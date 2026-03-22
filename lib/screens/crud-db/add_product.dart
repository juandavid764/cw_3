import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/models/model_category.dart';
import 'package:mr_croc/models/model_product.dart';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  //Llave para acceder al estado del formulario
  final _formKey = GlobalKey<FormState>(); // Add a form key for the validation

  //Crea los txtfields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _textoController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedSalsas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        actions: [
          //Boton Guardar
          IconButton(
            onPressed: () {
              buttonSave(context);
            },
            icon: const Icon(Icons.save_rounded),
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          //Inicio Formulario
          child: Form(
            key: _formKey, // The form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Name input field with validation
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(Icons.abc_outlined),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Porfavor digita un Nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Class input field with validation
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "Precio",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(Icons.price_change_rounded),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Porfavor digite un Precio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Categoria con dropdown en base a las categorias existentes
                ValueListenableBuilder<List<CategoryModel>>(
                  valueListenable: categorytList,
                  builder: (context, categories, _) {
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: const Icon(Icons.group_work_sharp),
                      ),
                      items: categories.isEmpty
                          ? [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('No hay categorias'),
                              )
                            ]
                          : categories
                              .map(
                                (cat) => DropdownMenuItem<int>(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una Categoria';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Salsas y Adiciones con dropdown (0 o 1)
                DropdownButtonFormField<int>(
                  value: _selectedSalsas,
                  decoration: InputDecoration(
                    labelText: "Salsas y Adiciones",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(Icons.select_all_rounded),
                  ),
                  items: const [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('0 - No lleva'),
                    ),
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('1 - Lleva adiciones'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSalsas = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please enter a bolean data';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: _textoController,
                  decoration: InputDecoration(
                    labelText: "Texto",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(Icons.short_text_sharp),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Porfavor digite un texto';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> buttonSave(mtx) async {
    //Verifica todos los 'validator' de los 'TextFormField' y la foto
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = _priceController.text;
      final category = _selectedCategoryId;
      final salsas = _selectedSalsas;
      final texto = _textoController.text;

      if (category == null) {
        ScaffoldMessenger.of(mtx).showSnackBar(
          const SnackBar(content: Text('Selecciona una categoria')),
        );
        return;
      }
      if (salsas == null) {
        ScaffoldMessenger.of(mtx).showSnackBar(
          const SnackBar(content: Text('Selecciona si lleva salsas y adiciones')),
        );
        return;
      }

      //crea un estudiante con los datos de los TextFormFields
      final pdtData = ProductModel(
        id: 1,
        name: name,
        price: int.parse(price),
        category: category,
        salsas: salsas,
        text: texto,
      );
      await addproduct(pdtData); // Use the correct function name addStudent.

      //Mensaje de inserccion exitosa
      ScaffoldMessenger.of(mtx).showSnackBar(
        const SnackBar(
          content: Text("Isercion Exitosa"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );

      //Vaciar txtfields
      setState(() {
        _nameController.clear();
        _priceController.clear();
        _selectedCategoryId = null;
        _selectedSalsas = null;
        _textoController.clear();
      });
    }
  }
}
