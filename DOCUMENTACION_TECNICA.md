# 📋 Documentación Técnica - MR CROC

## Resumen Ejecutivo

**MR CROC** es una aplicación móvil multiplataforma desarrollada en **Flutter** diseñada para gestionar pedidos en un restaurante. La aplicación permite a los meseros o personal de cocina registrar, modificar y confirmar pedidos de clientes, con características avanzadas como adicionales personalizables, salsas, categorización de productos y sincronización en tiempo real con una base de datos en la nube.

**Versión:** 1.0.0  
**Plataformas soportadas:** Android, iOS, Web, Windows, macOS, Linux  
**Estado:** En desarrollo

---

## 1. Requisitos Técnicos

### 1.1 Dependencias Principales

#### Framework y Base de Datos
- **Flutter:** 3.7.2 o superior
- **Dart:** 3.7.2 o superior
- **SQLite:** Base de datos local (sqflite: ^2.3.0)
- **Supabase:** Sincronización en la nube (supabase_flutter: ^2.8.0)

#### Librerías de UI
- **responsive_builder:** ^0.4.0 - Diseño responsive
- **cupertino_icons:** ^1.0.2 - Iconos iOS style
- **intl:** ^0.19.0 - Internacionalización y fechas
- **calendar_date_picker2:** ^0.5.5 - Selector de fechas
- **pie_chart:** ^5.4.0 - Gráficos de pastel

#### Impresión y Utilidades
- **esc_pos_printer_plus:** ^0.1.1 - Impresión térmica
- **esc_pos_utils_plus:** ^2.0.4 - Utilidades de impresión
- **path_provider:** ^2.1.1 - Acceso a directorios
- **path:** ^1.8.3 - Manipulación de rutas

#### Generación de Iconos
- **icons_launcher:** ^2.0.7 - Generación automática de iconos

### 1.2 Configuración de Entorno

Las credenciales de Supabase se definen mediante variables de entorno:
```dart
const String supabaseUrl = 
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String supabaseAnonKey = 
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
```

---

## 2. Arquitectura General

### 2.1 Patrón Arquitectónico

La aplicación implementa una arquitectura de **capas**:

```
┌─────────────────────────────────────┐
│         Capa de Presentación        │
│          (Screens & Widgets)        │
├─────────────────────────────────────┤
│         Capa de Estado (Provider)   │
│       (ValueNotifiers & Datos)      │
├─────────────────────────────────────┤
│      Capa de Lógica de Negocio      │
│     (Servicios, Operaciones CRUD)   │
├─────────────────────────────────────┤
│      Capa de Persistencia de Datos  │
│    (SQLite Local + Supabase Cloud)  │
└─────────────────────────────────────┘
```

### 2.2 Flujo de Datos

1. **Interfaz de Usuario → Presentación:** El usuario interactúa con pantallas
2. **Presentación → Estado:** Se actualiza el estado mediante ValueNotifiers
3. **Estado → Servicios:** La lógica realiza operaciones en BD local o cloud
4. **Servicios → Sincronización:** Los cambios se sincronizan con Supabase

---

## 3. Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── database/
│   └── db_functions.dart             # Funciones de inicialización y gestión de BD
├── models/                            # Modelos de datos
│   ├── model_additions.dart          # Modelo para adicionales
│   ├── model_category.dart           # Modelo de categorías
│   ├── model_item.dart               # Modelo de items expandibles
│   ├── model_order.dart              # Modelo de pedidos
│   ├── model_product.dart            # Modelo de productos
│   ├── model_sale_product.dart       # Modelo de productos vendidos
│   ├── model_salsa.dart              # Modelo de salsas
│   └── model_widget_adicion.dart     # Modelo para widgets de adicionales
├── provider/
│   └── provider_notifier.dart        # Estado global de la aplicación
├── screens/                           # Pantallas principales
│   ├── homescreen.dart               # Pantalla principal
│   ├── adiciones.dart                # Pantalla de adicionales
│   ├── big_order.dart                # Pantalla de pedidos grandes
│   ├── confrim.dart                  # Pantalla de confirmación
│   ├── salsas.dart                   # Pantalla de salsas
│   ├── nodes.dart                    # Navegación entre nodos
│   ├── navigation.dart               # Manejo de navegación
│   └── crud-db/                      # Operaciones CRUD en BD
│       └── password_page.dart        # Página de settings (protegida)
├── services/
│   └── sync_service.dart             # Sincronización con Supabase
└── widgets/                           # Componentes reutilizables
    ├── buttonAdicion.dart            # Botón de adicionales
    └── chartPie.dart                 # Gráfico de pastel

