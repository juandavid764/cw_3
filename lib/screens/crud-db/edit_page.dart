import 'package:mr_croc/screens/crud-db/statistics/screen_statistics.dart';
import 'package:mr_croc/screens/crud-db/view_additions.dart';
import 'package:mr_croc/screens/crud-db/view_categorias.dart';
import 'package:mr_croc/screens/crud-db/view_products.dart';
import 'package:flutter/material.dart';

import 'package:mr_croc/database/db_functions.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) =>
                  false, // Se establece la condiciÃ³n para eliminar todas las rutas
            );
          },
          icon: const Icon(Icons.food_bank),
        ),
        automaticallyImplyLeading: false,
        title: const Text('Editar'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctr) => const StatisticsScreen()),
              );
            },
            icon: const Icon(
              Icons.insert_chart_rounded,
              color: Color.fromARGB(255, 255, 230, 0),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 100),

            //Boton 'Products'
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctr) => const ViewProducts()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                child: Text('Productos', style: TextStyle(fontSize: 18.0)),
              ),
            ),

            //Boton 'categorias'
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctr) => const ViewCategories()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                child: Text('Categorias', style: TextStyle(fontSize: 18.0)),
              ),
            ),
            const SizedBox(height: 100),

            //Boton 'Adiciones'
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctr) => const ViewAdditions()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                child: Text('Adiciones', style: TextStyle(fontSize: 18.0)),
              ),
            ),
            const SizedBox(height: 50),

            //Boton borrar estadisticas
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 40.0,
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool result = await deleteStadictis();
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('EstadÃ­sticas borradas con Ã©xito'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Error al borrar estadÃ­sticas'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: const Text(
                  'Limpiar estadÃ­sticas',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
