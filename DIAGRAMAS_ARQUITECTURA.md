# 🏗️ Diagramas de Arquitectura - MR CROC

## Diagrama de Arquitectura General

```mermaid
graph TB
    subgraph UI["Capa de Presentación"]
        HomeScreen["🏠 HomeScreen"]
        Nodes["📁 Nodes - Navegación"]
        Screens["📋 Screens"]
        Adiciones["➕ Adiciones"]
        BigOrder["📦 Big Order"]
        Confirm["✅ Confirm"]
        Salsas["🌶️ Salsas"]
        CRUD["🔧 CRUD Settings"]
    end

    subgraph State["Capa de Estado"]
        Provider["📌 Provider Notifier"]
        ValueNotifiers["🔔 ValueNotifiers"]
    end

    subgraph Service["Capa de Servicios"]
        SyncService["🔄 Sync Service"]
        DBFunctions["📂 DB Functions"]
    end

    subgraph Data["Capa de Persistencia"]
        SQLite["💾 SQLite Local"]
        Supabase["☁️ Supabase Cloud"]
    end

    HomeScreen --> Nodes
    Nodes --> Screens
    Screens --> Adiciones
    Screens --> BigOrder
    Screens --> Confirm
    Screens --> Salsas
    HomeScreen --> CRUD
    
    Adiciones --> Provider
    BigOrder --> Provider
    Confirm --> Provider
    
    Provider --> ValueNotifiers
    ValueNotifiers --> SyncService
    ValueNotifiers --> DBFunctions
    
    SyncService --> SQLite
    SyncService --> Supabase
    DBFunctions --> SQLite

    style UI fill:#ff9999
    style State fill:#99ccff
    style Service fill:#99ff99
    style Data fill:#ffcc99
```

---

## Diagrama de Flujo de Datos

```mermaid
graph LR
    User["👤 Usuario"]
    UI["🎨 Interfaz"]
    State["🔔 Estado"]
    Logic["⚙️ Lógica"]
    LocalDB["💾 BD Local"]
    Cloud["☁️ Nube"]

    User -->|Interacción| UI
    UI -->|Actualiza| State
    State -->|Ejecuta| Logic
    Logic -->|Guarda| LocalDB
    LocalDB -->|Sincroniza| Cloud
    Cloud -->|Trae cambios| LocalDB
    LocalDB -->|Actualiza| State
    State -->|Renderiza| UI
    UI -->|Muestra| User

    style User fill:#ffcccc
    style UI fill:#ff9999
    style State fill:#99ccff
    style Logic fill:#99ff99
    style LocalDB fill:#ffcc99
    style Cloud fill:#ffddaa
```

---

## Diagrama de Entidades (Modelos de Datos)

```mermaid
erDiagram
    PRODUCT ||--o{ CATEGORY : "belongs_to"
    PRODUCT ||--o{ ADDITION : "has"
    SALE ||--o{ SALE_DETAIL : "contains"
    SALE_DETAIL ||--o{ PRODUCT : "lists"
    DATE ||--o{ SALE : "groups"

    CATEGORY {
        int category_id PK
        string category_name
        int parentCategory FK "Subcategoría"
        string uuid
        datetime created_at
        datetime updated_at
    }

    PRODUCT {
        int product_id PK
        string name
        int price
        int category FK
        int additives
        string text
        string uuid
        datetime created_at
        datetime updated_at
    }

    ADDITION {
        int addition_id PK
        string name
        int price
        string uuid
        datetime created_at
        datetime updated_at
    }

    SALE {
        int id PK
        string date
        int total
        string uuid
        datetime created_at
        datetime updated_at
    }

    SALE_DETAIL {
        int id PK
        int sale_id FK
        string text
        int quantity
        string uuid
        datetime created_at
        datetime updated_at
    }

    DATE {
        int date_id PK
        string date
        string uuid
        datetime created_at
        datetime updated_at
    }
```

---

## Flujo de Creación de Pedido

```mermaid
sequenceDiagram
    participant User as 👤 Usuario
    participant UI as 🎨 UI
    participant State as 🔔 Estado
    participant DB as 💾 BD Local
    participant Sync as 🔄 Sincronización
    participant Cloud as ☁️ Supabase

    User->>UI: Selecciona producto
    UI->>State: Actualiza comanda
    State->>State: Agrega Order a lista
    
    User->>UI: Selecciona adicionales
    UI->>State: Actualiza adicionales
    
    User->>UI: Selecciona salsas
    UI->>State: Actualiza salsas
    
    User->>UI: Confirma pedido
    UI->>DB: INSERT sale
    UI->>DB: INSERT sale_detail
    DB->>DB: Genera UUID
    DB->>State: Actualiza ValueNotifier
    
    Note over DB: Se registra en sync_outbox
    
    Sync->>DB: Detecta cambios pendientes
    Sync->>Cloud: POST a Supabase
    Cloud->>Cloud: Almacena datos
    Sync->>DB: Limpia sync_outbox
    Sync->>State: Muestra reporte

    User->>UI: Ve confirmación
```

