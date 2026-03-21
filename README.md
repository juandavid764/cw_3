# 🍽️ MR CROC - Sistema de Gestión de Pedidos para Restaurantes

![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.2+-green?logo=dart)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**MR CROC** es una aplicación móvil multiplataforma desarrollada en **Flutter** para gestionar pedidos en restaurantes. Permite a meseros y personal de cocina registrar, modificar y confirmar pedidos con soporte para adicionales personalizables y sincronización en tiempo real con la nube.

**Plataformas soportadas:** 
- 📱 iOS
- 🤖 Android  
- 🌐 Web
- 🪟 Windows
- 🍎 macOS
- 🐧 Linux

---

## 📚 Documentación Técnica

### Quick Links
- **[INDICE_DOCUMENTACION.md](INDICE_DOCUMENTACION.md)** - Índice completo de documentación (punto de entrada)
- **[DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md)** - Documentación técnica detallada
- **[DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md)** - Diagramas visuales de arquitectura
- **[REFERENCIA_API.md](REFERENCIA_API.md)** - Referencia de APIs y funciones
- **[GUIA_DESARROLLO.md](GUIA_DESARROLLO.md)** - Guía práctica de desarrollo

**[👉 Ir a Documentación Completa](INDICE_DOCUMENTACION.md)**

---

## 🚀 Quick Start

### Requisitos Previos
- Flutter 3.7.2+
- Dart 3.7.2+
- Git
- Editor (VS Code, Android Studio o IntelliJ)

### Instalación

```bash
# 1. Clonar repositorio
git clone <repository-url>
cd cw_3

# 2. Obtener dependencias
flutter pub get

# 3. Ejecutar la app
flutter run
```

### Con Variables de Entorno (Supabase)

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

---

## 📦 Dependencias Principales

| Librería | Versión | Propósito |
|----------|---------|----------|
| flutter | 3.7.2+ | Framework UI |
| sqflite | 2.3.0 | Base de datos local |
| supabase_flutter | 2.8.0 | Sincronización en la nube |
| responsive_builder | 0.4.0 | Diseño responsive |
| intl | 0.19.0 | Internacionalización |
| pie_chart | 5.4.0 | Gráficos |
| esc_pos_printer | 0.1.1 | Impresión térmica |

