# 📖 Índice de Documentación - MR CROC

## Bienvenida al Proyecto MR CROC

**MR CROC** es una aplicación móvil para gestión de pedidos en restaurantes, desarrollada con **Flutter** y sincronización en tiempo real con **Supabase**.

Toda la documentación técnica está organizada en los siguientes archivos:

---

## 📚 Documentos Principales

### 1. 📋 [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md)

**Contenido:** Documentación técnica completa del proyecto

**Secciones:**
- Resumen ejecutivo del proyecto
- Requisitos técnicos y dependencias
- Arquitectura general y patrones
- Estructura del proyecto (carpetas y archivos)
- Modelos de datos (ProductModel, CategoryModel, AdditionModel, etc.)
- Gestión de estado con ValueNotifiers
- Base de datos (tablas, sincronización)
- Servicios (SyncService)
- Pantallas principales
- Componentes reutilizables (Widgets)
- Tema y estilos
- Flujo de operaciones
- Configuración multiplataforma
- Ciclo de vida de la aplicación
- Mejores prácticas y patrones

**Para quién:** Desarrolladores que necesitan entender la arquitectura completa

**Cuándo leer:** Al inicio del proyecto o cuando necesites arquitectura técnica

---

### 2. 🏗️ [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md)

**Contenido:** Diagramas visuales de la arquitectura (en Mermaid)

**Diagramas incluidos:**
- Arquitectura general (Capa de Presentación → Estado → Servicios → Datos)
- Flujo de datos (usuario → BD)
- Modelo Entidad-Relación (tablas y relaciones)
- Flujo de creación de pedido
- Arquitectura de carpetas
- Diagrama de estado (ValueNotifiers)
- Ciclo de sincronización
- Componentes de UI
- Dependencias del proyecto
- Inicialización de la aplicación
- Patrones de diseño utilizados
- Matriz de responsabilidades
- Ciclo de vida de un pedido
- Referencias cruzadas de módulos

**Para quién:** Visualizadores, nuevos miembros del equipo

**Cuándo leer:** Para entender rápidamente la estructura visual

---

### 3. 📚 [REFERENCIA_API.md](REFERENCIA_API.md)

**Contenido:** Referencia detallada de APIs, funciones y clases

**Secciones:**
- **Modelos:** ProductModel, CategoryModel, AdditionModel, Order, etc.
  - Propiedades de cada modelo
  - Métodos disponibles
  - Ejemplos de uso
- **Funciones de Base de Datos:** Inicialización, sincronización
- **Provider/Estado:** ValueNotifiers globales  
  - productList, categorytList, additionsList
  - comanda, indexComanda, indexSalsas
  - pdtStadictsList, idFechaNow
- **Servicios:** SyncService y métodos
- **Widgets Personalizados:** ButtonAdicion, ChartPie
- **Utilidades:** Funciones y constantes
- **Variables de Entorno:** SUPABASE_URL, SUPABASE_ANON_KEY
- **Mejores Prácticas:** Patrones de código recomendados
- **Constantes de Tema:** Colores, fuentes, estilos
- **Rutas de Navegación:** Mapeo de rutas

**Para quién:** Desarrolladores implementando características

**Cuándo leer:** Cuando necesites usar API específica o función

---

### 4. 🔧 [GUIA_DESARROLLO.md](GUIA_DESARROLLO.md)

**Contenido:** Guía práctica de desarrollo y resolución de problemas

**Secciones:**
- **Configuración del Entorno:**
  - Instalación de Flutter
  - Clonación del proyecto
  - Configuración de IDE (VS Code, Android Studio)
  - Configuración de Supabase
- **Primeros Pasos:** Verificación, ejecución en plataformas
- **Estructura de Branching:** Git Flow, nombres de ramas, commits
- **Convenciones de Código:**
  - Naming (archivos, clases, variables)
  - Formato de código
  - Análisis estático
  - Docstrings
  - Comentarios
- **Agregar Nuevas Características:**
  - Agregar pantalla (paso a paso)
  - Agregar modelo (paso a paso)
  - Agregar widget (paso a paso)
- **Debugging:**
  - DevTools
  - Hot reload/restart
  - Breakpoints
  - Logging
  - Debugging de BD
  - Debugging de sincronización
- **Testing:**
  - Unit tests
  - Widget tests
  - Integration tests
- **Resolución de Problemas:** 10+ problemas comunes y soluciones
- **Performance:**
  - Análisis de rendimiento
  - Optimización de listas
  - Optimización de BD
  - Reducir tamaño de app
