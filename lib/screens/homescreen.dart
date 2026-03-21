import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/screens/crud-db/password_page.dart';
import 'package:mr_croc/screens/nodes.dart';
import 'package:mr_croc/services/sync_service.dart';

class HomeScreeen extends StatefulWidget {
  const HomeScreeen({super.key});

  @override
  State<HomeScreeen> createState() => _HomeScreeenState();
}

class _HomeScreeenState extends State<HomeScreeen> {
  Future<void> _syncNow() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Sincronizando...')),
    );

    try {
      final client = Supabase.instance.client;
      final report = await SyncService(
        client: client,
        database: database,
      ).syncAll();

      if (!mounted) {
        return;
      }

      if (report.errors.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Sync parcial: ${report.pushed} subidos, '
              '${report.pulled} bajados',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Sync completo: ${report.pushed} subidos, '
              '${report.pulled} bajados',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Error de sync: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mr Croc',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _syncNow,
            icon: const Icon(
              Icons.sync,
              color: Color.fromARGB(255, 255, 230, 0),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctxs) => const PasswordPage()));
              },
              icon: const Icon(
                Icons.settings,
                color: Color.fromARGB(255, 255, 230, 0),
              ))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 350),
        //color: Colors.amber,
        alignment: Alignment.bottomRight,
        child: const Nodes(),
      ),
    );
  }
}
