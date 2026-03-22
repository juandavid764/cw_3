//import 'dart:ffi';
import 'dart:math';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:mr_croc/models/model_salsa.dart';
import 'package:mr_croc/screens/adiciones.dart';
import 'package:mr_croc/screens/confrim.dart';
import 'package:flutter/material.dart';

//inicializar pantalla salsas
class Salsas extends StatefulWidget {
  const Salsas({Key? key}) : super(key: key);

  @override
  _SalsasState createState() => _SalsasState();
}

//Pantalla Menu
class _SalsasState extends State<Salsas> {
  bool isSwitchedOn = false;
  late List<bool> isSelected;
  late List<SalsaModel> salsas;

  double marginHorizontal = 40;
  double marginVertical = 20;

  @override
  void initState() {
    super.initState();
    _initializeSalsas();
  }

  void _initializeSalsas() {
    salsas = salsasList.value;
    isSelected = List<bool>.filled(salsas.length, false);
  }

  // Calcula la luminancia relativa de un color (0 = oscuro, 1 = claro)
  static double _getLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  // Retorna el color de texto óptimo basado en la luminancia del fondo
  static Color _getTextColor(Color backgroundColor) {
    final luminance = _getLuminance(backgroundColor);
    // Si la luminancia es > 0.5, el color es claro, usa texto oscuro
    // Si no, usa texto blanco
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    String selectedOptions = '';
    int cantProductos = comanda.value[indexComanda.value].cantidad;

    void salsaSelected() {
      //Se obtienen las salsas y se formatea
      selectedOptions = '[';

      for (int i = 0; i < isSelected.length; i++) {
        if (isSelected[i]) {
          selectedOptions += '${salsas[i].name}, ';
        }
      }

      selectedOptions += ']';

      //Si no se seleccionaron, van sin salsas
      if (selectedOptions == '[]') {
        selectedOptions = '[Sin salsas]';
      }

      int tamano = comanda.value[indexComanda.value].salsas.length;

      int index = indexSalsas.value;

      //si el indice se ha inicializado
      if (index >= 0 && index < tamano) {
        comanda.value[indexComanda.value].salsas[indexSalsas.value] =
            selectedOptions;
      } else {
        comanda.value[indexComanda.value].salsas.add(selectedOptions);
      }
    }

    return ValueListenableBuilder(
      valueListenable: salsasList,
      builder: (context, salsasFromDb, child) {
        // Actualizar lista local cuando cambia la BD
        if (salsas.length != salsasFromDb.length) {
          salsas = salsasFromDb;
          isSelected = List<bool>.filled(salsas.length, false);
        }

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  //Si se selecionaron todas las salsas
                  if (cantProductos == indexSalsas.value + 1 &&
                      indexSalsas.value + 1 > 1) {
                    indexSalsas.value--;
                  }
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                "Salsas",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                Switch(
                  value: isSwitchedOn,
                  onChanged: (newValue) {
                    setState(() {
                      isSwitchedOn = newValue;
                    });
                  },
                ),
              ],
            ),
            body:
                salsas.isEmpty
                    ? Center(
                      child: Text(
                        'No hay salsas registradas',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${indexSalsas.value + 1}/$cantProductos',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          'Selecciona tus salsas favoritas:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: List.generate(salsas.length, (index) {
                                  final salsa = salsas[index];
                                  final salsaColor = salsa.getColorObject();
                                  final isSelectedLocal = isSelected[index];
                                  final labelColor =
                                      isSelectedLocal
                                          ? _getTextColor(salsaColor)
                                          : Colors.white;
                                  final chipBackground =
                                      isSelectedLocal
                                          ? salsaColor
                                          : Colors.transparent;

                                  return ChoiceChip(
                                    avatar:
                                        isSelectedLocal
                                            ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color: labelColor,
                                            )
                                            : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    selectedColor: salsaColor,
                                    backgroundColor: chipBackground,
                                    side: BorderSide(
                                      color:
                                          isSelectedLocal
                                              ? salsaColor
                                              : Colors.white,
                                      width: isSelectedLocal ? 2 : 2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.04,
                                      vertical: 8,
                                    ),
                                    labelStyle: TextStyle(
                                      color: labelColor,
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.35),
                                          offset: const Offset(0.5, 0.5),
                                          blurRadius: 1.5,
                                        ),
                                      ],
                                    ),
                                    label: Text(salsa.name),
                                    selected: isSelected[index],
                                    onSelected: (bool selected) {
                                      setState(() {
                                        isSelected[index] = selected;
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  salsaSelected();

                                  if (isSwitchedOn == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            ((context) => const Adiciones()),
                                      ),
                                    );
                                  } else {
                                    int tamanoListSalsas =
                                        comanda
                                            .value[indexComanda.value]
                                            .salsas
                                            .length;
                                    int tamanoListAdics =
                                        comanda
                                            .value[indexComanda.value]
                                            .adiciones
                                            .length;
                                    int diferencia =
                                        tamanoListSalsas - tamanoListAdics;

                                    for (var i = 0; i < diferencia; i++) {
                                      comanda
                                          .value[indexComanda.value]
                                          .adiciones
                                          .add([]);
                                    }

                                    if (cantProductos ==
                                        indexSalsas.value + 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              ((context) => const PrintPage()),
                                        ),
                                      );
                                    } else {
                                      indexSalsas.value++;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              ((context) => const Salsas()),
                                        ),
                                      );
                                    }
                                  }
                                },
                                onLongPress: () {
                                  //Se obtienen las salsas y se agregarn
                                  salsaSelected();
                                  int tamanoListSalsas =
                                      comanda
                                          .value[indexComanda.value]
                                          .salsas
                                          .length;
                                  int tamanoListAdics =
                                      comanda
                                          .value[indexComanda.value]
                                          .adiciones
                                          .length;
                                  int diferencia =
                                      tamanoListSalsas - tamanoListAdics;

                                  //Igualamos salsas y adiciones
                                  for (var i = 0; i < diferencia; i++) {
                                    comanda.value[indexComanda.value].adiciones
                                        .add([]);
                                  }

                                  int indexNow = indexSalsas.value;
                                  int indexNext = indexNow + 1;

                                  //Si los indices posteriores esta inicialidos
                                  if (indexNow < cantProductos) {
                                    for (
                                      var i = indexNext;
                                      i < cantProductos;
                                      i++
                                    ) {
                                      //si el indice se ha inicializado
                                      if (i >= 0 && i < tamanoListSalsas) {
                                        /* Eliminamos los indices posteriores al actual 
                              que no se iinicializaron */
                                        comanda.value[indexComanda.value].salsas
                                            .removeAt(i);
                                      }
                                    }
                                  }

                                  //Navega a PrintPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => const PrintPage()),
                                    ),
                                  );
                                },
                                child: const Text("Siguiente"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