assets/
├── cw_database.db                    # Base de datos SQLite embebida
├── icon/
│   └── app_icon.png                  # Icono de la aplicación
└── Screenshots/                      # Capturas de pantalla

android/                              # Configuración Android
ios/                                  # Configuración iOS
windows/                              # Soporte para Windows
macos/                                # Soporte para macOS
linux/                                # Soporte para Linux
web/                                  # Soporte para Web
```

---

## 4. Modelos de Datos

### 4.1 Modelo de Producto (ProductModel)

**Archivo:** [lib/models/model_product.dart](lib/models/model_product.dart)

```dart
class ProductModel {
  final int id;              // ID único del producto
  final String name;         // Nombre del producto
  final int price;          // Precio en centavos
  final int category;       // ID de categoría
  final int salsas;         // Cantidad de salsas disponibles
  final String text;        // Descripción del producto
}
```

**Funcionalidades:**
- Conversión desde Map: `ProductModel.fromMap()`
- Verificación de categoría: `isChild(idCategory)`

---

### 4.2 Modelo de Categoría (CategoryModel)

**Archivo:** [lib/models/model_category.dart](lib/models/model_category.dart)

```dart
class CategoryModel {
  final int id;              // ID único
  final String name;         // Nombre de la categoría
  final int? parent;         // ID de categoría padre (para subcategorías)
}
```

**Funcionalidades:**
- Soporta jerarquía (subcategorías)
- Método `isChild(idCategory)` para detectar relaciones

---

### 4.3 Modelo de Adicionales (AdditionModel)

**Archivo:** [lib/models/model_additions.dart](lib/models/model_additions.dart)

```dart
class AdditionModel {
  final int id;              // ID único
  final String name;         // Nombre del adicional
  final int price;          // Precio adicional en centavos
}
```

---

### 4.4 Modelo de Pedido (Order)

**Archivo:** [lib/models/model_order.dart](lib/models/model_order.dart)

```dart
class Order {
  final ProductModel product;              // Producto pedido
  final int cantidad;                      // Cantidad pedida
  List<List<Map<AdditionModel, int>>> adiciones;  // Adicionales seleccionados
  List<String> salsas;                    // Salsas seleccionadas
}
```

---

### 4.5 Otros Modelos

| Modelo | Archivo | Descripción |
|--------|---------|-------------|
| **SaleProductsModel** | model_sale_product.dart | Productos vendidos con cantidad |
| **Item** | model_item.dart | Items expandibles para listas |

---

## 5. Gestión de Estado

### 5.1 Provider Notifier

**Archivo:** [lib/provider/provider_notifier.dart](lib/provider/provider_notifier.dart)

La aplicación utiliza `ValueNotifier` para gestión de estado reactivo:

```dart
// Datos de catálogo
ValueNotifier<List<ProductModel>> productList;
ValueNotifier<List<CategoryModel>> categorytList;
ValueNotifier<List<CategoryModel>> rootsCategories;
ValueNotifier<List<AdditionModel>> additionsList;

// Control de pedidos
ValueNotifier<List<Order>> comanda;
ValueNotifier<int> indexComanda;
ValueNotifier<int> indexSalsas;

// Datos temporales
ValueNotifier<int> idFechaNow;
ValueNotifier<Map<String, double>> pdtStadictsList;
```

**Ventajas:**
- ✅ Estado reactivo simple
- ✅ Bajo overhead de rendimiento
- ✅ Fácil de depurar
- ✅ No requiere dependencias adicionales

---

## 6. Base de Datos

### 6.1 Inicialización

**Archivo:** [lib/database/db_functions.dart](lib/database/db_functions.dart)

En `main()` se inicializa la BD en este orden:
```dart
await initializeDatabase();      // Crea/abre la BD SQLite
await _initSupabase();           // Conecta a Supabase (si credenciales existen)
await getRoots();                // Carga categorías raíz
await gerDateNow();              // Obtiene fecha actual
await getcategoriesdata();       // Carga todas las categorías
await getproductsdata();         // Carga todos los productos
await getAdditionesData();       // Carga todos los adicionales
```

### 6.2 Estructura de Tablas

#### Tabla: products
```sql
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  name TEXT,
  price INTEGER,
  category INTEGER,
  additives INTEGER,
  text TEXT,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

