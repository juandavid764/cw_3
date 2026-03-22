import 'package:mr_croc/screens/crud-db/statistics/screen_statistics.dart';
import 'package:mr_croc/screens/crud-db/view_additions.dart';
import 'package:mr_croc/screens/crud-db/view_categorias.dart';
import 'package:mr_croc/screens/crud-db/view_products.dart';
import 'package:mr_croc/screens/crud-db/view_salsas.dart';
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
    // Obtener dimensiones de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calcular espacios responsivos
    final verticalSpacing = screenHeight * 0.08; // 8% de la altura
    final buttonPadding = screenWidth > 600 ? 60.0 : 40.0; // Responsive padding

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
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
            icon: Icon(
              Icons.insert_chart_rounded,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Boton 'Productos'
                _CrudButton(
                  label: 'Productos',
                  icon: Icons.shopping_cart,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctr) => const ViewProducts()),
                    );
                  },
                  padding: buttonPadding,
                ),

                // Boton 'Categorias'
                _CrudButton(
                  label: 'Categorias',
                  icon: Icons.folder,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctr) => const ViewCategories()),
                    );
                  },
                  padding: buttonPadding,
                ),

                // Boton 'Adiciones'
                _CrudButton(
                  label: 'Adiciones',
                  icon: Icons.add_circle,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctr) => const ViewAdditions()),
                    );
                  },
                  padding: buttonPadding,
                ),

                // Boton 'Salsas'
                _CrudButton(
                  label: 'Salsas',
                  icon: Icons.fastfood,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctr) => const ViewSalsas()),
                    );
                  },
                  padding: buttonPadding,
                ),

                // Boton borrar estadisticas
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: buttonPadding * 0.66),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool result = await deleteStadictis();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: result ? Colors.green : Colors.red,
                            content: Text(
                              result
                                  ? 'Estadísticas borradas con éxito'
                                  : 'Error al borrar estadísticas',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Limpiar Estadísticas',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: buttonPadding * 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget reutilizable para botones de CRUD
class _CrudButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double padding;

  const _CrudButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: padding),
      ),
    );
  }
}
