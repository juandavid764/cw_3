import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncReport {
  SyncReport({
    this.pushed = 0,
    this.pulled = 0,
    List<String>? errors,
  }) : errors = errors ?? [];

  int pushed;
  int pulled;
  final List<String> errors;

  SyncReport merge(SyncReport other) {
    pushed += other.pushed;
    pulled += other.pulled;
    errors.addAll(other.errors);
    return this;
  }
}

class SyncService {
  SyncService({
    required SupabaseClient client,
    required Database database,
    List<SyncTableConfig>? tables,
  })  : _client = client,
        _db = database,
        _tables = tables ?? SyncTableConfig.defaultTables;

  final SupabaseClient _client;
  final Database _db;
  final List<SyncTableConfig> _tables;

  Future<SyncReport> syncAll() async {
    final report = SyncReport();
    report.merge(await pushPendingChanges());
    report.merge(await pullChanges());
    return report;
  }

  Future<SyncReport> pushPendingChanges() async {
    final report = SyncReport();
    final rows = await _db.rawQuery(
      'SELECT outbox_id, table_name, row_id, row_uuid, operation, payload '
      'FROM sync_outbox ORDER BY outbox_id ASC',
    );

    for (final row in rows) {
      final outboxId = row['outbox_id'] as int;
      final table = row['table_name'] as String;
      final config = _configFor(table);
      if (config == null || !config.pushEnabled) {
        continue;
      }

      final operation = row['operation'] as String;
      final rowId = row['row_id'] as int?;
      final rowUuid = row['row_uuid'] as String?;
      final payload = _decodePayload(row['payload']);

      try {
        final sendPayload = await config.transformPayload(payload, _db);
        final uuid = (sendPayload['uuid'] ?? rowUuid)?.toString() ?? '';
        if (uuid.isEmpty) {
          throw StateError('Missing uuid for $table outbox $outboxId');
        }
        sendPayload['uuid'] = uuid;
        sendPayload.remove('sync_status');

        if (operation == 'delete') {
          final deletePayload = <String, Object?>{
            'deleted_at':
                sendPayload['deleted_at'] ?? _nowUtcString(),
            'updated_at':
                sendPayload['updated_at'] ?? _nowUtcString(),
          };
          await _client
              .from(table)
              .update(deletePayload)
              .eq('uuid', uuid);
        } else {
          if (operation != 'insert') {
            sendPayload.remove(config.idColumn);
          }
          await _client
              .from(table)
              .upsert(sendPayload, onConflict: 'uuid');
        }

        await _markOutboxDone(
          outboxId: outboxId,
          table: table,
          config: config,
          rowId: rowId,
          rowUuid: rowUuid,
        );
        report.pushed += 1;
      } catch (e) {
        report.errors.add('$table:$outboxId:$e');
        await _markOutboxError(outboxId, e.toString());
      }
    }

    await _setSyncMeta('last_push_at', _nowUtcString());
    return report;
  }

  Future<SyncReport> pullChanges() async {
    final report = SyncReport();

    for (final config in _tables) {
      if (!config.pullEnabled) {
        continue;
      }
      final lastPullKey = 'last_pull_${config.name}';
      final lastPull = await _getSyncMeta(lastPullKey);

      final query = _client.from(config.name).select();
      final response = (lastPull == null || lastPull.isEmpty)
          ? await query
          : await query.gt('updated_at', lastPull);

      if (response is! List) {
        continue;
      }

      String latestUpdatedAt = lastPull ?? '';
      for (final item in response) {
        if (item is! Map) {
          continue;
        }
        final row = Map<String, Object?>.from(item);
        final updatedAt = row['updated_at']?.toString() ?? '';
        if (updatedAt.isNotEmpty &&
            _isAfter(updatedAt, latestUpdatedAt)) {
          latestUpdatedAt = updatedAt;
        }
        await _applyRemoteRow(config, row);
        report.pulled += 1;
      }

      if (latestUpdatedAt.isNotEmpty) {
        await _setSyncMeta(lastPullKey, latestUpdatedAt);
      }
    }

    return report;
  }

  SyncTableConfig? _configFor(String table) {
    for (final config in _tables) {
      if (config.name == table) {
        return config;
      }
    }
    return null;
  }