---

## Arquitectura de Carpetas Detallada

```mermaid
graph TB
    Root["📦 mr_croc"]
    
    Root --> Lib["lib/"]
    Root --> Assets["assets/"]
    Root --> Android["android/"]
    Root --> IOS["ios/"]
    Root --> Web["web/"]
    Root --> Config["Config Files"]
    
    Lib --> Main["main.dart 🚀"]
    Lib --> Database["database/"]
    Lib --> Models["models/"]
    Lib --> Provider["provider/"]
    Lib --> Screens["screens/"]
    Lib --> Services["services/"]
    Lib --> Widgets["widgets/"]
    
    Database --> DBFuncs["db_functions.dart"]
    
    Models --> ModelProd["model_product.dart"]
    Models --> ModelCat["model_category.dart"]
    Models --> ModelAdd["model_additions.dart"]
    Models --> ModelOrd["model_order.dart"]
    Models --> ModelOther["model_*.dart (otros)"]
    
    Provider --> ProvNotif["provider_notifier.dart"]
    
    Screens --> Home["homescreen.dart"]
    Screens --> Nav["navigation.dart"]
    Screens --> Nodos["nodes.dart"]
    Screens --> PantOtras["adiciones.dart, salsas.dart, etc."]
    Screens --> CRUDDB["crud-db/"]
    
    Services --> Sync["sync_service.dart"]
    
    Widgets --> WButton["buttonAdicion.dart"]
    Widgets --> WChart["chartPie.dart"]
    
    Assets --> AssetDB["cw_database.db"]
    Assets --> AssetIcon["icon/"]
    Assets --> AssetScreens["Screenshots/"]
    
    Config --> PubSpec["pubspec.yaml"]
    Config --> Analysis["analysis_options.yaml"]
    Config --> README["README.md"]
    Config --> IML["cw_3.iml"]
    
    style Root fill:#ffffcc
    style Lib fill:#ccffcc
    style Assets fill:#ccffff
    style Android fill:#ffcccc
    style IOS fill:#ffcccc
    style Web fill:#ffcccc
    style Config fill:#ffccff
```

---

## Diagrama de Estado (ValueNotifiers)

```mermaid
stateDiagram-v2
    [*] --> Empty: Aplicación iniciada
    
    Empty --> Loaded: cargarDatos()
    
    Loaded --> CreatingOrder: nuevoProducto()
    
    CreatingOrder --> AddingAdditions: seleccionarAdicionales()
    
    AddingAdditions --> SelectingSalsas: seleccionarSalsas()
    
    SelectingSalsas --> ReviewOrder: revisarPedido()
    
    ReviewOrder --> Confirming: confirmarPedido()
    
    Confirming --> Saving: guardarEnBD()
    
    Saving --> Syncing: iniciarSincronización()
    
    Syncing --> Synced: sincronizaciónCompleta()
    
    Synced --> Loaded: pedidoConfirmado()
    
    CreatingOrder --> Loaded: cancelar()
    AddingAdditions --> CreatingOrder: atrás()
    SelectingSalsas --> AddingAdditions: atrás()
    ReviewOrder --> SelectingSalsas: atrás()
    
    Syncing --> Error: errorSincronización()
    Error --> Syncing: reintentar()
    Error --> Loaded: cancelarSync()

    style Empty fill:#ff9999
    style Loaded fill:#99ff99
    style CreatingOrder fill:#99ccff
    style AddingAdditions fill:#99ccff
    style SelectingSalsas fill:#99ccff
    style ReviewOrder fill:#ffcc99
    style Confirming fill:#ffcc99
    style Saving fill:#ccffcc
    style Syncing fill:#ffffcc
    style Synced fill:#99ff99
    style Error fill:#ff9999
```

---

## Ciclo de Sincronización

