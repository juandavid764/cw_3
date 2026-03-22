import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/models/model_category.dart';
import 'package:mr_croc/models/model_product.dart';
import 'package:mr_croc/provider/provider_notifier.dart';
import 'package:flutter/material.dart';

class UpdateProduct extends StatefulWidget {
  final ProductModel product;

  const UpdateProduct({super.key, required this.product});

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  String? updatedImagepath;

  final _formKey = GlobalKey<FormState>(); //  form key for the validation

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _textController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedSalsas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Producto'),
        actions: [
          IconButton(
            onPressed: () {
              editProductClicked(
                context,
                widget.product,
              );
            },
            icon: const Icon(Icons.cloud_upload),
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey, // Assign the form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // Name input field with validation
                  Row(
                    children: [
                      const Icon(Icons.abc_outlined),
                      const SizedBox(
                          width: 10), // Add spacing between icon and text field
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Nombre",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Porfavor digita un Nombre';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Class input field with validation
                  Row(
                    children: [
                      const Icon(Icons.price_change_rounded),
                      const SizedBox(
                          width: 10), // Add spacing between icon and text field
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: "Precio",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Porfavor digite un Precio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Categoria con dropdown en base a las categorias existentes
                  Row(
                    children: [
                      const Icon(Icons.group_work_sharp),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ValueListenableBuilder<List<CategoryModel>>(
                          valueListenable: categorytList,
                          builder: (context, categories, _) {
                            return DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: "Categoria",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
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
                                  return 'Porfavor selecciona una Categoria';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Salsas y Adiciones con dropdown (0 o 1)
                  Row(
                    children: [
                      const Icon(Icons.select_all_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedSalsas,
                          decoration: InputDecoration(
                            labelText: "Salsas y Adiciones",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.short_text_sharp),
                      const SizedBox(
                          width: 10), // Add spacing between icon and text field
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          controller: _textController,
                          decoration: InputDecoration(
                            labelText: "Texto",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Porfavor digite un texto';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _selectedCategoryId = widget.product.category;
    _selectedSalsas = widget.product.salsas;
    _textController.text = widget.product.text;
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> editProductClicked(
      BuildContext context, ProductModel product) async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = _priceController.text;
      final category = _selectedCategoryId;
      final salsas = _selectedSalsas;
      final texto = _textController.text;

      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una categoria')),
        );
        return;
      }
      if (salsas == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona si lleva salsas y adiciones')),
        );
        return;
      }

      final updatedStudent = ProductModel(
        id: product.id,
        name: name,
        price: int.parse(price),
        category: category,
        salsas: salsas,
        text: texto,
      );

      await editproduct(
        product.id,
        updatedStudent.name,
        updatedStudent.price,
        updatedStudent.category,
        updatedStudent.salsas,
        updatedStudent.text,
      );

      // Refresh the data in the StudentList widget.
      Navigator.of(context).pop();
    }
  }
}