  Future<void> _applyRemoteRow(
    SyncTableConfig config,
    Map<String, Object?> row,
  ) async {
    final uuid = row['uuid']?.toString();
    if (uuid == null || uuid.isEmpty) {
      return;
    }

    final existing = await _db.rawQuery(
      'SELECT ${config.idColumn} FROM ${config.name} WHERE uuid = ? LIMIT 1',
      [uuid],
    );

    final deletedAt = row['deleted_at']?.toString() ?? '';
    if (deletedAt.isNotEmpty) {
      await _db.rawUpdate(
        'UPDATE ${config.name} SET deleted_at = ?, updated_at = ?, '
        'sync_status = 1 WHERE uuid = ?',
        [
          deletedAt,
          row['updated_at'] ?? deletedAt,
          uuid,
        ],
      );
      return;
    }

    if (existing.isEmpty) {
      final insertData = Map<String, Object?>.from(row);
      if (!config.includeIdOnInsert) {
        insertData.remove(config.idColumn);
      }
      insertData['sync_status'] = 1;
      await _db.insert(
        config.name,
        insertData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final updateData = Map<String, Object?>.from(row);
      updateData.remove(config.idColumn);
      updateData['sync_status'] = 1;
      await _db.update(
        config.name,
        updateData,
        where: 'uuid = ?',
        whereArgs: [uuid],
      );
    }
  }

  Future<void> _markOutboxDone({
    required int outboxId,
    required String table,
    required SyncTableConfig config,
    int? rowId,
    String? rowUuid,
  }) async {
    if (rowId != null) {
      await _db.rawUpdate(
        'UPDATE $table SET sync_status = 1 WHERE ${config.idColumn} = ?',
        [rowId],
      );
    } else if (rowUuid != null && rowUuid.isNotEmpty) {
      await _db.rawUpdate(
        'UPDATE $table SET sync_status = 1 WHERE uuid = ?',
        [rowUuid],
      );
    }
    await _db.rawDelete(
      'DELETE FROM sync_outbox WHERE outbox_id = ?',
      [outboxId],
    );
  }

  Future<void> _markOutboxError(int outboxId, String error) async {
    await _db.rawUpdate(
      'UPDATE sync_outbox '
      'SET attempt_count = attempt_count + 1, last_error = ? '
      'WHERE outbox_id = ?',
      [error, outboxId],
    );
  }

  Future<String?> _getSyncMeta(String key) async {
    final rows = await _db.rawQuery(
      'SELECT value FROM sync_meta WHERE key = ? LIMIT 1',
      [key],
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value']?.toString();
  }

  Future<void> _setSyncMeta(String key, String value) async {
    await _db.rawInsert(
      'INSERT OR REPLACE INTO sync_meta (key, value) VALUES(?,?)',
      [key, value],
    );
  }

  Map<String, Object?> _decodePayload(Object? raw) {
    if (raw == null) {
      return {};
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, Object?>.from(decoded);
      }
    }
    if (raw is Map) {
      return Map<String, Object?>.from(raw);
    }
    return {};
  }

  String _nowUtcString() {
    final now = DateTime.now().toUtc();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  bool _isAfter(String candidate, String baseline) {
    if (baseline.isEmpty) {
      return true;
    }
    final candidateDate = DateTime.tryParse(candidate);
    final baselineDate = DateTime.tryParse(baseline);
    if (candidateDate == null || baselineDate == null) {
      return candidate.compareTo(baseline) > 0;
    }
    return candidateDate.isAfter(baselineDate);
  }
}

typedef PayloadTransform = Future<Map<String, Object?>> Function(
  Map<String, Object?> payload,
  Database database,
);

class SyncTableConfig {
  const SyncTableConfig({
    required this.name,
    required this.idColumn,
    this.pushEnabled = true,
    this.pullEnabled = true,
    this.includeIdOnInsert = true,
    this.payloadTransform,
  });

  final String name;
  final String idColumn;
  final bool pushEnabled;
  final bool pullEnabled;
  final bool includeIdOnInsert;
  final PayloadTransform? payloadTransform;

  static const defaultTables = [
    SyncTableConfig(name: 'products', idColumn: 'product_id'),
    SyncTableConfig(name: 'categories', idColumn: 'category_id'),
    SyncTableConfig(name: 'additions', idColumn: 'addition_id'),
    SyncTableConfig(name: 'sales', idColumn: 'sale_id'),
    SyncTableConfig(
      name: 'details_sale_product',
      idColumn: 'details_product_id',
    ),
    SyncTableConfig(name: 'dates', idColumn: 'date_id'),
    SyncTableConfig(name: 'config', idColumn: 'config_id'),
  ];

  Future<Map<String, Object?>> transformPayload(
    Map<String, Object?> payload,
    Database database,
  ) async {
    if (payloadTransform != null) {
      return payloadTransform!(payload, database);
    }
    return Map<String, Object?>.from(payload);
  }
}