```mermaid
flowchart TD
    Start["🔄 Iniciar Sincronización"] --> Check["Verificar conexión"]
    Check -->|Conectado| Pull["⬇️ PULL: Traer cambios"]
    Check -->|Sin conexión| Queue["📝 Encolar cambios"]
    
    Pull --> Merge["🔗 Fusionar datos"]
    Merge --> Push["⬆️ PUSH: Enviar cambios"]
    
    Push --> Success{¿Exitoso?}
    Success -->|Sí| Clean["🧹 Limpiar outbox"]
    Success -->|No| Retry["🔁 Reintentar"]
    
    Retry --> Attempt{¿Max intentos?}
    Attempt -->|No| Merge
    Attempt -->|Sí| Error["❌ Error"]
    
    Queue --> Done["⏸️ Sincronización pendiente"]
    Clean --> Report["📊 Generar reporte"]
    Error --> Report
    Report --> End["✅ Completado"]

    style Start fill:#99ff99
    style Check fill:#99ccff
    style Pull fill:#ccffcc
    style Push fill:#ccffcc
    style Clean fill:#ffcc99
    style Report fill:#ffffcc
    style Error fill:#ff9999
    style End fill:#99ff99
    style Done fill:#ffcccc
```

---

## Arquitectura de Componentes de UI

```mermaid
graph TB
    App["MyApp"]
    Theme["🎨 Material 3 Dark Theme"]
    
    App --> Home["HomeScreen"]
    Home --> AppBar["AppBar - Sync & Settings"]
    Home --> Body["Body: Nodes"]
    
    Nodes --> Categories["📁 Categorías"]
    Categories --> Products["📦 Productos"]
    Products --> ProductCard["Card de Producto"]
    
    ProductCard --> Click["onClick"]
    Click --> AdicionesScreen["Pantalla Adiciones"]
    
    AdicionesScreen --> Additions["Seleccionar Adicionales"]
    Additions --> SalsasScreen["Pantalla Salsas"]
    
    SalsasScreen --> Salsas["Seleccionar Salsas"]
    Salsas --> ComandaScreen["Pantalla Comanda"]
    
    ComandaScreen --> BigOrder["Big Order - Visualizar"]
    BigOrder --> ConfirmScreen["Pantalla Confirmación"]
    
    ConfirmScreen --> PrintButton["🖨️ Imprimir Ticket"]
    ConfirmScreen --> SaveButton["💾 Guardar Venta"]
    
    SaveButton --> DB["BD Local"]
    PrintButton --> Printer["Impresora Térmica"]

    style App fill:#ffcccc
    style Theme fill:#99ccff
    style AppBar fill:#ccffcc
    style Body fill:#ffffcc
    style DB fill:#ccffff
    style Printer fill:#ffccff
```

---

## Dependencias del Proyecto

```mermaid
graph LR
    App["MR CROC App"]
    
    App --> Flutter["📱 Flutter 3.7.2"]
    App --> Dart["🎯 Dart 3.7.2"]
    
    Flutter --> Material["Material Design 3"]
    Flutter --> Responsive["Responsive Builder"]
    Flutter --> Icons["Cupertino Icons"]
    
    App --> Data["Capa de Datos"]
    Data --> SQLite["SQLite - sqflite"]
    Data --> Supabase["Supabase Cloud"]
    
    App --> UI["Componentes UI"]
    UI --> Intl["Intl - Fechas"]
    UI --> Calendar["Calendar Picker"]
    UI --> Charts["Pie Charts"]
    
    App --> Tools["Herramientas"]
    Tools --> PathProv["Path Provider"]
    Tools --> Print["ESC POS Printer"]
    Tools --> Icons2["Icons Launcher"]

    style App fill:#ffcccc
    style Flutter fill:#99ccff
    style Dart fill:#99ff99
    style SQLite fill:#ffcc99
    style Supabase fill:#ffffcc
```

---

## Flujo de Inicialización de la Aplicación

```mermaid
flowchart TD
    A["▶️ main()"] --> B["initialize Database"]
    B --> C["BD SQLite creada/abierta"]
    C --> D["_initSupabase()"]
    D --> E{¿Credenciales<br/>disponibles?}
    E -->|Sí| F["Conectar a Supabase"]
    E -->|No| G["Skipped"]
    F --> H["getRoots()"]
    G --> H
    H --> I["Cargar categorías raíz"]
    I --> J["gerDateNow()"]
    J --> K["Obtener fecha actual"]
    K --> L["getcategoriesdata()"]
    L --> M["Cargar todas categorías"]
    M --> N["getproductsdata()"]
    N --> O["Cargar todos productos"]
    O --> P["getAdditionesData()"]
    P --> Q["Cargar adicionales"]
    Q --> R["runApp MyApp"]
    R --> S["MyApp - Tema configurado"]
    S --> T["HomeScreen"]
    T --> U["✅ App lista para usar"]

    style A fill:#99ff99
    style B fill:#99ccff
    style C fill:#ccffcc
    style D fill:#99ccff
    style E fill:#ffffcc
    style F fill:#ccffcc
    style G fill:#ffcccc
    style U fill:#99ff99
```