**[Ver todas las dependencias](DOCUMENTACION_TECNICA.md#11-dependencias-principales)**

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────┐
│   Capa de Presentación          │
│  (Screens, Widgets, UI)         │
├─────────────────────────────────┤
│   Capa de Estado                │
│  (ValueNotifiers, Provider)     │
├─────────────────────────────────┤
│   Capa de Servicios             │
│  (Sincronización, Operaciones)  │
├─────────────────────────────────┤
│   Capa de Persistencia          │
│  (SQLite Local + Supabase)      │
└─────────────────────────────────┘
```

**[Ver diagramas detallados](DIAGRAMAS_ARQUITECTURA.md)**

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── database/                    # Funciones de BD
│   └── db_functions.dart
├── models/                      # Modelos de datos
│   ├── model_product.dart
│   ├── model_category.dart
│   ├── model_additions.dart
│   ├── model_order.dart
│   └── ...
├── provider/                    # Estado global
│   └── provider_notifier.dart
├── screens/                     # Pantallas
│   ├── homescreen.dart
│   ├── adiciones.dart
│   ├── big_order.dart
│   ├── confrim.dart
│   └── ...
├── services/                    # Servicios
│   └── sync_service.dart
└── widgets/                     # Componentes reutilizables
    ├── buttonAdicion.dart
    └── chartPie.dart
```

**[Ver estructura completa](DOCUMENTACION_TECNICA.md#3-estructura-del-proyecto)**

---

## 🎯 Funcionalidades Principales

✅ **Gestión de Pedidos**
- Crear, modificar y confirmar pedidos
- Sistema de comanda para rastrear pedidos activos
- Cálculo automático de totales

✅ **Categorización de Productos**
- Menú jerárquico (categorías y subcategorías)
- Visualización intuitiva de productos

✅ **Adicionales y Salsas**
- Selección de toppings/adicionales con precios
- Múltiples opciones de salsas por producto
- Control de cantidades

✅ **Impresión de Tickets**
- Impresión térmica de pedidos
- Formato ESC/POS para impresoras de restaurante
- Generación de recibos

✅ **Sincronización en Tiempo Real**
- Sincronización offline-first con SQLite
- Sincronización con Supabase cuando hay conexión
- Patrón outbox para garantizar entrega
- Manejo automático de conflictos

✅ **Estadísticas y Reportes**
- Gráficos de pastel con productos vendidos
- Análisis de ventas por fecha
- Seguimiento de tendencias

✅ **Interfaz Responsiva**
- Adaptación a diferentes tamaños de pantalla
- Tema Material Design 3
- Soporte para plataformas múltiples

---

## 🔧 Desarrollo

### Setup de Desarrollo

```bash
# Verificar instalación
flutter doctor

# Obtener dependencias
flutter pub get

# Ejecutar tests
flutter test

# Analisar código
flutter analyze

# Formatear código
dart format lib/
```

### Comandos Útiles

```bash
# Hot reload (mantiene estado)
r

# Hot restart (reinicia app completamente)
R

# Abrir DevTools
flutter devtools

# Build APK (Android)
flutter build apk --release

# Build para iOS
flutter build ios --release

# Build para Web
flutter build web --release
```

**[Ver guía completa de desarrollo](GUIA_DESARROLLO.md)**

---

## 🐛 Troubleshooting

### Database not initialized
**Solución:** Verificar que `initializeDatabase()` se llame en `main()` antes de otros inits.

### Import errors
**Solución:** Ejecutar `flutter pub get` para descargar dependencias.

### Sync no funciona
**Solución:** Verificar credenciales de Supabase y conectividad de red.

**[Ver más soluciones](GUIA_DESARROLLO.md#resolución-de-problemas)**

---

## 📋 Base de Datos

### Tablas Principales

| Tabla | Descripción |
|-------|-------------|
| `products` | Catálogo de productos |
| `categories` | Categorías (con soporte jerárquico) |
| `additions` | Adicionales/toppings |
| `sales` | Registro de ventas |
| `details_sale_product` | Ítems de cada venta |
| `dates` | Agrupación por fecha |
| `sync_*` | Tablas de sincronización |

**[Ver esquema detallado](DOCUMENTACION_TECNICA.md#62-estructura-de-tablas)**

---

## 🔐 Seguridad

- Credenciales de Supabase mediante variables de entorno
- Protección por contraseña para funciones administrativas
- Validación de datos en BD
- Gestión segura de tokens de autenticación

---

## 📈 Performance

- Caché local con SQLite para operaciones offline
- Actualización reactiva con ValueNotifiers
- Sincronización asincrónica no bloqueante
- Índices de BD para consultas rápidas
- Lazy loading de datos

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Test específico
flutter test test/models/model_product_test.dart

# Con cobertura
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

**[Ver guía de testing](GUIA_DESARROLLO.md#testing)**

---

## 📦 Compilación y Distribución

### Android

```bash
# APK para distribución manual
flutter build apk --release

# App Bundle para Google Play
flutter build appbundle --release
```

### iOS

```bash
# Preparar para TestFlight/App Store
flutter build ios --release
```

### Web

```bash
# Build web
flutter build web --release
```

**[Ver instrucciones detalladas](GUIA_DESARROLLO.md#deployment)**

---

## 📊 Versión

**Versión Actual:** 1.0.0  
**Build Number:** 1  
**Status:** En Desarrollo Activo

---

## 🤝 Contribuir

1. Lee las [Convenciones de Código](GUIA_DESARROLLO.md#convenciones-de-código)
2. Sigue el [Git Flow](GUIA_DESARROLLO.md#estructura-de-branching)
3. Escribe tests para nuevas funcionalidades
4. Mantén la documentación actualizada

---

## 📚 Recursos Útiles

- **[Documentación Oficial Flutter](https://flutter.dev/docs)**
- **[Documentación Dart](https://dart.dev)**
- **[Material Design 3](https://m3.material.io/)**
- **[Documentación Supabase](https://supabase.com/docs)**
- **[SQLite Flutter](https://pub.dev/packages/sqflite)**

---

## 📝 Notas para Desarrolladores

- Revisa [INDICE_DOCUMENTACION.md](INDICE_DOCUMENTACION.md) para guía de documentos
- Mantén `pubspec.yaml` actualizado con dependencias
- Actualiza documentación si cambias arquitectura
- Commit regularmente siguiendo convenciones
- Ejecuta análisis antes de push: `flutter analyze`

---

## 📞 Soporte

Para preguntas o reportar bugs:
1. Revisar [Troubleshooting](GUIA_DESARROLLO.md#resolución-de-problemas)
2. Consultar [FAQ](INDICE_DOCUMENTACION.md#preguntas-frecuentes)
3. Contactar al equipo de desarrollo

---

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver detalles en LICENSE.

---

## 👥 Equipo

- **Desarrolladores:** Equipo de Desarrollo MR CROC
- **Documentación:** Sistema de Documentación Automática
- **Última actualización:** 21 de Marzo de 2026

---

**¿Necesitas más información?** 👉 [Ir a documentación completa](INDICE_DOCUMENTACION.md)
