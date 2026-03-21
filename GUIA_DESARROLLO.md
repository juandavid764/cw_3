# 🔧 Guía de Desarrollo - MR CROC

## Tabla de Contenidos

1. [Configuración del Entorno](#configuración-del-entorno)
2. [Primeros Pasos](#primeros-pasos)
3. [Estructura de Branching](#estructura-de-branching)
4. [Convenciones de Código](#convenciones-de-código)
5. [Agregar Nuevas Características](#agregar-nuevas-características)
6. [Debugging](#debugging)
7. [Testing](#testing)
8. [Resolución de Problemas](#resolución-de-problemas)
9. [Performance](#performance)
10. [Deployment](#deployment)

---

## Configuración del Entorno

### Requisitos Previos

- **macOS/Linux/Windows:** Sistema operativo compatible
- **Flutter SDK:** v3.7.2 o superior
- **Dart SDK:** v3.7.2 o superior (incluido con Flutter)
- **Git:** Control de versiones
- **Editor:** VS Code, Android Studio o IntelliJ IDEA
- **Emulador/Dispositivo:** Para testing

### Instalación de Flutter

```bash
# Descargar Flutter
git clone https://github.com/flutter/flutter.git
cd flutter
export PATH="$PATH:`pwd`/bin"

# Verificar instalación
flutter doctor

# Resolver problemas
flutter doctor -v
```

### Clonar el Proyecto

```bash
git clone <repository-url>
cd cw_3
flutter pub get
```

### Configurar Variables de Entorno

```bash
# .env (no versionar este archivo)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Configurar IDE

#### VS Code

1. Instalar extensiones:
   - Flutter
   - Dart
   - Awesome Flutter Snippets

2. Crear archivo `.vscode/settings.json`:
```json
{
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true
  }
}
```

#### Android Studio

1. Instalar plugins:
   - Flutter
   - Dart

2. Configurar emulador Android

#### Configurar Supabase Localmente (opcional)

```bash
# Instalar supabase CLI
npm install -g @supabase/cli

# Iniciar Supabase localmente
supabase start

# Obtener credenciales locales
supabase status
```

---

## Primeros Pasos

### Verificar Instalación

```bash
# Dentro del directorio del proyecto
flutter doctor -v
flutter pub get
flutter analyze

# Ejecutar en emulador/dispositivo
flutter run
```

### Ejecutar en Diferentes Plataformas

```bash
# Android (emulador)
flutter run -d emulator-5554

# iOS (simulador)
flutter run -d simulator

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Ejecutar con Variables de Entorno

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

### Comando útil: Watch Mode

```bash
flutter run --debug
# Modificar archivo y presionar 'r' para hot reload
# Presionar 'R' para hot restart
```

---

## Estructura de Branching

### Estrategia Git Flow

```
main (producción)
├── release/* (preparación para producción)
└── develop (desarrollo)
    ├── feature/* (nuevas características)
    ├── bugfix/* (correcciones)
    └── hotfix/* (correcciones urgentes)
```

### Crear Nueva Rama

```bash
# Actualizar main y develop
git checkout develop
git pull origin develop

# Crear Feature Branch
git checkout -b feature/nombre-descriptivo

# Crear Bugfix Branch
git checkout -b bugfix/nombre-descriptivo

# Crear Release Branch
git checkout -b release/v1.1.0

# Crear Hotfix
git checkout -b hotfix/descripcion-del-problema
```

### Nombres de Ramas

**Formato:** `<tipo>/<descripcion-kebab-case>`

**Ejemplos:**
```
feature/agregar-pantalla-estadisticas
feature/sincronizacion-mejorada
bugfix/error-sincronizacion-supabase
hotfix/corregir-crash-pedidos
refactor/optimizar-carga-productos
docs/actualizar-documentacion-api
test/agregar-tests-modelos
```

### Hacer Commit

**Formato de mensaje:**
```
<tipo>: <descripción corta>

<cuerpo descriptivo opcional>

<closes #issue-number>
```

**Tipos:**
- `feat:` Nuevas características
- `fix:` Correcciones
- `refactor:` Restructuración sin cambiar funcionalidad
- `style:` Formato, espacios, semicolons
- `docs:` Cambios en documentación
- `test:` Agregar o actualizar tests
- `perf:` Mejoras de rendimiento
- `ci:` Cambios en CI/CD

**Ejemplos:**
```bash
git commit -m "feat: agregar selección de salsas en detalles del pedido"

git commit -m "fix: corregir crash cuando no hay conexión a internet

- Manejar excepción de conectividad
- Mostrar toast al usuario
- Guardar cambios localmente

closes #42"
```

---

## Convenciones de Código

### Naming

#### Archivos

```
# ✅ Correcto
lib/models/model_product.dart
lib/screens/homescreen.dart
lib/widgets/buttonAdicion.dart
lib/services/sync_service.dart

# ❌ Evitar
lib/models/Product.dart
lib/screens/home_screen.dart
lib/widgets/ButtonAdicion.dart
lib/services/SyncService.dart
```

#### Clases

```dart
// ✅ Correcto - PascalCase
class ProductModel { }
class SyncService { }
class HomeScreen extends StatefulWidget { }

// ❌ Incorrecto
class product_model { }
class syncService { }
class homescreen { }
```

#### Variables

```dart
// ✅ Correcto - camelCase
final productName = "Hamburguesa";
var syncInProgress = false;
late Database _db;

// ❌ Incorrecto
final product_name = "Hamburguesa";
var SyncInProgress = false;
final DB_INSTANCE;
```

#### Constantes

```dart
// ✅ Correcto
const int syncStatusPending = 0;
const String appName = 'Mr Croc';
const double taxRate = 0.16;

// ❌ Incorrecto
const int SYNC_STATUS_PENDING = 0;
const String AppName = 'Mr Croc';
const double tax_rate = 0.16;
```

### Formato

```bash
# Formatear todo el código
dart format lib/

# Formatear archivo específico
dart format lib/models/model_product.dart

# Verificar formato (sin cambiar)
dart format --set-exit-if-changed lib/
```

### Análisis Estático

```bash
# Ejecutar análisis
flutter analyze

# Análisis detallado
flutter analyze --watch

# Verificar lint específico
flutter analyze lib/models/
```

### Docstrings

```dart
/// Crea un producto desde un mapa de datos.
///
/// Utiliza el método [fromMap] para deserializar datos de la BD.
/// 
/// Ejemplo:
/// ```dart
/// final product = ProductModel.fromMap({
///   'product_id': 1,
///   'name': 'Hamburguesa',
///   'price': 4999,
/// });
/// ```
static ProductModel fromMap(Map<String, Object?> map) {
  return ProductModel(
    id: map['product_id'] as int,
    name: map['name'] as String,
  );
}
```

### Comentarios

```dart
// ✅ Bueno: Explica POR QUÉ, no QUÉ
// Se genera UUID seguro para sincronización offline-first
final uuid = _generateUuid();

// ❌ Malo: Solo repite el código
// Generar UUID
final uuid = _generateUuid();

// ❌ Innecesario en código obvio
i++; // Incrementar i
```

---

## Agregar Nuevas Características

### Agregar Nueva Pantalla

1. **Crear archivo en `lib/screens/`:**

```dart
// lib/screens/menu_settings.dart
import 'package:flutter/material.dart';

class MenuSettings extends StatefulWidget {
  const MenuSettings({super.key});

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Menú'),
      ),
      body: Center(
        child: Text('Contenido aquí'),
      ),
    );
  }
}
```

2. **Agregar ruta en `lib/main.dart`:**

```dart
routes: {
  '/home': (context) => const HomeScreeen(),
  '/menu-settings': (context) => const MenuSettings(),
}
```

3. **Navegar desde otra pantalla:**

```dart
onPressed: () {
  Navigator.pushNamed(context, '/menu-settings');
}
```

---

### Agregar Nuevo Modelo

1. **Crear archivo en `lib/models/`:**

```dart
// lib/models/model_discount.dart
class DiscountModel {
  final int id;
  final String name;
  final double percentage;
  final String? description;

  DiscountModel({
    required this.id,
    required this.name,
    required this.percentage,
    this.description,
  });

  /// Crea un descuento desde datos de BD
  static DiscountModel fromMap(Map<String, Object?> map) {
    return DiscountModel(
      id: map['discount_id'] as int,
      name: map['name'] as String,
      percentage: (map['percentage'] as num).toDouble(),
      description: map['description'] as String?,
    );
  }

  /// Convierte a mapa para guardar en BD
  Map<String, Object?> toMap() {
    return {
      'discount_id': id,
      'name': name,
      'percentage': percentage,
      'description': description,
    };
  }
}
```

2. **Agregar ValueNotifier en `lib/provider/provider_notifier.dart`:**

```dart
ValueNotifier<List<DiscountModel>> discountsList = ValueNotifier([]);
```

3. **Implementar en funciones de BD:**

```dart
// lib/database/db_functions.dart
Future<void> getDiscountsData() async {
  final results = await _db.query('discounts');
  discountsList.value = results
      .map((map) => DiscountModel.fromMap(map))
      .toList();
}
```

4. **Llamar en `main()`:**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  // ... otras inicializaciones
  await getDiscountsData();  // ← Agregar esta línea
  runApp(const MyApp());
}
```

---

### Agregar Nuevo Widget

```dart
// lib/widgets/discount_badge.dart
import 'package:flutter/material.dart';

/// Widget que muestra un badge de descuento
class DiscountBadge extends StatelessWidget {
  final double percentage;
  final double size;

  const DiscountBadge({
    Key? key,
    required this.percentage,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

**Usar en otra pantalla:**

```dart
DiscountBadge(percentage: 15.0)
```

---

## Debugging

### Herramientas Integradas

#### Flutter DevTools

```bash
# Abrir DevTools automáticamente
flutter run --debug

# Abrir DevTools manualmente
flutter pub global activate devtools
devtools

# O simplemente
flutter devtools
```

**Características:**
- Inspector de widgets
- Timeline y performance
- Memoria y GC
- Logs
- Network inspector

#### Hot Reload/Restart

```bash
# Durante ejecución en terminal
r     # Hot reload (mantiene estado)
R     # Hot restart (reinicia app)
q     # Cerrar

# Desde VS Code
Ctrl+Shift+F5  # Hot reload
Cmd+Shift+F5   # macOS
```

### Debugging con Breakpoints

#### VS Code

1. Coloca punto de quiebre (click en número de línea)
2. Ejecuta `flutter run`
3. La ejecución se detiene en el breakpoint
4. Usa "Debug Console" para inspeccionar variables

#### Android Studio

1. Menu: Run → Debug
2. Coloca breakpoints
3. Usa Debug panel para inspeccionar

### Logging

#### Usar print (simple)

```dart
print('Producto agregado: ${product.name}');
print('Comanda actual: ${comanda.value.length} items');
```

#### Usar dart:developer (recomendado)

```dart
import 'dart:developer' as developer;

developer.log(
  'Producto agregado',
  name: 'ProductManager',
  error: product,
);
```

#### Usar package log (profesional)

```yaml
dependencies:
  logger: ^1.4.0
```

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.i('Información');
logger.w('Advertencia');
logger.e('Error', error: exception, stackTrace: stackTrace);
logger.d('Debug');
```

### Debugging de Base de Datos

#### Inspeccionar BD SQLite

```bash
# Instalar herramienta
sqlite3 --version

# Abrir BD
sqlite3 assets/cw_database.db

# Comandos útiles
.tables                    # Listar tablas
.schema products          # Ver estructura
SELECT * FROM products;   # Consultar
.mode column              # Formato columnar
.exit                     # Salir
```

#### Desde Flutter

```dart
import 'package:sqflite/sqflite.dart';

// Consultar manualmente
Future<void> debugDatabase() async {
  final products = await _db.query('products');
  print('Productos en BD: ${products.length}');
  for (var p in products) {
    print('  - ${p['name']}: ${p['price']}');
  }
}

// Llamar para debugging
await debugDatabase();
```

### Debugging de Sincronización

```dart
// Agregar logging a SyncService
logger.i('Iniciando sincronización');

try {
  final report = await syncService.syncAll();
  logger.i('Sync exitoso: ${report.pushed} enviados, ${report.pulled} recibidos');
} catch (e) {
  logger.e('Error sync', error: e);
}

// Verificar outbox
final pending = await _db.query(
  'sync_outbox',
  where: 'operation = ?',
  whereArgs: ['INSERT'],
);
logger.d('Cambios pendientes: ${pending.length}');
```

---

## Testing

### Unit Tests

```dart
// test/models/model_product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_croc/models/model_product.dart';

void main() {
  group('ProductModel', () {
    test('ProductModel.fromMap crea instancia correcta', () {
      // Arrange
      final data = {
        'product_id': 1,
        'name': 'Hamburguesa',
        'price': 4999,
        'category': 5,
        'additives': 3,
        'text': 'Descripción',
      };

      // Act
      final product = ProductModel.fromMap(data);

      // Assert
      expect(product.id, 1);
      expect(product.name, 'Hamburguesa');
      expect(product.price, 4999);
      expect(product.isChild(5), true);
      expect(product.isChild(6), false);
    });

    test('isChild verifica correctamente la categoría', () {
      final product = ProductModel(
        id: 1,
        name: 'Pizza',
        price: 5999,
        category: 3,
        salsas: 2,
        text: 'Pizza clásica',
      );

      expect(product.isChild(3), true);
      expect(product.isChild(4), false);
    });
  });
}
```

**Ejecutar tests:**

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/models/model_product_test.dart

# Con cobertura
flutter test --coverage
# Generar reporte
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### Widget Tests

```dart
// test/widgets/discount_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_croc/widgets/discount_badge.dart';

void main() {
  group('DiscountBadge', () {
    testWidgets('muestra porcentaje correctamente', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscountBadge(percentage: 15.0),
          ),
        ),
      );

      // Assert
      expect(find.text('15%'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('respeta el tamaño especificado', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscountBadge(
              percentage: 20.0,
              size: 80.0,
            ),
          ),
        ),
      );

      final container = find.byType(Container);
      expect(container, findsOneWidget);
    });
  });
}
```

### Test de Integración

```dart
// test_driver/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mr_croc/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo de Pedido', () {
    testWidgets('Usuario puede crear pedido completo', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar pantalla inicial
      expect(find.text('Mr Croc'), findsOneWidget);

      // Seleccionar producto
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Verificar pantalla de adicionales
      expect(find.text('Adicionales'), findsOneWidget);
    });
  });
}
```

**Ejecutar:**

```bash
flutter drive --target=test_driver/app.dart
```

---

## Resolución de Problemas

### "Database not initialized"

**Problema:** Variable `_db` se usa antes de inicializar.

**Solución:**

```dart
// Verificar que initializeDatabase() se llama en main()
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();  // ← Obligatorio
  
  // Ahora 'database' está disponible
  runApp(const MyApp());
}
```

---

### "No changes detected" (Listener no dispara)

**Problema:** ValueNotifier no actualiza UI cuando modificas lista.

**Incorrecto:**
```dart
productList.value.add(newProduct);  // ❌ No dispara
```

**Correcto:**
```dart
productList.value = [...productList.value, newProduct]; // ✅
```

---

### "Connection refused" (Supabase)

**Problema:** No puede conectar a Supabase.

**Verificar:**
```bash
# 1. Credenciales configuradas
flutterdart-define=SUPABASE_URL
--dart-define=SUPABASE_ANON_KEY

# 2. URL válida
https://xyz.supabase.co

# 3. Clave válida
eyJhbG...

# 4. Firewall/VPN bloqueando
```

**Alternativa local:**
```bash
# Usar Supabase local
supabase start
supabase status  # Ver URLs locales
```

---

### "Hot reload no funciona"

**Problema:** Cambios no aparecen después de hot reload.

**Causas:**
- Cambios en initState()
- Modificaciones en main()
- Cambios en modelos de datos

**Solución:** Usar hot restart

```bash
# En terminal de Flutter
R  # Hot restart (en lugar de r)
```

---

### "Flutter analyze" muestra errores

**Problema:** Análisis estático encontró problemas.

```bash
# Ver errores detallados
flutter analyze --pubs

# Mostrar todos los problemas
flutter analyze --no-preamble

# Por archivo
flutter analyze lib/screens/
```

**Corregir:**

```bash
# Formatear automáticamente
dart format lib/

# O manualmente según las sugerencias del análisis
```

---

### "Cambios de BD no persisten"

**Problema:** INSERT/UPDATE no se guardan.

**Verificar:**

```dart
// 1. Verificar que tabla existe
final tables = await _db.rawQuery(
  "SELECT name FROM sqlite_master WHERE type='table'"
);
print('Tablas: $tables');

// 2. Verificar que write completa
final id = await _db.insert('products', data);
print('Insertado con ID: $id');

// 3. Verificar lectura
final read = await _db.query('products', where: 'product_id = ?', whereArgs: [id]);
print('Leído: $read');
```

---

### "Sync no se ejecuta"

**Problema:** SyncService.syncAll() no hace nada.

**Verificar:**

```dart
// 1. Credenciales
if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
  print('Credenciales no configuradas');
}

// 2. Conectividad
try {
  await Supabase.instance.client.auth.getUser();
  print('Conectado a Supabase');
} catch (e) {
  print('Supabase no accessible: $e');
}

// 3. Cambios pendientes
final pending = await _db.query('sync_outbox');
print('Cambios pendientes: ${pending.length}');
```

---

## Performance

### Análisis de Rendimiento

#### Timeline

```bash
# Abrir DevTools
flutter devtools

# Grabar timeline
1. Click en "Timeline" tab
2. Click en "Record"
3. Usar app
4. Click en "Stop"
5. Analizar gráfico
```

**Buscar:** Frames que tarden >16ms (60 FPS) o >33ms (30 FPS)

#### Memory Profiler

```bash
# DevTools → Memory tab
1. Click "GC" para limpiar memoria
2. Usar app por unos minutos
3. Analizar gráfico de memoria
4. Buscar spikes o crecimiento continuo
```

### Optimización de Listas

**Problema:** ListView lento con muchos items.

**Solución 1 - ListView.builder:**

```dart
// ✅ Eficiente: Solo renderiza items visibles
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductTile(
    product: products[index],
  ),
)

// ❌ Ineficiente: Renderiza todos los items
ListView(
  children: products.map(
    (p) => ProductTile(product: p),
  ).toList(),
)
```

**Solución 2 - Agregar key:**

```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductTile(
    key: ValueKey(products[index].id),  // ← Agregar
    product: products[index],
  ),
)
```

### Optimización de BD

#### Índices

```dart
// Crear índice en tabla frecuentemente consultada
await _db.execute(
  'CREATE INDEX IF NOT EXISTS idx_products_category ON products(category)',
);
```

#### Batch Inserts

```dart
// ❌ Lento: Una transacción por insert
for (final product in products) {
  await _db.insert('products', product.toMap());
}

// ✅ Rápido: Batch insert
await _db.transaction((txn) async {
  for (final product in products) {
    await txn.insert('products', product.toMap());
  }
});
```

#### Lazy Loading

```dart
// ✅ Cargar solo lo necesario
Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
  final results = await _db.query(
    'products',
    where: 'category = ?',
    whereArgs: [categoryId],
  );
  return results.map((map) => ProductModel.fromMap(map)).toList();
}

// En lugar de cargar TODO al iniciar
```

### Reducir Tamaño de App

```bash
# Ver tamaño de dependencias
flutter pub deps --tree

# Build Release
flutter build apk --release
flutter build ios --release

# Analizar assets
ls -lah assets/
```

---

## Deployment

### Build Producción

#### Android

```bash
# APK (instalación manual)
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk

# App Bundle (Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app.aab
```

#### iOS

```bash
# Build para TestFlight/App Store
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Crear Archive en Xcode
open ios/Runner.xcworkspace
# Product → Archive (en Xcode)
```

#### Web

```bash
# Build web
flutter build web --release
# Output: build/web/

# Deploy a servidor web
cd build/web
scp -r . user@server:/var/www/html/
```

### Versionado

```yaml
# pubspec.yaml
version: 1.1.0+2
# 1.1.0 = versión
# 2 = build number
```

**Actualizar versión:**

```bash
# Android
flutter pub version 1.1.0

# Cambiar manualmente en pubspec.yaml
version: 1.1.0+3  # Aumentar build número
```

### Configuración de CI/CD

#### GitHub Actions Ejemplo

```yaml
# .github/workflows/release.yml
name: Release Build

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.2'
      
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      
      - uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/app-release.apk
```

---

## Checklist Pre-Release

- [ ] Todos los tests pasan (`flutter test`)
- [ ] Análisis limpio (`flutter analyze`)
- [ ] No hay TODOs no resueltos en código
- [ ] Documentación actualizada
- [ ] Cambios en CHANGELOG
- [ ] Versión actualizada en pubspec.yaml
- [ ] Código formateado (`dart format lib/`)
- [ ] Performance OK (DevTools)
- [ ] Funcionamiento en dispositivos físicos
- [ ] Sincronización con Supabase funciona
- [ ] Build producción compila sin errores
- [ ] Screenshots actualizadas en README

---

**Última actualización:** 21 de Marzo de 2026