---

## Patrones de Diseño Utilizados

```mermaid
graph TB
    MVVM["🏗️ MVVM (Modelo-Vista-ViewModel)"]
    Provider["📌 Provider Pattern"]
    Factory["🏭 Factory Pattern(fromMap)"]
    Singleton["🔐 Singleton (Database)"]
    Observer["👁️ Observer (ValueNotifier)"]
    
    MVVM -->|Separación de responsabilidades| Arch
    Provider -->|Gestión de estado| Arch
    Factory -->|Creación de objetos| Arch
    Singleton -->|Instancia única BD| Arch
    Observer -->|Reactividad| Arch
    
    Arch["✅ Arquitectura Limpia"]
    
    style MVVM fill:#99ccff
    style Provider fill:#99ff99
    style Factory fill:#ffcc99
    style Singleton fill:#ffffcc
    style Observer fill:#ccffcc
    style Arch fill:#ff99cc
```

---

## Matriz de Responsabilidades

```mermaid
graph TB
    Models["📊 Models"]
    Views["🎨 Views/Screens"]
    Services["⚙️ Services"]
    DB["💾 Database"]
    Cloud["☁️ Cloud"]
    
    Views -->|Mostrar| Models
    Views -->|Invocar| Services
    Services -->|Leer/Escribir| DB
    Services -->|Sincronizar| Cloud
    DB -->|Persistir| Data["💿 Datos locales"]
    Cloud -->|Persistir| CloudData["☁️ Datos remotos"]
    
    Models -->|Definir estructura| Data
    Models -->|Definir estructura| CloudData

    style Models fill:#99ff99
    style Views fill:#99ccff
    style Services fill:#ffcc99
    style DB fill:#ccffff
    style Cloud fill:#ffffcc
    style Data fill:#ccffcc
    style CloudData fill:#ccffcc
```

---

## Ciclo de Vida de un Pedido

```mermaid
stateDiagram-v2
    [*] --> Empty
    
    state Creación as Creación del Pedido
    Empty --> Creación: Usuario selecciona producto
    Creación --> Creación: Agregar adicionales
    Creación --> Creación: Agregar salsas
    Creación --> Creación: Ajustar cantidad
    
    Creación --> Cambio as Cambios en Comanda
    Cambio --> Cambio: Modificar cantidad
    Cambio --> Cambio: Eliminar producto
    Cambio --> Cambio: Agregar producto
    
    Cambio --> Revisión: usuario confirma
    Revisión --> Confirmado: Guardar en BD
    
    Confirmado --> Sincronización: Cambios en outbox
    Sincronización --> Sincronizado: Enviar a Supabase
    Sincronización --> Error: Falló sincronización
    
    Error --> Sincronización: Reintentar
    
    Sincronizado --> [*]
    Error --> Manual: Usuario resuelve
    Manual --> [*]

    style Creación fill:#99ccff
    style Cambio fill:#99ccff
    style Revisión fill:#ffcc99
    style Confirmado fill:#ccffcc
    style Sincronización fill:#ffffcc
    style Sincronizado fill:#99ff99
    style Error fill:#ff9999
    style Manual fill:#ffcccc
```

---

## Referencias Cruzadas de Módulos

```mermaid
graph TB
    main["main.dart"]
    db["db_functions.dart"]
    provider["provider_notifier.dart"]
    syncer["sync_service.dart"]
    screens["screens/**"]
    models["models/**"]
    widgets["widgets/**"]
    
    main --> db
    main --> screens
    
    db --> provider
    db --> models
    
    provider --> models
    
    screens --> provider
    screens --> widgets
    screens --> db
    
    syncer --> db
    syncer --> provider
    syncer --> models
    
    widgets --> provider
    widgets --> models

    style main fill:#ff9999
    style db fill:#99ccff
    style provider fill:#99ff99
    style syncer fill:#ffcc99
    style screens fill:#ccffff
    style models fill:#ccffcc
    style widgets fill:#ffffcc
```

---

## Matriz de Tecnologías

| Aspecto | Tecnología | Versión |
|---------|-----------|---------|
| **Framework** | Flutter | ≥3.7.2 |
| **Lenguaje** | Dart | ≥3.7.2 |
| **BD Local** | SQLite | 2.3.0 |
| **BD Cloud** | Supabase | 2.8.0 |
| **Diseño** | Material 3 | Latest |
| **Responsive** | responsive_builder | 0.4.0 |
| **Internacionalización** | intl | 0.19.0 |
| **Gráficos** | pie_chart | 5.4.0 |
| **Impresión** | esc_pos_printer | 0.1.1 |

---

**Última actualización:** 21 de Marzo de 2026

