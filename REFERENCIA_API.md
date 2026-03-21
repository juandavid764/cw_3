# 📚 Referencia de API - MR CROC

## Tabla de Contenidos

1. [Modelos](#modelos)
2. [Funciones de Base de Datos](#funciones-de-base-de-datos)
3. [Provider/Estado](#providerestado)
4. [Servicios](#servicios)
5. [Widgets Personalizados](#widgets-personalizados)
6. [Utilidades](#utilidades)

---

## Modelos

### ProductModel

**Ubicación:** `lib/models/model_product.dart`

Representa un producto del menú del restaurante.

#### Propiedades

```dart
class ProductModel {
  final int id;           // ID único del producto
  final String name;      // Nombre del producto
  final int price;        // Precio en centavos (e.g., 5999 = $59.99)
  final int category;     // ID de la categoría a la que pertenece
  final int salsas;       // Número de salsas disponibles para este producto
  final String text;      // Descripción del producto
}
```

#### Métodos

| Método | Descripción | Parámetros | Retorna |
|--------|-------------|-----------|---------|
| `fromMap(map)` | Factory para crear desde Map | `Map<String, Object?>` | `ProductModel` |
| `isChild(idCategory)` | Verifica si pertenece a categoría | `int idCategory` | `bool` |

#### Ejemplo de Uso

```dart
// Crear desde map (típicamente de BD)
final Map<String, Object?> productData = {
  'product_id': 1,
  'name': 'Hamburguesa',
  'price': 4999,
  'category': 5,
  'additives': 3,
  'text': 'Hamburguesa clásica'
};

ProductModel product = ProductModel.fromMap(productData);

// Verificar categoría
if (product.isChild(5)) {
  print('Pertenece a categoría 5');
}
```

---

### CategoryModel

**Ubicación:** `lib/models/model_category.dart`

Representa una categoría de productos (con soporte para subcategorías).

#### Propiedades

```dart
class CategoryModel {
  final int id;           // ID único de la categoría
  final String name;      // Nombre de la categoría
  final int? parent;      // ID de la categoría padre (null si es raíz)
}
```

#### Métodos

| Método | Descripción | Parámetros | Retorna |
|--------|-------------|-----------|---------|
| `fromMap(map)` | Factory para crear desde Map | `Map<String, Object?>` | `CategoryModel` |
| `isChild(idCategory)` | Verifica si es subcategoría de | `int idCategory` | `bool` |

#### Ejemplo de Uso

```dart
// Categoría raíz
CategoryModel entradas = CategoryModel(
  id: 1,
  name: 'Entradas',
  parent: null,
);

// Subcategoría
CategoryModel sopas = CategoryModel(
  id: 2,
  name: 'Sopas',
  parent: 1, // Padre: Entradas
);

// Verificar jerarquía
if (sopas.isChild(1)) {
  print('Sopa es subcategoría de Entradas');
}
```

---

### AdditionModel

**Ubicación:** `lib/models/model_additions.dart`

Representa un adicional/topping para productos.

#### Propiedades

```dart
class AdditionModel {
  final int id;           // ID único del adicional
  final String name;      // Nombre del adicional (e.g., "Queso Extra")
  final int price;        // Precio adicional en centavos
}
```

#### Métodos

| Método | Descripción | Parámetros | Retorna |
|--------|-------------|-----------|---------|
| `fromMap(map)` | Factory para crear desde Map | `Map<String, Object?>` | `AdditionModel` |

#### Ejemplo de Uso

```dart
final quesExtra = AdditionModel(
  id: 1,
  name: 'Queso Extra',
  price: 500, // $5.00
);

// Desde BD
final addition = AdditionModel.fromMap({
  'addition_id': 1,
  'name': 'Queso Extra',
  'price': 500,
});
```

---

### Order

**Ubicación:** `lib/models/model_order.dart`

Representa un pedido individual con toda su información.

#### Propiedades

```dart
class Order {
  final ProductModel product;                    // Producto pedido
  final int cantidad;                            // Cantidad de unidades
  List<List<Map<AdditionModel, int>>> adiciones; // Adicionales con cantidades
  List<String> salsas;                          // Salsas seleccionadas
}
```

#### Ejemplo de Uso

```dart
// Crear pedido
final order = Order(
  product: hamburguesa,
  cantidad: 2,
  adiciones: [
    [
      {quesExtra: 1, cebollaExtra: 1},
    ]
  ],
  salsas: ['Ketchup', 'Mostaza'],
);

// Acceder a información
print('Producto: ${order.product.name}');
print('Cantidad: ${order.cantidad}');
print('Salsas: ${order.salsas.join(', ')}');
```

---

### SaleProductsModel

**Ubicación:** `lib/models/model_sale_product.dart`

Representa un producto vendido (línea de venta).

#### Propiedades

```dart
class SaleProductsModel {
  final String name;      // Nombre del producto vendido
  final int quantity;     // Cantidad vendida
}
```

#### Métodos

| Método | Descripción | Parámetros | Retorna |
|--------|-------------|-----------|---------|
| `fromMap(map)` | Factory para crear desde Map | `Map<String, Object?>` | `SaleProductsModel` |

---

### Item

**Ubicación:** `lib/models/model_item.dart`

Modelo para items expandibles en listas.

#### Propiedades

```dart
class Item {
  String expandedValue;   // Contenido cuando está expandido
  String headerValue;     // Texto del encabezado
  bool isExpanded;        // Estado expandido/colapsado
}
```

---

## Funciones de Base de Datos

### Ubicación

`lib/database/db_functions.dart`

### Variables Globales

#### Database Instance

```dart
late Database _db;

// Acceso seguro mediante getter
Database get database => _db;
```

**Tipo:** `late Database`  
**Descripción:** Instancia única de la base de datos SQLite. Se inicializa en `main()`.

#### Constantes de Sincronización

```dart
const int syncStatusPending = 0;  // Cambios pendientes de sincronizar
const int syncStatusSynced = 1;   // Cambios sincronizados
```

### Funciones Auxiliares Privadas

#### _twoDigits

```dart
String _twoDigits(int value) => value.toString().padLeft(2, '0');
```

**Descripción:** Formatea un número a dos dígitos con cero a la izquierda.

**Parámetros:**
- `value` (int): Número a formatear

**Retorna:** String con formato

**Ejemplo:**
```dart
_twoDigits(5)   // "05"
_twoDigits(15)  // "15"
```

---

#### _nowUtcString

```dart
String _nowUtcString() {
  final now = DateTime.now().toUtc();
  final year = now.year.toString().padLeft(4, '0');
  return '$year-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
      '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
}
```

**Descripción:** Obtiene timestamp UTC actual en formato ISO.

**Retorna:** String con formato "YYYY-MM-DD HH:mm:ss"

**Ejemplo:**
```dart
_nowUtcString() // "2026-03-21 14:30:45"
```

---

#### _generateUuid

```dart
String _generateUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  final buffer = StringBuffer();
  for (final value in bytes) {
    buffer.write(value.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
```

**Descripción:** Genera un UUID v4 seguro aleatoriamente.

**Retorna:** String con UUID de 32 caracteres hexadecimales

**Ejemplo:**
```dart
_generateUuid() // "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
```

---

#### _ensureSyncSchema

```dart
Future<void> _ensureSyncSchema() async
```

**Descripción:** Verifica y crea todas las tablas necesarias para sincronización.

**Tablas creadas:**
- `sync_meta` - Metadatos de sincronización
- `sync_outbox` - Cola de cambios a sincronizar
- Columnas UUID, created_at, updated_at en tablas existentes

**Ejemplo:**
```dart
await _ensureSyncSchema();
// Ahora todas las tablas están listas para sincronización
```

---

#### _ensureSyncColumns

```dart
Future<void> _ensureSyncColumns(String table) async
```

**Descripción:** Verifica y agrega columnas de sincronización a una tabla.

**Parámetros:**
- `table` (String): Nombre de la tabla

**Columnas agregadas si faltan:**
- `uuid TEXT` - Identificador único
- `created_at TEXT` - Timestamp de creación
- `updated_at TEXT` - Timestamp de actualización

---

## Provider/Estado

### Ubicación

`lib/provider/provider_notifier.dart`

### ValueNotifiers Globales

Estas variables son `ValueNotifier` que permiten reactividad sin dependencias adicionales.

#### productList

```dart
ValueNotifier<List<ProductModel>> productList = ValueNotifier([]);
```

**Descripción:** Lista de todos los productos del catálogo.

**Tipo:** `List<ProductModel>`

**Acceso:**
```dart
productList.value         // Obtener lista actual
productList.value = newList  // Actualizar lista
productList.addListener(() {});  // Escuchar cambios
```

---

#### categorytList

```dart
ValueNotifier<List<CategoryModel>> categorytList = ValueNotifier([]);
```

**Descripción:** Lista de todas las categorías.

**Tipo:** `List<CategoryModel>`

> **Nota:** El nombre tiene un typo ("categor**y**tList" en lugar de "categoryList"), pero se mantiene por compatibilidad.

---

#### rootsCategories

```dart
ValueNotifier<List<CategoryModel>> rootsCategories = ValueNotifier([]);
```

**Descripción:** Categorías raíz (sin padre), típicamente para menú principal.

**Tipo:** `List<CategoryModel>`

---

#### additionsList

```dart
ValueNotifier<List<AdditionModel>> additionsList = ValueNotifier([]);
```

**Descripción:** Lista de todos los adicionales disponibles.

**Tipo:** `List<AdditionModel>`

---

#### comanda

```dart
ValueNotifier<List<Order>> comanda = ValueNotifier([]);
```

**Descripción:** Comanda actual (pedidos pendientes de confirmar).

**Tipo:** `List<Order>`

**Ejemplo:**
```dart
// Agregar pedido a comanda
comanda.value = [...comanda.value, newOrder];

// Obtener comanda actual
final currentOrders = comanda.value;

// Escuchar cambios
comanda.addListener(() {
  print('Comanda actualizada: ${comanda.value.length} items');
});
```

---

#### indexComanda

```dart
ValueNotifier<int> indexComanda = ValueNotifier<int>(0);
```

**Descripción:** Índice del pedido actualmente seleccionado en la comanda.

**Tipo:** `int`

---

#### indexSalsas

```dart
ValueNotifier<int> indexSalsas = ValueNotifier<int>(0);
```

**Descripción:** Índice de salsa actualmente seleccionada.

**Tipo:** `int`

---

#### idFechaNow

```dart
ValueNotifier<int> idFechaNow = ValueNotifier<int>(0);
```

**Descripción:** ID de fecha actual para agrupar ventas por día.

**Tipo:** `int`

---

#### pdtStadictsList

```dart
ValueNotifier<Map<String, double>> pdtStadictsList = 
    ValueNotifier({'Sin ventas': 0});
```

**Descripción:** Estadísticas de productos vendidos (para gráficos).

**Tipo:** `Map<String, double>` - Mapa de nombre de producto a cantidad vendida

**Ejemplo:**
```dart
// Actualizar estadísticas
pdtStadictsList.value = {
  'Hamburguesa': 15.0,
  'Hot Dog': 8.0,
  'Pizza': 12.0,
};
```

---

## Servicios

### SyncService

**Ubicación:** `lib/services/sync_service.dart`

Maneja la sincronización bidireccional con Supabase.

#### Constructor

```dart
SyncService({
  required SupabaseClient client,  // Cliente de Supabase
  required Database database,      // Instancia de BD local
})
```

#### Métodos Principales

##### syncAll()

```dart
Future<SyncReport> syncAll() async
```

**Descripción:** Sincroniza todos los datos con Supabase.

**Flujo:**
1. Conectar a Supabase
2. PULL cambios remotos
3. Fusionar datos
4. PUSH cambios locales
5. Generar reporte

**Retorna:** `SyncReport` con información de la sincronización

**Propiedades de SyncReport:**
- `pushed` (int) - Cambios enviados
- `pulled` (int) - Cambios recibidos
- `errors` (List) - Errores ocurridos

**Ejemplo:**
```dart
final client = Supabase.instance.client;
final service = SyncService(
  client: client,
  database: database,
);

try {
  final report = await service.syncAll();
  print('Sync completo: ${report.pushed} enviados, ${report.pulled} recibidos');
  
  if (report.errors.isNotEmpty) {
    print('Errores: ${report.errors}');
  }
} catch (e) {
  print('Error de sincronización: $e');
}
```

---

## Widgets Personalizados

### Ubicación

`lib/widgets/`

### ButtonAdicion

**Archivo:** `buttonAdicion.dart`

Widget personalizado para seleccionar adicionales.

**Propiedades típicas:**
- Label de adicional
- Precio
- Cantidad seleccionada
- Callback al seleccionar

---

### ChartPie

**Archivo:** `chartPie.dart`

Gráfico de pastel para mostrar estadísticas.

**Visualización:**
- Distribución de productos vendidos
- Porcentajes de cada producto
- Colores diferenciados

---

## Utilidades

### Funciones de Inicialización (main.dart)

#### initializeDatabase()

```dart
Future<void> initializeDatabase() async
```

Inicializa la base de datos SQLite local.

---

#### _initSupabase()

```dart
Future<void> _initSupabase() async
```

Inicializa conexión a Supabase si hay credenciales disponibles.

---

#### getRoots()

```dart
Future<void> getRoots() async
```

Carga categorías raíz en `rootsCategories`.

---

#### gerDateNow()

```dart
Future<void> gerDateNow() async
```

Obtiene fecha actual y establece `idFechaNow`.

> **Nota:** Método tiene typo en nombre ("ger" en lugar de "get").

---

#### getcategoriesdata()

```dart
Future<void> getcategoriesdata() async
```

Carga todas las categorías en `categorytList`.

---

#### getproductsdata()

```dart
Future<void> getproductsdata() async
```

Carga todos los productos en `productList`.

---

#### getAdditionesData()

```dart
Future<void> getAdditionesData() async
```

Carga todos los adicionales en `additionsList`.

---

## Constantes de Tema

### darkTheme

**Ubicación:** `lib/main.dart`

```dart
final ThemeData darkTheme = ThemeData(
  colorSchemeSeed: Color(255, 230, 0),    // Amarillo
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  ...
)
```

**Colores:**
- Primario: Amarillo (#FFE600)
- Secundario: Amarillo oscuro (#C5C500)
- Fondo: Oscuro
- Texto: Blanco/Negro según contraste

**TextThemes:**
- `bodyLarge` - Bootstrap bold
- `bodyMedium` - Bootstrap bold negro
- `bodySmall` - Texto regular negro

**ButtonThemes:**
- Color de fondo: Amarillo
- Color de overlay: Ámbar acerado

---

## Rutas de Navegación

### main.dart Routes

```dart
routes: {
  '/home': (context) => const HomeScreeen(),
}
```

**Rutas disponibles:**
- `/home` - Pantalla principal (HomeScreen)

**Inicialización:**
```dart
initialRoute: '/home'
```

---

## Patrones de Uso Comúnes

### Acceder a Estado Global

```dart
// Escuchar cambios
ValueListenableBuilder<List<ProductModel>>(
  valueListenable: productList,
  builder: (context, products, _) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  },
)
```

### Actualizar Estado

```dart
// Agregar producto
productList.value = [...productList.value, newProduct];

// Reemplazar lista
productList.value = newProductList;

// Actualizar elemento específico
final updated = [...productList.value];
updated[index] = modifiedProduct;
productList.value = updated;
```

### Sincronizar Datos

```dart
final service = SyncService(
  client: Supabase.instance.client,
  database: database,
);

final report = await service.syncAll();
if (report.errors.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Sync exitoso: ${report.pushed} enviados')),
  );
}
```

---

## Variables de Entorno

### SUPABASE_URL

URL del proyecto Supabase.

```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
```

---

### SUPABASE_ANON_KEY

Clave anónima de Supabase para acceso público.

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=xyz...
```

---

## Mejores Prácticas

### 1. Manejo de ValueNotifier

```dart
// ✅ Correcto: Crear nueva lista para disparar listeners
productList.value = [...productList.value, new Product];

// ❌ Incorrecto: Modificar la lista existente
productList.value.add(newProduct);  // No dispara listener
```

### 2. Sincronización

```dart
// ✅ Correcto: Sincronizar en segundo plano
Future<void> _syncInBackground() async {
  try {
    final report = await _syncService.syncAll();
    // Actualizar UI con reporte
  } catch (e) {
    // Manejar error
  }
}

// Llamar desde UI sin bloquear
_syncInBackground();
```

### 3. Conversión de Modelos

```dart
// ✅ Correcto: Usar fromMap
final product = ProductModel.fromMap(data);

// ❌ Incorrecto: Acceso directo sin type safety
final product = ProductModel(
  id: data['product_id'],  // Falta casting
  // ...
);
```

---

**Última actualización:** 21 de Marzo de 2026