#### Tabla: categories
```sql
CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY,
  category_name TEXT,
  parentCategory INTEGER,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

#### Tabla: additions
```sql
CREATE TABLE additions (
  addition_id INTEGER PRIMARY KEY,
  name TEXT,
  price INTEGER,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

#### Tabla: sales
```sql
CREATE TABLE sales (
  id INTEGER PRIMARY KEY,
  date TEXT,
  total INTEGER,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

#### Tabla: details_sale_product
```sql
CREATE TABLE details_sale_product (
  id INTEGER PRIMARY KEY,
  sale_id INTEGER,
  text TEXT,
  ventaProducto INTEGER,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

#### Tabla: dates
```sql
CREATE TABLE dates (
  date_id INTEGER PRIMARY KEY,
  date TEXT,
  uuid TEXT UNIQUE,
  created_at TEXT,
  updated_at TEXT
)
```

### 6.3 Sistema de Sincronización

#### Tablas de Sincronización

**sync_meta:** Almacena metadatos de sincronización
```sql
CREATE TABLE sync_meta (
  key TEXT PRIMARY KEY,
  value TEXT
)
```

**sync_outbox:** Cola de operaciones pendientes para sincronizar
```sql
CREATE TABLE sync_outbox (
  outbox_id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  row_id INTEGER,
  row_uuid TEXT,
  operation TEXT,       -- 'INSERT', 'UPDATE', 'DELETE'
  payload TEXT,
  created_at TEXT,
  attempt_count INTEGER,
  last_error TEXT
)
```

#### Mecanismo de Sincronización

- **UUID:** Cada registro tiene un identificador único universal
- **Timestamps:** `created_at` y `updated_at` para detectar cambios
- **Outbox Pattern:** Los cambios se registran en `sync_outbox` antes de sincronizar
- **Intentos:** Se reintentan operaciones fallidas (con contador `attempt_count`)

---

## 7. Servicios

### 7.1 SyncService

**Archivo:** [lib/services/sync_service.dart](lib/services/sync_service.dart)

Responsable de la sincronización bidireccional con Supabase.

**Funcionalidades:**
- `syncAll()` - Sincroniza todos los datos
- Manejo de conflictos
- Reporte de progreso (pushed, pulled, errores)
- Reintentos automáticos

**Flujo de Sincronización:**
```
1. Detectar cambios locales (outbox)
2. Enviar cambios a Supabase
3. Recibir cambios remotos
4. Sincronizar estado local
5. Limpiar outbox
6. Generar reporte
```

---

## 8. Pantallas Principales

### 8.1 HomeScreen

**Archivo:** [lib/screens/homescreen.dart](lib/screens/homescreen.dart)

Pantalla principal de la aplicación.

**Componentes:**
- **AppBar:** Con botón de sincronización y settings
- **Body:** Nodos de navegación
- **Funcionalidades:**
  - Sincronización en tiempo real
  - Acceso a configuración (protegida por contraseña)

**States:**
- `_syncNow()` - Inicia sincronización

### 8.2 Screens/Nodes

**Archivo:** [lib/screens/nodes.dart](lib/screens/nodes.dart)

Sistema de navegación jerárquico para categorías.

---

### 8.3 Pantalla de Adicionales

**Archivo:** [lib/screens/adiciones.dart](lib/screens/adiciones.dart)

Permite al usuario seleccionar adicionales para los productos.

**Características:**
- Selección múltiple de adicionales
- Mostrar precio de cada adicional
- Control de cantidad

---

### 8.4 Pantalla de Pedidos

**Archivo:** [lib/screens/big_order.dart](lib/screens/big_order.dart)

Gestión de pedidos completos.

**Funcionalidades:**
- Visualizar comanda
- Modificar cantidades
- Agregar/eliminar productos

---

### 8.5 Pantalla de Confirmación

**Archivo:** [lib/screens/confrim.dart](lib/screens/confrim.dart)

Confirmación final del pedido.

**Acciones:**
- Revisar detalles
- Confirmar venta
- Generar ticket de impresión

---

### 8.6 Salsas

**Archivo:** [lib/screens/salsas.dart](lib/screens/salsas.dart)

Selección de salsas para los productos.

---

### 8.7 CRUD Database

**Carpeta:** [lib/screens/crud-db/](lib/screens/crud-db/)

Operaciones de base de datos protegidas por contraseña.

**Archivo:** password_page.dart
- Validación de contraseña
- Acceso a funciones administrativas

---

## 9. Componentes Reutilizables (Widgets)

### 9.1 ButtonAdicion

**Archivo:** [lib/widgets/buttonAdicion.dart](lib/widgets/buttonAdicion.dart)

Widget botón para seleccionar adicionales.

---

### 9.2 ChartPie

**Archivo:** [lib/widgets/chartPie.dart](lib/widgets/chartPie.dart)

Gráfico de pastel para visualizar estadísticas de ventas.

---

## 10. Tema y Estilos

### 10.1 Tema Oscuro (Dark Theme)

**Definido en:** [lib/main.dart](lib/main.dart) - `darkTheme`

```dart
final ThemeData darkTheme = ThemeData(
  colorSchemeSeed: Color(255, 230, 0),  // Amarillo
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  cardTheme: CardThemeData(
    color: Color(197, 197, 0),          // Amarillo oscuro
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
```

**Paleta de Colores:**
- **Primario:** Amarillo (#FFE600)
- **Secundario:** Amarillo oscuro (#C5C500)
- **Fondo:** Oscuro (Material 3)
- **Texto:** Blanco y Negro según contraste

---

## 11. Flujo de Operaciones Principales

### 11.1 Crear un Nuevo Pedido

```
1. HomeScreen → Nodes (seleccionar categoría)
2. ProductList (seleccionar producto)
3. Adiciones (seleccionar adicionales)
4. Salsas (seleccionar salsas)
5. BigOrder (visualizar comanda)
6. Confirm (confirmar y generar venta)
7. BD Local: INSERT en sales + details_sale_product
8. SyncService: Enviar a Supabase
```

### 11.2 Sincronización de Datos

```
1. Detectar cambios (outbox)
2. Conectar a Supabase
3. PULL: Traer cambios remotos
4. PUSH: Enviar cambios locales
5. Actualizar state (ValueNotifiers)
6. Mostrar reporte
```

---

## 12. Configuración Multiplataforma

### 12.1 Android

**Archivo:** [android/app/build.gradle.kts](android/app/build.gradle.kts)

- Soporte para Android 5.0+
- Permisos de impresión térmica

### 12.2 iOS

**Archivo:** [ios/Runner.xcworkspace/](ios/Runner.xcworkspace/)

- Soporte para iOS 11.0+
- Configuración de entitlements

### 12.3 Web

**Archivo:** [web/index.html](web/index.html)

- PWA compatible
- Manifest.json para instalación

### 12.4 Desktop (Windows, macOS, Linux)

- Soporte con Flutter Desktop
- Acceso a BD local

---

## 13. Ciclo de Vida de la Aplicación

```
main()
   ├─→ initializeDatabase()      [SQLite]
   ├─→ _initSupabase()           [Cloud]
   ├─→ getRoots()                [Cargar categorías raíz]
   ├─→ gerDateNow()              [Obtener fecha actual]
   ├─→ getcategoriesdata()       [Cargar todas las categorías]
   ├─→ getproductsdata()         [Cargar productos]
   ├─→ getAdditionesData()       [Cargar adicionales]
   └─→ runApp(MyApp())
       ├─→ MyApp (Configurar tema)
       └─→ HomeScreen (Pantalla principal)
```

---

## 14. Funciones Utilitarias

**Archivo:** [lib/database/db_functions.dart](lib/database/db_functions.dart)

| Función | Descripción |
|---------|-------------|
| `_twoDigits(int)` | Formatea número a dos dígitos |
| `_nowUtcString()` | Obtiene timestamp UTC actual |
| `_generateUuid()` | Genera UUID único |
| `_ensureSyncSchema()` | Crea tablas de sincronización |
| `_ensureSyncColumns()` | Verifica columnas de sincronización |
| `_fillSyncDefaults()` | Completa valores por defecto |

---

## 15. Constantes Globales

**Archivo:** [lib/database/db_functions.dart](lib/database/db_functions.dart)

```dart
const int syncStatusPending = 0;  // Pendiente de sincronización
const int syncStatusSynced = 1;   // Sincronizado
```

---

## 16. Variables Globales

**Archivo:** [lib/database/db_functions.dart](lib/database/db_functions.dart)

```dart
late Database _db;  // Instancia de BD (inicializada después)
```

Acceso mediante getter:
```dart
Database get database => _db;
```

---

## 17. Configuración de Activos

**pubspec.yaml:**
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/cw_database.db
  
icons_launcher:
  image_path: "assets/icon/app_icon.png"
  platforms:
    android:
      enable: true
    ios:
      enable: true
```

---

## 18. Rutas de Navegación

**Definidas en:** [lib/main.dart](lib/main.dart)

```dart
routes: {
  '/home': (context) => const HomeScreeen(),
}
```

Inicialización:
```dart
initialRoute: '/home'
```

---

## 19. Información de Compilación

### 19.1 Versión del Proyecto

- **nombre:** mr_croc
- **versión:** 1.0.0
- **build:** 1

### 19.2 Requisitos del SDK

```yaml
environment:
  sdk: ^3.7.2
```

---

## 20. Análisis de Código

**Archivo:** [analysis_options.yaml](analysis_options.yaml)

Configuración de lints para garantizar calidad de código.

---

## 21. Patrones y Mejores Prácticas

### 21.1 Conversión de Modelos

```dart
// Patrón factory para mapeo
static ModeloX fromMap(Map<String, Object?> map) {
  return ModeloX(
    id: map['id'] as int,
    name: map['name'] as String,
  );
}
```

### 21.2 Gestión de Estado Reactivo

```dart
// ValueNotifier para actualizaciones reactivas
ValueNotifier<List<ProductModel>> productList = ValueNotifier([]);

// Actualizar estado
productList.value = newProductList;
```

### 21.3 Inicialización Segura

```dart
late Database _db;  // Se inicializa después de crearse

// En main()
await initializeDatabase();
// Ahora _db está disponible seguramente
```

---

## 22. Dependencias de Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## 23. Seguridad

### 23.1 Credenciales de Supabase

Las credenciales se proporcionan mediante variables de entorno:
```bash
flutter run -d <device> \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key>
```

### 23.2 Protección de Funciones Administrativas

- Pantalla CRUD protegida con contraseña
- Acceso limitado a configuración

---

## 24. Rendimiento

### 24.1 Optimizaciones Implementadas

- ✅ **SQLite local:** Caché offline
- ✅ **ValueNotifiers:** Actualizaciones eficientes
- ✅ **Sincronización asincrónica:** No bloquea UI
- ✅ **Outbox Pattern:** Garantiza entrega de cambios

### 24.2 Consideraciones

- Base de datos embebida (cw_database.db) cargada al inicio
- Carga de categorías jerárquicas en memoria
- Sincronización en segundo plano

---

## 25. Mantenimiento y Escalabilidad

### 25.1 Posibles Mejoras Futuras

- [ ] Implementar Provider package para mejor gestión de estado
- [ ] Agregar tests unitarios y de integración
- [ ] Mejorar UI/UX con Material Design 3 avanzado
- [ ] Agregar reportes y analíticas
- [ ] Implementar caché inteligente
- [ ] Agregar notificaciones push
- [ ] Multiusuario con roles

### 25.2 Documenting Changes

- Mantener este archivo actualizado
- Usar versionado semántico
- Crear changelogs

---

## 26. Guía de Desarrollo

### 26.1 Configuración Local

1. Clonar repositorio
2. Ejecutar `flutter pub get`
3. Configurar variables de entorno (Supabase)
4. Ejecutar con `flutter run`

### 26.2 Adición de Nuevas Pantallas

1. Crear archivo en `lib/screens/`
2. Definir ruta en `main.dart`
3. Actualizar navegación en `nodes.dart` o `navigation.dart`

### 26.3 Adición de Nuevos Modelos

1. Crear archivo en `lib/models/`
2. Implementar método `fromMap()`
3. Agregar ValueNotifier en `provider_notifier.dart`
4. Crear tabla en BD si es necesario

---

## 27. Estructura de Commits Recomendada

```
feat: Agregar nueva pantalla de estadísticas
fix: Corregir sincronización de cambios
refactor: Mejorar gestión de estado
docs: Actualizar documentación
style: Ajustar formato de código
test: Agregar tests
```

---

## 28. Referencias y Recursos

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev)
- [SQLite Flutter](https://pub.dev/packages/sqflite)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Material Design 3](https://m3.material.io/)

---

## 29. Contacto y Soporte

Para preguntas o reportes de bugs, contactar al equipo de desarrollo.

---

**Última actualización:** 21 de Marzo de 2026  
**Responsable de documentación:** Sistema de Documentación Automática
**Estado de documento:** ✅ Completo y Verificado

