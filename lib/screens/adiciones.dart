import 'package:mr_croc/models/model_additions.dart';
import 'package:mr_croc/models/model_widget_adicion.dart';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:mr_croc/screens/confrim.dart';
import 'package:mr_croc/screens/salsas.dart';
import 'package:mr_croc/widgets/buttonAdicion.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Adiciones extends StatefulWidget {
  const Adiciones({Key? key}) : super(key: key);

  @override
  AdicionesState createState() => AdicionesState();
}

class AdicionesState extends State<Adiciones> {
  final List<WidgetAdicion> _adiciones = [];

  @override
  void initState() {
    super.initState();

    for (AdditionModel adicionActual in additionsList.value) {
      _adiciones.add(
        WidgetAdicion(adicionActual, TextEditingController()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navegar hacia atrÃ¡s manualmente
            Navigator.pop(context);
          },
        ),
        title: const Text("Adiciones",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
      ),
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          int itemCount;
          double childAspectRatio;

          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            itemCount = 5;
            childAspectRatio = 1.2;
          } else if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            itemCount = 4;
            childAspectRatio = 1.1;
          } else {
            itemCount = 3;
            childAspectRatio = 1.0;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: GridView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    shrinkWrap: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: itemCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _adiciones.length,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 64),
                          child: ButtonAdicion(
                            title: _adiciones[index].adicion.name,
                            controller: _adiciones[index].controller,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      style: const ButtonStyle(),
                      onPressed: _save,
                      child: const Text("Siguiente"),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _save() {
    String txtCant = '';
    List<Map<AdditionModel, int>> adicionesSelected = [];

    //Obtenemos las adiciones
    for (var data in _adiciones) {
      txtCant = data.controller.text;
      //Si se seleciono una adicion la agrega a una lista con su cantidad
      if (txtCant != '' && txtCant != '0') {
        adicionesSelected.add({
          data.adicion: int.parse(
            txtCant,
          ),
        });
      }
    }

    //Agregamos la lista de adiciones a la comanda
    int tamano = comanda.value[indexComanda.value].adiciones.length;

    int index = indexSalsas.value;

    //si el indice se ha inicializado
    if (index >= 0 && index < tamano) {
      comanda.value[indexComanda.value].adiciones[indexSalsas.value] =
          adicionesSelected;
    } else {
      comanda.value[indexComanda.value].adiciones.add(adicionesSelected);
    }

    //Recorre las salsas para cada producto
    if (comanda.value[indexComanda.value].cantidad == indexSalsas.value + 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => const PrintPage()),
        ),
      );
    } else {
      indexSalsas.value++;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => const Salsas()),
        ),
      );
    }
  }
}
