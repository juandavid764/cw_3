//import 'package:mr_croc/screens/settingsScreen.dart';
import 'package:mr_croc/screens/crud-db/edit_page.dart';
import 'package:mr_croc/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:mr_croc/database/db_functions.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final String _correctPassword = '1234'; // ContraseÃ±a predefinida
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingrese la contraseÃ±a'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreeen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'ContraseÃ±a',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text == _correctPassword) {
                    getproductsdata();
                    // ContraseÃ±a correcta, navegar a otra pÃ¡gina
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditPage()),
                    );
                  } else {
                    // ContraseÃ±a incorrecta, mostrar mensaje de error
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('ContraseÃ±a incorrecta.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                  child: Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
