import 'package:mr_croc/models/model_additions.dart';
import 'package:mr_croc/models/model_category.dart';
import 'package:mr_croc/models/model_order.dart';
import 'package:mr_croc/models/model_product.dart';
import 'package:mr_croc/models/model_salsa.dart';
import 'package:flutter/material.dart';

ValueNotifier<List<ProductModel>> productList = ValueNotifier([]);
ValueNotifier<List<CategoryModel>> categorytList = ValueNotifier([]);
ValueNotifier<List<CategoryModel>> rootsCategories = ValueNotifier([]);
ValueNotifier<List<AdditionModel>> additionsList = ValueNotifier([]);
ValueNotifier<List<SalsaModel>> salsasList = ValueNotifier([]);
ValueNotifier<List<Order>> comanda = ValueNotifier([]);
ValueNotifier<int> indexComanda = ValueNotifier<int>(0);
ValueNotifier<int> indexSalsas = ValueNotifier<int>(0);
ValueNotifier<int> idFechaNow = ValueNotifier<int>(0);

ValueNotifier<Map<String, double>> pdtStadictsList =
    ValueNotifier({'Sin ventas': 0});
