import 'package:flutter/material.dart';

class ButtonAdicion extends StatefulWidget {
  final String title;
  final TextEditingController controller;

  const ButtonAdicion({Key? key, required this.title, required this.controller})
      : super(key: key);

  @override
  _ButtonAdicionState createState() => _ButtonAdicionState();
}

class _ButtonAdicionState extends State<ButtonAdicion> {
  int _counter = 0;

  void increment() {
    setState(() {
      _counter++; // Incrementar el contador
      widget.controller.text =
          '$_counter'; // Actualizar el valor del campo de texto
    });
  }

  //Solo decrementar si el contador es mayor que 0counter--; // Decrementar el contador
  void decrement() {
    setState(() {
      if (_counter >= 1) {
        _counter--;
        widget.controller.text =
            '$_counter'; // Actualizar el valor del campo de texto
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.amberAccent,
      elevation: 0,
      color: const Color.fromARGB(115, 43, 41, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                widget.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: Colors.redAccent,
                    iconSize: 18,
                    constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                    padding: EdgeInsets.zero,
                    splashRadius: 16,
                    icon: const Icon(Icons.remove),
                    onPressed: decrement,
                  ),
                  Container(
                    width: 28,
                    alignment: Alignment.center,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      controller: widget.controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    color: Colors.greenAccent,
                    iconSize: 18,
                    constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                    padding: EdgeInsets.zero,
                    splashRadius: 16,
                    icon: const Icon(Icons.add),
                    onPressed: increment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
