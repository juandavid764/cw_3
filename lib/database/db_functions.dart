import 'package:mr_croc/models/model_additions.dart';
import 'package:mr_croc/models/model_category.dart';
import 'package:mr_croc/models/model_sale_product.dart';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mr_croc/models/model_product.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

late Database _db;
//Es una variable privada que se declarara mas adelante (Antes de ser usada)

const int syncStatusPending = 0;
const int syncStatusSynced = 1;

Database get database => _db;

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _nowUtcString() {
  final now = DateTime.now().toUtc();
  final year = now.year.toString().padLeft(4, '0');
  return '$year-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
      '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
}

String _generateUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  final buffer = StringBuffer();
  for (final value in bytes) {
    buffer.write(value.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

Future<void> _ensureSyncSchema() async {
  const tables = [
    'products',
    'categories',
    'additions',
    'sales',
    'details_sale_product',
    'dates',
    'config',
  ];

  for (final table in tables) {
    await _ensureSyncColumns(table);
  }

  await _db.execute(
    '''
    CREATE TABLE IF NOT EXISTS sync_meta (
      key TEXT PRIMARY KEY,
      value TEXT
    )
    ''',
  );

  await _db.execute(
    '''
    CREATE TABLE IF NOT EXISTS sync_outbox (
      outbox_id INTEGER PRIMARY KEY AUTOINCREMENT,
      table_name TEXT NOT NULL,
      row_id INTEGER,
      row_uuid TEXT,
      operation TEXT NOT NULL,
      payload TEXT,
      created_at TEXT NOT NULL DEFAULT '',
      attempt_count INTEGER NOT NULL DEFAULT 0,
      last_error TEXT
    )
    ''',
  );

  for (final table in tables) {
    await _db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_${table}_uuid ON $table(uuid)',
    );
    await _fillSyncDefaults(table);
  }
}

Future<void> _ensureSyncColumns(String table) async {
  final columns = await _db.rawQuery('PRAGMA table_info($table)');
  final existing = <String>{};
  for (final row in columns) {
    final name = row['name'] as String?;
    if (name != null) {
      existing.add(name);
    }
  }

  final requiredColumns = <String, String>{
    'uuid': 'TEXT',
    'created_at': "TEXT NOT NULL DEFAULT ''",
    'updated_at': "TEXT NOT NULL DEFAULT ''",
    'deleted_at': 'TEXT',
    'sync_status': 'INTEGER NOT NULL DEFAULT 0',
  };

  for (final entry in requiredColumns.entries) {
    if (!existing.contains(entry.key)) {
      await _db.execute(
        'ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}',
      );
    }
  }
}

Future<void> _fillSyncDefaults(String table) async {
  final now = _nowUtcString();
  await _db.rawUpdate(
    "UPDATE $table SET uuid = lower(hex(randomblob(16))) "
    "WHERE uuid IS NULL OR uuid = ''",
  );
  await _db.rawUpdate(
    "UPDATE $table SET created_at = ? "
    "WHERE created_at IS NULL OR created_at = ''",
    [now],
  );
  await _db.rawUpdate(
    "UPDATE $table SET updated_at = ? "
    "WHERE updated_at IS NULL OR updated_at = ''",
    [now],
  );
}

Future<String> _ensureRowUuid(String table, String idColumn, int id) async {
  final rows = await _db.rawQuery(
    'SELECT uuid FROM $table WHERE $idColumn = ?',
    [id],
  );
  var uuid = '';
  if (rows.isNotEmpty) {
    uuid = (rows.first['uuid'] as String?) ?? '';
  }

  if (uuid.isEmpty) {
    uuid = _generateUuid();
    await _db.rawUpdate(
      'UPDATE $table SET uuid = ? WHERE $idColumn = ?',
      [uuid, id],
    );
  }

  return uuid;
}

Future<void> _insertOutbox({
  required String table,
  int? rowId,
  String? rowUuid,
  required String operation,
  Map<String, Object?>? payload,
}) async {
  await _db.rawInsert(
    'INSERT INTO sync_outbox '
    '(table_name, row_id, row_uuid, operation, payload, created_at) '
    'VALUES(?,?,?,?,?,?)',
    [
      table,
      rowId,
      rowUuid,
      operation,
      payload == null ? null : jsonEncode(payload),
      _nowUtcString(),
    ],
  );
}

Future<void> _markDeleted(String table, String idColumn, int id) async {
  final now = _nowUtcString();
  final uuid = await _ensureRowUuid(table, idColumn, id);

  await _db.rawUpdate(
    'UPDATE $table SET deleted_at = ?, updated_at = ?, sync_status = ? '
    'WHERE $idColumn = ?',
    [now, now, syncStatusPending, id],
  );

  await _insertOutbox(
    table: table,
    rowId: id,
    rowUuid: uuid,
    operation: 'delete',
    payload: {
      'uuid': uuid,
      idColumn: id,
      'deleted_at': now,
    },
  );
}

Future<void> _markAllDeleted(String table, String idColumn) async {
  final rows = await _db.rawQuery(
    'SELECT $idColumn as id FROM $table '
    "WHERE deleted_at IS NULL OR deleted_at = ''",
  );
  for (final row in rows) {
    final id = row['id'];
    if (id is int) {
      await _markDeleted(table, idColumn, id);
    }
  }
}

Future<void> initializeDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "cw_database.db");

  // Check if the database exists
  var exists = await databaseExists(path);

  if (!exists) {
    // Should happen only the first time you launch your application

    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (e) {
      //print("Error creating directory: $e");
    }

    // Copy from asset
    ByteData data = await rootBundle.load(url.join("assets", "cw_database.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  } else {}

  // open the database
  _db = await openDatabase(path);
  await _ensureSyncSchema();
}

//Obtener id fecha actual
Future<void> gerDateNow() async {
  DateTime time = DateTime.now();
  String fechaNow = '${time.year}-${time.month}-${time.day}';

  //Vaciamos la bd el primer dia del mes
  if (time.day == 1) {
    await deleteStadictis();
  }

  //Consultamos si la fecha ya existe
  final List<Map<String, dynamic>> result = await _db.rawQuery(
    "SELECT date_id FROM dates WHERE date = ? "
    "AND (deleted_at IS NULL OR deleted_at = '');",
    [fechaNow],
  );

  if (result.isEmpty) {
    try {
      final now = _nowUtcString();
      final uuid = _generateUuid();

      //Insertamos y obetemeos ultimo id
      int idFecha = await _db.rawInsert(
        'INSERT INTO dates '
        '(date, uuid, created_at, updated_at, sync_status) '
        'VALUES(?,?,?,?,?)',
        [fechaNow, uuid, now, now, syncStatusPending],
      );

      await _insertOutbox(
        table: 'dates',
        rowId: idFecha,
        rowUuid: uuid,
        operation: 'insert',
        payload: {
          'uuid': uuid,
          'date': fechaNow,
          'created_at': now,
          'updated_at': now,
        },
      );

      //Guardamos el id
      idFechaNow.value = idFecha;
      // ignore: empty_catches
    } catch (e) {}
    //Si hay coincidencias
  } else {
    //Obtenemos el id de la base de datos
    idFechaNow.value = result[0]['date_id'];
  }
}

//------------------------------------------------------------------------------
//Products
//Obtiene todo los productos de la base de datos
Future<void> getproductsdata() async {
  //Obtiene todos los productos de la tabla, guarda la filas encontradas en result
  final result = await _db.rawQuery(
    "SELECT * FROM products WHERE deleted_at IS NULL OR deleted_at = ''",
  );

  //Vacia la lista para llenarla con los valores de la consulta
  productList.value.clear();
  for (var map in result) {
    //Agrega cada producto obtenido a "productList"
    final product = ProductModel.fromMap(map);
    productList.value.add(product);
  }
  productList.notifyListeners();
}

//Insertar un nuevo producto a la BS
Future<void> addproduct(ProductModel value) async {
  try {
    final now = _nowUtcString();
    final uuid = _generateUuid();
    final id = await _db.rawInsert(
      'INSERT INTO products '
      '(name, price, category, additives, text, uuid, created_at, updated_at, '
      'sync_status) VALUES(?,?,?,?,?,?,?,?,?)',
      [
        value.name,
        value.price,
        value.category,
        value.salsas,
        value.text,
        uuid,
        now,
        now,
        syncStatusPending,
      ],
    );

    await _insertOutbox(
      table: 'products',
      rowId: id,
      rowUuid: uuid,
      operation: 'insert',
      payload: {
        'uuid': uuid,
        'name': value.name,
        'price': value.price,
        'category': value.category,
        'additives': value.salsas,
        'text': value.text,
        'created_at': now,
        'updated_at': now,
      },
    );

    //Actuliza la lista de productos "productList"
    await getproductsdata();
    // ignore: empty_catches
  } catch (e) {}
}

//Recibe un id y elimina el producto dicho id, actuliza "productList"
Future<void> deleteProduct(id) async {
  if (id is int) {
    await _markDeleted('products', 'product_id', id);
    await getproductsdata();
  }
}

//Realiza update en la bs, actualiza "productList"
Future<void> editproduct(
  int id,
  String name,
  int price,
  int category,
  int salsas,
  String texto,
) async {
  final now = _nowUtcString();
  final uuid = await _ensureRowUuid('products', 'product_id', id);
  await _db.rawUpdate(
    'UPDATE products SET name = ?, price = ?, category = ?, additives = ?, '
    'text = ?, updated_at = ?, sync_status = ? WHERE product_id = ?',
    [name, price, category, salsas, texto, now, syncStatusPending, id],
  );
  await _insertOutbox(
    table: 'products',
    rowId: id,
    rowUuid: uuid,
    operation: 'update',
    payload: {
      'uuid': uuid,
      'name': name,
      'price': price,
      'category': category,
      'additives': salsas,
      'text': texto,
      'updated_at': now,
    },
  );
  await getproductsdata();
}

//------------------------------------------------------------------------------
//Categories
//Obtiene todo los productos de la base de datos
Future<void> getcategoriesdata() async {
  //Obtiene todos las categorias de la tabla, guarda la filas encontradas en result
  final result = await _db.rawQuery(
    "SELECT * FROM categories WHERE deleted_at IS NULL OR deleted_at = ''",
  );
  //print('All Products data : $result');

  //Vacia la lista para llenarla con los valores de la consulta
  categorytList.value.clear();
  for (var map in result) {
    //Agrega cada producto obtenido a "productList"
    final category = CategoryModel.fromMap(map);
    categorytList.value.add(category);
  }
  categorytList.notifyListeners();
}

//Obtiene las categorias raiz
Future<void> getRoots() async {
  //Obtiene todos los productos de la tabla, guarda la filas encontradas en result
  final result = await _db.rawQuery(
    "SELECT category_id, category_name, parentCategory FROM categories "
    "WHERE parentCategory IS NULL AND "
    "(deleted_at IS NULL OR deleted_at = '')",
  );
  //print('All Products data : $result');

  //Vacia la lista para llenarla con los valores de la consulta
  rootsCategories.value.clear();
  for (var map in result) {
    //Agrega cada producto obtenido a "productList"
    final category = CategoryModel.fromMap(map);
    rootsCategories.value.add(category);
  }
}

//Insentar una nueva categoria
Future<void> addCategory(CategoryModel value) async {
  try {
    final now = _nowUtcString();
    final uuid = _generateUuid();
    final id = await _db.rawInsert(
      'INSERT INTO categories '
      '(category_name, parentCategory, uuid, created_at, updated_at, '
      'sync_status) VALUES(?,?,?,?,?,?)',
      [
        value.name,
        value.parent,
        uuid,
        now,
        now,
        syncStatusPending,
      ],
    );

    await _insertOutbox(
      table: 'categories',
      rowId: id,
      rowUuid: uuid,
      operation: 'insert',
      payload: {
        'uuid': uuid,
        'category_name': value.name,
        'parentCategory': value.parent,
        'created_at': now,
        'updated_at': now,
      },
    );

    //Actuliza la lista de categorias "categoryList"
    await getcategoriesdata();
    await getRoots();
    // ignore: empty_catches
  } catch (e) {}
}

//Recibe un id y elimina la categoria dicho id, actuliza "CategotytList"
Future<void> deleteCategory(id) async {
  if (id is int) {
    await _markDeleted('categories', 'category_id', id);
    await getcategoriesdata();
    await getRoots();
  }
}

//Realiza update en la bs, actualiza "CategotytList"
Future<void> editCategory(CategoryModel categoria) async {
  final now = _nowUtcString();
  final uuid = await _ensureRowUuid('categories', 'category_id', categoria.id);
  await _db.rawUpdate(
    'UPDATE categories SET category_name = ?, parentCategory = ?, '
    'updated_at = ?, sync_status = ? WHERE category_id = ?',
    [categoria.name, categoria.parent, now, syncStatusPending, categoria.id],
  );
  await _insertOutbox(
    table: 'categories',
    rowId: categoria.id,
    rowUuid: uuid,
    operation: 'update',
    payload: {
      'uuid': uuid,
      'category_name': categoria.name,
      'parentCategory': categoria.parent,
      'updated_at': now,
    },
  );
  await getcategoriesdata();
  await getRoots();
}

//------------------------------------------------------------------------------
//additions
//Obtiene todo los productos de la base de datos
Future<void> getAdditionesData() async {
  final result = await _db.rawQuery(
    "SELECT * FROM additions WHERE deleted_at IS NULL OR deleted_at = ''",
  );
  //print('All Products data : $result');

  //Vacia la lista para llenarla con los valores de la consulta
  additionsList.value.clear();

  for (var map in result) {
    //Agrega cada producto obtenido a "additionsList"
    final addition = AdditionModel.fromMap(map);
    additionsList.value.add(addition);
  }
  //Avisar a los oyentes (widgets) un cambio en la lista
  additionsList.notifyListeners();
}

///Insentar una nueva adicion
Future<void> addAddition(AdditionModel value) async {
  try {
    final now = _nowUtcString();
    final uuid = _generateUuid();
    final id = await _db.rawInsert(
      'INSERT INTO additions '
      '(name, price, uuid, created_at, updated_at, sync_status) '
      'VALUES(?,?,?,?,?,?)',
      [
        value.name,
        value.price,
        uuid,
        now,
        now,
        syncStatusPending,
      ],
    );

    await _insertOutbox(
      table: 'additions',
      rowId: id,
      rowUuid: uuid,
      operation: 'insert',
      payload: {
        'uuid': uuid,
        'name': value.name,
        'price': value.price,
        'created_at': now,
        'updated_at': now,
      },
    );

    //Actuliza la lista de categorias "categoryList"
    await getAdditionesData();
    // ignore: empty_catches
  } catch (e) {}
}

//Recibe un id y elimina la adicion de dicho id, actuliza "AdditionsList"
Future<void> deleteAddition(int id) async {
  await _markDeleted('additions', 'addition_id', id);
  await getAdditionesData();
}

//Realiza update de Adden la bs, actualiza "productList"
Future<void> editAddtion(AdditionModel addition) async {
  final now = _nowUtcString();
  final uuid = await _ensureRowUuid('additions', 'addition_id', addition.id);
  await _db.rawUpdate(
    'UPDATE additions SET name = ?, price = ?, updated_at = ?, '
    'sync_status = ? WHERE addition_id = ?',
    [addition.name, addition.price, now, syncStatusPending, addition.id],
  );
  await _insertOutbox(
    table: 'additions',
    rowId: addition.id,
    rowUuid: uuid,
    operation: 'update',
    payload: {
      'uuid': uuid,
      'name': addition.name,
      'price': addition.price,
      'updated_at': now,
    },
  );
  await getAdditionesData();
}

//------------------------------------------------------------------------------
//sales
Future<void> addSale(int total) async {
  DateTime time = DateTime.now();
  String horaNow = '${time.hour}';
  final now = _nowUtcString();
  int idsale;

  //Insertamos la venta y detalles
  try {
    final saleUuid = _generateUuid();
    idsale = await _db.rawInsert(
      'INSERT INTO sales '
      '(fecha, hora, total, uuid, created_at, updated_at, sync_status) '
      'VALUES(?,?,?,?,?,?,?)',
      [
        idFechaNow.value,
        horaNow,
        total,
        saleUuid,
        now,
        now,
        syncStatusPending,
      ],
    );

    await _insertOutbox(
      table: 'sales',
      rowId: idsale,
      rowUuid: saleUuid,
      operation: 'insert',
      payload: {
        'uuid': saleUuid,
        'fecha': idFechaNow.value,
        'hora': horaNow,
        'total': total,
        'created_at': now,
        'updated_at': now,
      },
    );

    //Se inserta cada producto y su cantidad a la venta correspondiente
    for (var orderNow in comanda.value) {
      final detailUuid = _generateUuid();
      final detailId = await _db.rawInsert(
        'INSERT INTO details_sale_product '
        '(product_id, quantity, sale_id, uuid, created_at, updated_at, '
        'sync_status) VALUES(?,?,?,?,?,?,?)',
        [
          orderNow.product.id,
          orderNow.cantidad,
          idsale,
          detailUuid,
          now,
          now,
          syncStatusPending,
        ],
      );
      await _insertOutbox(
        table: 'details_sale_product',
        rowId: detailId,
        rowUuid: detailUuid,
        operation: 'insert',
        payload: {
          'uuid': detailUuid,
          'product_id': orderNow.product.id,
          'quantity': orderNow.cantidad,
          'sale_id': idsale,
          'created_at': now,
          'updated_at': now,
        },
      );
    }
    // ignore: empty_catches
  } catch (e) {}
}

//Obtiene la cantidad de ventas en un fecha
Future<int> getQuantityCostumers(int dateToSearch) async {
  //Obtiene cuantos registro
  final List<Map<String, dynamic>> result = await _db.rawQuery(
    "SELECT count(*) as cantVentas FROM sales s "
    "INNER JOIN dates d ON s.fecha = d.date_id "
    "WHERE d.date_id = ? AND "
    "(s.deleted_at IS NULL OR s.deleted_at = '') AND "
    "(d.deleted_at IS NULL OR d.deleted_at = '')",
    [dateToSearch],
  );

  //Verifica que retornaron datos
  if (result.isNotEmpty) {
    // Obtener el valor de la columna "sales_count" del primer resultado
    final int salesCount = result[0]['cantVentas'];
    return salesCount; // Retornar el valor
  } else {
    // Si no se encontraron resultados, retornar 0
    return 0;
  }
}

//Suma los totales de cada venta en una fecha
Future<int> getNetValue(int dateToSearch) async {
  //Obtiene cuantos registro
  final List<Map<String, dynamic>> result = await _db.rawQuery(
    "SELECT sum(s.total) as neto FROM sales s "
    "INNER JOIN dates d ON s.fecha = d.date_id "
    "WHERE d.date_id = ? AND "
    "(s.deleted_at IS NULL OR s.deleted_at = '') AND "
    "(d.deleted_at IS NULL OR d.deleted_at = '')",
    [dateToSearch],
  );

  if (result[0]['neto'] != null) {
    // Obtener el valor de la columna "sales_count" del primer resultado
    final int valorNeto = result[0]['neto'];
    return valorNeto; // Retornar el valor
  } else {
    // Si no se encontraron resultados, retornar 0
    return 0;
  }
}

//Obtiene el id de un fecha texto
Future<int> getIdFechaSearch(String fecha) async {
  //Obtiene el id de la fecha que se quiere buscar

  final List<Map<String, dynamic>> result = await _db
      .rawQuery(
    "SELECT date_id FROM dates AS d WHERE d.date = ? "
    "AND (d.deleted_at IS NULL OR d.deleted_at = '')",
    [fecha],
  );
  //Verifica que retornaron datos
  if (result.isNotEmpty) {
    // Obtener el valor de la columna "sales_count" del primer resultado
    final int salesCount = result[0]['date_id'];
    return salesCount; // Retornar el valor
  } else {
    // Si no se encontraron resultados, retornar 0
    return 0;
  }
}

//Obtenemos la hora con mas ventas
Future<String> getBestHour(int dateToSearch) async {
  final List<Map<String, dynamic>> result = await _db.rawQuery(
    "SELECT hora FROM sales s WHERE s.fecha = ? AND "
    "(s.deleted_at IS NULL OR s.deleted_at = '') "
    "GROUP BY hora ORDER BY COUNT(*) DESC LIMIT 1;",
    [dateToSearch],
  );

  //Verifica que retornaron datos
  if (result.isNotEmpty) {
    // Obtener el valor de la columna "hora" del primer resultado
    final String besHour = result[0]['hora'];
    return besHour; // Retornar el valor
  } else {
    // Si no se encontraron resultados, retornar ''
    return '';
  }
}

//Obtenemos los productos yentas
Future<bool> getProductsSales(int dateToSearch) async {
  pdtStadictsList.value.clear();

  final List<Map<String, dynamic>> result = await _db.rawQuery(
    "SELECT p.text, SUM(dsp.quantity) AS ventaProducto "
    "FROM products p "
    "INNER JOIN details_sale_product dsp USING(product_id) "
    "INNER JOIN sales s USING(sale_id) "
    "INNER JOIN dates d ON d.date_id = s.fecha "
    "WHERE s.fecha = ? AND "
    "(s.deleted_at IS NULL OR s.deleted_at = '') AND "
    "(d.deleted_at IS NULL OR d.deleted_at = '') AND "
    "(dsp.deleted_at IS NULL OR dsp.deleted_at = '') "
    "GROUP BY p.text ORDER BY COUNT(*) DESC;",
    [dateToSearch],
  );

  if (result.isEmpty) {
    pdtStadictsList.value['Sin ventas'] = 0;
    return false; // No hay ventas
  } else {

    for (var map in result) {
      //Agrega cada producto obtenido al mapa
      final product = SaleProductsModel.fromMap(map);
      pdtStadictsList.value[product.name] = product.quantity.toDouble();
    }

    return true;
  }

  

}

//-------------------------------------------------------------------
//Native querys


//? Eliminamos la informacion de las estadisticas
Future<bool> deleteStadictis() async {
  try {
    await _markAllDeleted('details_sale_product', 'details_product_id');
    await _markAllDeleted('sales', 'sale_id');
    await _markAllDeleted('dates', 'date_id');
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> getIp() async {
  try {
    final List<Map<String, dynamic>> result = await _db.rawQuery(
      "SELECT ip FROM config "
      "WHERE deleted_at IS NULL OR deleted_at = '' LIMIT 1;",
    );

    if (result.isNotEmpty) {
      return result[0]['ip'];
    } else {
      return 'No IP found'; // Return a default or error string
    }
    
  } catch (e) {
    return 'Error'; // Return a default or error string
  }
}

Future<bool> updateip(String ip) async {
  try {
    final now = _nowUtcString();
    final uuid = await _ensureRowUuid('config', 'config_id', 1);
    await _db.rawUpdate(
      'UPDATE config SET ip = ?, updated_at = ?, sync_status = ? '
      'WHERE config_id = 1',
      [ip, now, syncStatusPending],
    );
    await _insertOutbox(
      table: 'config',
      rowId: 1,
      rowUuid: uuid,
      operation: 'update',
      payload: {
        'uuid': uuid,
        'ip': ip,
        'updated_at': now,
      },
    );
    return true;
  } catch (e) {
    return false;
  }
}
