import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/models/model_salsa.dart';
import 'package:mr_croc/screens/crud-db/add_salsa.dart';
import 'package:mr_croc/screens/crud-db/update_salsa.dart';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:flutter/material.dart';

class ViewSalsas extends StatelessWidget {
  const ViewSalsas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salsas'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddSalsa(),
              ));
            },
            icon: const Icon(Icons.add),
          )
        ],
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: salsasList,
        builder: (context, value, child) {
          if (value.isEmpty) {
            return Center(
              child: Text(
                'No hay salsas registradas',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final salsa = value[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 1,
                child: ListTile(
                  // Color preview widget
                  leading: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: salsa.getColorObject(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                  title: Text(
                    salsa.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    salsa.color,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UpdateSalsa(salsa: salsa),
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          deleteSalsaDialog(context, salsa);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UpdateSalsa(salsa: salsa),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void deleteSalsaDialog(context, SalsaModel salsa) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Salsa'),
          content: Text('¿Quieres eliminar la salsa "${salsa.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                deleteSalsaConfirmed(context, salsa);
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void deleteSalsaConfirmed(context, SalsaModel salsa) {
    deleteSalsa(int.tryParse(salsa.id) ?? 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Salsa eliminada correctamente"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        backgroundColor: Color.fromARGB(255, 82, 134, 255),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }
}