- **Deployment:**
  - Build Android APK/AAB
  - Build iOS
  - Build Web
  - Versionado
  - CI/CD con GitHub Actions
- **Checklist Pre-Release**

**Para quién:** Desarrolladores nuevos, developers que hacen cambios

**Cuándo leer:** Cuando necesites setup, debugging o agregar features

---

## 🎯 Guía Rápida por Rol

### Developer Junior (Nuevo en el Proyecto)

1. **Comienza con:** [GUIA_DESARROLLO.md#configuración-del-entorno](GUIA_DESARROLLO.md) - Configurar entorno
2. **Luego lee:** [DOCUMENTACION_TECNICA.md#resumen-ejecutivo](DOCUMENTACION_TECNICA.md) - Entender proyecto
3. **Visualiza:** [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md) - Ver estructura
4. **Consulta:** [REFERENCIA_API.md](REFERENCIA_API.md) - Cuando necesites APIs

### Developer Senior (Cambios Arquitectónicos)

1. **Lee todo:** [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md)
2. **Revisa:** [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md)
3. **Implementa:** Siguiendo [GUIA_DESARROLLO.md#convenciones-de-código](GUIA_DESARROLLO.md)
4. **QA:** [GUIA_DESARROLLO.md#testing](GUIA_DESARROLLO.md) y [#deployment](GUIA_DESARROLLO.md#deployment)

### QA / Tester

1. **Entiende flujo:** [DOCUMENTACION_TECNICA.md#flujo-de-operaciones-principales](DOCUMENTACION_TECNICA.md)
2. **Casos de prueba:** [GUIA_DESARROLLO.md#testing](GUIA_DESARROLLO.md)
3. **Debugging:** [GUIA_DESARROLLO.md#debugging](GUIA_DESARROLLO.md)
4. **Resolución:** [GUIA_DESARROLLO.md#resolución-de-problemas](GUIA_DESARROLLO.md)

### Deployments / DevOps

1. **Deploy:** [GUIA_DESARROLLO.md#deployment](GUIA_DESARROLLO.md)
2. **CI/CD:** [GUIA_DESARROLLO.md#configuración-de-cicd](GUIA_DESARROLLO.md)
3. **Environment:** [REFERENCIA_API.md#variables-de-entorno](REFERENCIA_API.md)

### Product Manager / Stakeholder

1. **Resumen Ejecutivo:** [DOCUMENTACION_TECNICA.md#resumen-ejecutivo](DOCUMENTACION_TECNICA.md)
2. **Arquitectura Visual:** [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md)
3. **Características:** [DOCUMENTACION_TECNICA.md#pantallas-principales](DOCUMENTACION_TECNICA.md)

---

## 📋 Tabla de Contenidos Rápida

### Documentación Técnica

| Sección | Ubicación |
|---------|-----------|
| Requisitos técnicos | [DOCUMENTACION_TECNICA.md#1-requisitos-técnicos](DOCUMENTACION_TECNICA.md) |
| Arquitectura | [DOCUMENTACION_TECNICA.md#2-arquitectura-general](DOCUMENTACION_TECNICA.md) |
| Modelos de datos | [DOCUMENTACION_TECNICA.md#4-modelos-de-datos](DOCUMENTACION_TECNICA.md) |
| Base de datos | [DOCUMENTACION_TECNICA.md#6-base-de-datos](DOCUMENTACION_TECNICA.md) |
| Servicios | [DOCUMENTACION_TECNICA.md#7-servicios](DOCUMENTACION_TECNICA.md) |
| Pantallas | [DOCUMENTACION_TECNICA.md#8-pantallas-principales](DOCUMENTACION_TECNICA.md) |

### Diagramas

| Diagrama | Ubicación |
|----------|-----------|
| Arquitectura general | [DIAGRAMAS_ARQUITECTURA.md#diagrama-de-arquitectura-general](DIAGRAMAS_ARQUITECTURA.md) |
| Flujo de datos | [DIAGRAMAS_ARQUITECTURA.md#diagrama-de-flujo-de-datos](DIAGRAMAS_ARQUITECTURA.md) |
| Modelos ER | [DIAGRAMAS_ARQUITECTURA.md#diagrama-de-entidades-modelos-de-datos](DIAGRAMAS_ARQUITECTURA.md) |
| Estado | [DIAGRAMAS_ARQUITECTURA.md#diagrama-de-estado-valuenotifiers](DIAGRAMAS_ARQUITECTURA.md) |
| Sincronización | [DIAGRAMAS_ARQUITECTURA.md#ciclo-de-sincronización](DIAGRAMAS_ARQUITECTURA.md) |

### Referencias API

| Elemento | Ubicación |
|----------|-----------|
| ProductModel | [REFERENCIA_API.md#productmodel](REFERENCIA_API.md) |
| CategoryModel | [REFERENCIA_API.md#categorymodel](REFERENCIA_API.md) |
| Order | [REFERENCIA_API.md#order](REFERENCIA_API.md) |
| ValueNotifiers | [REFERENCIA_API.md#providerestado](REFERENCIA_API.md) |
| SyncService | [REFERENCIA_API.md#syncservice](REFERENCIA_API.md) |

### Guía de Desarrollo

| Tópico | Ubicación |
|--------|-----------|
| Setup | [GUIA_DESARROLLO.md#configuración-del-entorno](GUIA_DESARROLLO.md) |
| Git Flow | [GUIA_DESARROLLO.md#estructura-de-branching](GUIA_DESARROLLO.md) |
| Convenciones | [GUIA_DESARROLLO.md#convenciones-de-código](GUIA_DESARROLLO.md) |
| Agregar Features | [GUIA_DESARROLLO.md#agregar-nuevas-características](GUIA_DESARROLLO.md) |
| Debugging | [GUIA_DESARROLLO.md#debugging](GUIA_DESARROLLO.md) |
| Testing | [GUIA_DESARROLLO.md#testing](GUIA_DESARROLLO.md) |
| Troubleshooting | [GUIA_DESARROLLO.md#resolución-de-problemas](GUIA_DESARROLLO.md) |
| Performance | [GUIA_DESARROLLO.md#performance](GUIA_DESARROLLO.md) |
| Deploy | [GUIA_DESARROLLO.md#deployment](GUIA_DESARROLLO.md) |

---

## 🚀 Primeros Pasos para Nuevo Developer

### 1. Configurar (1-2 horas)

```bash
# 1. Leer guía setup
# Ver: GUIA_DESARROLLO.md#configuración-del-entorno

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar app
flutter run

# 4. Verificar que funciona
# Debería ver pantalla HomeScreen con "Mr Croc"
```

### 2. Entender (2-3 horas)

```
1. Leer: DOCUMENTACION_TECNICA.md (20 min)
2. Ver: DIAGRAMAS_ARQUITECTURA.md (20 min)
3. Explorar: Códu en lib/ (aplicar lo leído)
```

### 3. Practicar (2-4 horas)

**Ejercicio 1:** Agregar nuevo modelo

```dart
// Crear lib/models/model_salsa.dart (si no existe)
// Seguir: GUIA_DESARROLLO.md#agregar-nuevo-modelo
```

**Ejercicio 2:** Agregar nueva pantalla

```dart
// Crear lib/screens/estadisticas.dart
// Seguir: GUIA_DESARROLLO.md#agregar-nueva-pantalla
```

**Ejercicio 3:** Debug simple

```dart
// Seguir: GUIA_DESARROLLO.md#logging
// Agregar logs en main.dart
```

### 4. Contribuir

```
// Leer antes de hacer cambios:
// - GUIA_DESARROLLO.md#convenciones-de-código
// - GUIA_DESARROLLO.md#estructura-de-branching
```

---

## 🔍 Búsqueda Rápida

### "¿Cómo hago para...?"

| Acción | Referencia |
|--------|-----------|
| Agregar un modelo | [GUIA_DESARROLLO.md#agregar-nuevo-modelo](GUIA_DESARROLLO.md) |
| Crear una pantalla | [GUIA_DESARROLLO.md#agregar-nueva-pantalla](GUIA_DESARROLLO.md) |
| Usar un ValueNotifier | [REFERENCIA_API.md#providerestado](REFERENCIA_API.md) |
| Sincronizar datos | [REFERENCIA_API.md#syncservice](REFERENCIA_API.md) |
| Debuggear la app | [GUIA_DESARROLLO.md#debugging](GUIA_DESARROLLO.md) |
| Escribir tests | [GUIA_DESARROLLO.md#testing](GUIA_DESARROLLO.md) |
| Hacer build | [GUIA_DESARROLLO.md#deployment](GUIA_DESARROLLO.md) |
| Resolver error | [GUIA_DESARROLLO.md#resolución-de-problemas](GUIA_DESARROLLO.md) |
| Entender BD | [DOCUMENTACION_TECNICA.md#6-base-de-datos](DOCUMENTACION_TECNICA.md) |
| Optimizar performance | [GUIA_DESARROLLO.md#performance](GUIA_DESARROLLO.md) |

---

## 📞 Preguntas Frecuentes

**P: ¿Por dónde empiezo?**  
R: Ve a [GUIA_DESARROLLO.md#primeros-pasos](GUIA_DESARROLLO.md) y sigue paso a paso.

**P: ¿Cómo está organizado el código?**  
R: Ver [DOCUMENTACION_TECNICA.md#3-estructura-del-proyecto](DOCUMENTACION_TECNICA.md)

**P: ¿Cuál es la arquitectura?**  
R: Lee [DOCUMENTACION_TECNICA.md#2-arquitectura-general](DOCUMENTACION_TECNICA.md) y ve [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md)

**P: ¿Cómo funciona la sincronización?**  
R: Ver [DOCUMENTACION_TECNICA.md#63-sistema-de-sincronización](DOCUMENTACION_TECNICA.md) y [DIAGRAMAS_ARQUITECTURA.md#ciclo-de-sincronización](DIAGRAMAS_ARQUITECTURA.md)

**P: ¿Cómo agrego una nueva función?**  
R: Ve a [GUIA_DESARROLLO.md#agregar-nuevas-características](GUIA_DESARROLLO.md)

**P: ¿Qué hago si hay un error?**  
R: Consulta [GUIA_DESARROLLO.md#resolución-de-problemas](GUIA_DESARROLLO.md)

**P: ¿Cómo hago deploy?**  
R: Ve a [GUIA_DESARROLLO.md#deployment](GUIA_DESARROLLO.md)

---

## 📈 Versiones de Documentos

| Documento | Versión | Última Actualización |
|-----------|---------|----------------------|
| DOCUMENTACION_TECNICA.md | 1.0 | 21 de Marzo de 2026 |
| DIAGRAMAS_ARQUITECTURA.md | 1.0 | 21 de Marzo de 2026 |
| REFERENCIA_API.md | 1.0 | 21 de Marzo de 2026 |
| GUIA_DESARROLLO.md | 1.0 | 21 de Marzo de 2026 |
| INDICE_DOCUMENTACION.md | 1.0 | 21 de Marzo de 2026 |

---

## 🔗 Enlaces Externos Útiles

### Documentación Oficial
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev)
- [Material Design 3](https://m3.material.io/)

### Librerías Usadas
- [SQLite (sqflite)](https://pub.dev/packages/sqflite)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [responsive_builder](https://pub.dev/packages/responsive_builder)
- [intl](https://pub.dev/packages/intl)
- [pie_chart](https://pub.dev/packages/pie_chart)

### Herramientas
- [Android Studio](https://developer.android.com/studio)
- [Xcode](https://developer.apple.com/xcode/)
- [VS Code](https://code.visualstudio.com/)

---

## 📝 Notas Importantes

⚠️ **Cambios de BD:** Actualizar [DOCUMENTACION_TECNICA.md#62-estructura-de-tablas](DOCUMENTACION_TECNICA.md) cuando agreges tablas.

⚠️ **Nuevas dependencias:** Actualizar [DOCUMENTACION_TECNICA.md#11-dependencias-principales](DOCUMENTACION_TECNICA.md)

⚠️ **API changes:** Actualizar [REFERENCIA_API.md](REFERENCIA_API.md)

⚠️ **Arquitectura:** Actualizar [DIAGRAMAS_ARQUITECTURA.md](DIAGRAMAS_ARQUITECTURA.md) si hay cambios mayores

---

## ✅ Checklist para Mantenimiento de Documentos

- [ ] Revisar documentación mensualmente
- [ ] Actualizar si hay cambios en arquitectura
- [ ] Verificar que ejemplos de código funcionan
- [ ] Agregar problemas nuevos a troubleshooting
- [ ] Mantener diagramas sincronizados
- [ ] Validar enlaces internos
- [ ] Actualizar versionado

---

## 📮 Feedback

Si encuentras errores, inconsistencias o secciones confusas en la documentación, por favor crea un issue o contacta al equipo de desarrollo.

---

**Creado:** 21 de Marzo de 2026  
**Mantenido por:** Equipo de Desarrollo MR CROC  
**Estado:** ✅ Documentación Completa

