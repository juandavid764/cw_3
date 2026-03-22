# 📊 Diagramas - Implementación CRUD Salsas

## Arquitectura de Implementación

```mermaid
graph TB
    subgraph "1. Modelo" 
        M["SalsaModel<br/>id, name, price<br/>color, description<br/>activo"]
        DH["Helpers<br/>_colorToHex()<br/>_colorFromHex()"]
    end
    
    subgraph "2. Base de Datos"
        DB["salsas Table<br/>salsa_id, name, price<br/>color, description, activo<br/>uuid, created_at<br/>updated_at, deleted_at"]
        OBSYNC["sync_outbox<br/>(auto-sincronizado)"]
    end
    
    subgraph "3. Funciones BD"
        CREATE["createSalsa()"]
        READ["getSalsasData()<br/>getSalsaById()"]
        UPDATE["updateSalsa()"]
        DELETE["deleteSalsa()"]
    end
    
    subgraph "4. Estado"
        STATE["salsasList<br/>ValueNotifier<br/>List<SalsaModel>"]
    end
    
    subgraph "5. Pantallas UI"
        VIEW["view_salsas.dart<br/>🔴 Color preview<br/>Editar/Eliminar"]
        ADD["add_salsa.dart<br/>Formulario<br/>Color picker"]
        UPDATE["update_salsa.dart<br/>Pre-llenado<br/>Color picker"]
    end
    
    M --> CREATE
    M --> READ
    M --> UPDATE
    M --> DELETE
    
    CREATE --> DB
    READ --> DB
    UPDATE --> DB
    DELETE --> DB
    
    CREATE --> OBSYNC
    UPDATE --> OBSYNC
    DELETE --> OBSYNC
    
    READ --> STATE
    CREATE --> STATE
    UPDATE --> STATE
    DELETE --> STATE
    
    VIEW --> STATE
    ADD --> CREATE
    UPDATE --> UPDATE
    VIEW --> DELETE

    style M fill:#99ff99
    style DB fill:#ccffcc
    style CREATE fill:#99ccff
    style STATE fill:#ffcc99
    style VIEW fill:#ff99cc
```

## Flujo de Datos: Crear Salsa

```mermaid
sequenceDiagram
    participant User as 👤 Usuario
    participant UI as 🎨 add_salsa.dart
    participant State as 🔔 salsasList
    participant DB as 💾 BD Local
    participant Outbox as 📦 sync_outbox
    participant Cloud as ☁️ Supabase

    User->>UI: Input: Nombre, Precio, Color
    UI->>UI: Validar formulario
    
    User->>UI: Clickear Guardar
    UI->>DB: createSalsa()
    Note over DB: Genera UUID y timestamp
    DB->>DB: INSERT INTO salsas
    DB->>Outbox: INSERT sync_outbox (INSERT op)
    
    DB->>State: Actualiza salsasList
    State->>UI: ValueNotifier notifica cambio
    UI->>UI: Pop y mostrar SnackBar ✅
    
    Note over Cloud: SyncService (background)
    Outbox->>Cloud: PUSH cambios a Supabase
    Cloud->>Outbox: ✅ Confirmación
    Outbox->>Outbox: Limpiar entrada
    
    style User fill:#ffcccc
    style UI fill:#99ccff
    style State fill:#ffcc99
    style DB fill:#ccffcc
    style Cloud fill:#ffffcc
```

## Flujo de Datos: Editar Salsa

```mermaid
sequenceDiagram
    participant User as 👤 Usuario
    participant UI as 🎨 update_salsa.dart
    participant State as 🔔 salsasList
    participant DB as 💾 BD Local
    participant Outbox as 📦 sync_outbox

    User->>UI: Pre-llena datos (fromMap)
    User->>UI: Modifica campos
    
    User->>UI: Clickear Guardar
    UI->>DB: updateSalsa(id, nuevos datos)
    DB->>DB: UPDATE salsas WHERE salsa_id
    DB->>Outbox: INSERT sync_outbox (UPDATE op)
    
    DB->>State: Recarga getSalsasData()
    State->>UI: ValueNotifier notifica
    UI->>UI: Pop y SnackBar ✅
    
    Note over Outbox: SyncService sincroniza automáticamente
```

## Flujo de Datos: Eliminar Salsa

```mermaid
sequenceDiagram
    participant User as 👤 Usuario
    participant UI as 🎨 view_salsas.dart
    participant Dialog as 🔔 AlertDialog
    participant DB as 💾 BD Local
    participant Outbox as 📦 sync_outbox

    User->>UI: Click ícono 🗑️
    UI->>Dialog: Mostrar confirmación
    
    User->>Dialog: Confirmar
    Dialog->>DB: deleteSalsa(id)
    Note over DB: Soft Delete<br/>(UPDATE con deleted_at)
    DB->>DB: UPDATE salsas SET deleted_at=NOW()
    DB->>Outbox: INSERT sync_outbox (DELETE op)
    
    DB->>UI: Recarga getSalsasData()
    UI->>UI: Quita de lista (Soft delete<br/>no la retorna)
    UI->>UI: SnackBar ✅
    
    Note over Outbox: SyncService marcará en Supabase
```

## Estados de Sincronización

```mermaid
stateDiagram-v2
    [*] --> Local: CREATE/UPDATE/DELETE
    
    Local --> Outbox: Registrado en<br/>sync_outbox
    Note right of Outbox: operation='insert'/'update'/'delete'
    
    Outbox --> Syncing: SyncService<br/>detecta cambios
    Syncing --> Synced: ✅ Push exitoso<br/>a Supabase
    
    Syncing --> Error: ❌ Error<br/>de red/BD
    Error --> Retry: Reintentar<br/>(max 3 intentos)
    Retry --> Syncing
    Retry --> Failed: Agotados<br/>intentos
    
    Synced --> Clean: Limpiar<br/>sync_outbox
    Clean --> [*]
    
    Failed --> Manual: Admin revisa<br/>en Supabase
    Manual --> [*]

    style Local fill:#ccffcc
    style Outbox fill:#ffcc99
    style Syncing fill:#ffffcc
    style Synced fill:#99ff99
    style Error fill:#ff9999
    style Failed fill:#ff0000
```

## Estructura de Carpetas Nueva

```mermaid
graph TB
    CRUDDB["lib/screens/crud-db/"]
    
    CRUDDB --> Existing["📄 Existentes:<br/>add_product.dart<br/>edit_page.dart<br/>password_page.dart<br/>etc."]
    
    CRUDDB --> NewSalsas["🆕 Nuevos:<br/>view_salsas.dart<br/>add_salsa.dart<br/>update_salsa.dart"]
    
    style NewSalsas fill:#ccffcc
    style Existing fill:#cccccc
```

## Conversiones: Precio y Color

```mermaid
graph LR
    Input["Entrada<br/>del Usuario"]
    
    subgraph "UI → BD"
        Precio["5.99 USD"]
        Centavos[" × 100 = 599"]
        Color["Red Color"]
        Hex["#FF0000"]
    end
    
    subgraph "BD → UI"
        Centavos2["599 centavos"]
        Precio2[" ÷ 100 = 5.99"]
        Hex2["#FF0000"]
        RenderColor["Render Red"]
    end
    
    Input --> Precio
    Precio --> Centavos
    Input --> Color
    Color --> Hex
    
    Centavos --> DB["💾<br/>BD Local"]
    Hex --> DB
    
    DB --> Centavos2
    DB --> Hex2
    Centavos2 --> Precio2
    Hex2 --> RenderColor
    
    Precio2 --> Output["✅ Usuario ve 5.99"]
    RenderColor --> Output
    
    style DB fill:#ffcc99
    style Output fill:#99ff99
```

## Validación de Datos

```mermaid
graph TD
    User["👤 Entrada<br/>Usuario"]
    
    User --> Validate["🔍 Validar en<br/>formulario"]
    
    Validate --> CheckName{"¿Nombre<br/>válido?"}
    CheckName -->|No| ErrName["❌ Error:<br/>Ingresa nombre"]
    ErrName --> User
    
    CheckName -->|Sí| CheckPrice{"¿Precio > 0<br/>y < 10000?"}
    CheckPrice -->|No| ErrPrice["❌ Error:<br/>Precio inválido"]
    ErrPrice --> User
    
    CheckPrice -->|Sí| CheckColor{"¿Color<br/>seleccionado?"}
    CheckColor -->|No| ErrColor["❌ Error:<br/>Selecciona color"]
    ErrColor --> User
    
    CheckColor -->|Sí| ToDB["✅ Enviar a BD"]
    ToDB --> DB["💾 INSERT/UPDATE<br/>en salsas"]
    DB --> Success["✅ OK<br/>Pop & SnackBar"]
    
    style User fill:#ffcccc
    style Validate fill:#ffffcc
    style ToDB fill:#ccffcc
    style Success fill:#99ff99
```

## Dependencia: flutter_colorpicker

```mermaid
graph LR
    App["App"]
    App --> FC["flutter_colorpicker<br/>v1.0.3"]
    
    FC --> CP["ColorPicker<br/>widget"]
    FC --> Color["Utilities<br/>para colores"]
    
    CP --> UI["Dialog en<br/>add/update<br/>_salsa.dart"]
    
    Color --> Conv["Conversión<br/>Color ↔ Hex"]
    
    style FC fill:#99ccff
    style CP fill:#ccffcc
```

## Timeline: Cronograma

```mermaid
gantt
    title Implementación CRUD Salsas
    dateFormat YYYY-MM-DD
    
    section Desarrollo
    Backend (Modelo + BD)           :backend, 2026-03-21, 2h
    Funciones DB                    :dbfunc, after backend, 3h
    State (ValueNotifier)           :state, after dbfunc, 30m
    UI - view_salsas.dart           :view, after state, 1h
    UI - add_salsa.dart             :add, after view, 1.5h
    UI - update_salsa.dart          :upd, after add, 1.5h
    Integración                     :integ, after upd, 1h
    
    section Testing
    Test Create                     :test1, after integ, 30m
    Test Read                       :test2, after test1, 30m
    Test Update                     :test3, after test2, 30m
    Test Delete                     :test4, after test3, 30m
    Test Sync                       :test5, after test4, 1h
```

## Patrón CRUD: Comparación con Productos

```mermaid
graph TB
    subgraph "Productos"
        P1["ViewProducts → view_products.dart"]
        P2["AddProduct → add_product.dart"]
        P3["UpdateProduct → update_product.dart"]
        
        PDB["createProduct()<br/>getproductsdata()<br/>updateProduct()<br/>deleteProduct()"]
        PModel["ProductModel"]
    end
    
    subgraph "Salsas (Mismo Patrón)"
        S1["ViewSalsas → view_salsas.dart"]
        S2["AddSalsa → add_salsa.dart"]
        S3["UpdateSalsa → update_salsa.dart"]
        
        SDB["createSalsa()<br/>getSalsasData()<br/>updateSalsa()<br/>deleteSalsa()"]
        SModel["SalsaModel"]
    end
    
    P1 -.Patrón similar.- S1
    P2 -.Patrón similar.- S2
    P3 -.Patrón similar.- S3
    PDB -.Patrón similar.- SDB
    PModel -.Patrón similar.- SModel
    
    style S1 fill:#ccffcc
    style S2 fill:#ccffcc
    style S3 fill:#ccffcc
    style SDB fill:#ccffcc
    style SModel fill:#ccffcc
```

## Integración en Menú CRUD

```mermaid
graph TD
    Home["HomeScreen"]
    Home --> Settings["⚙️ Settings<br/>Password Protected"]
    
    Settings --> CRUD["Edit Page<br/>(CRUD Menu)"]
    
    CRUD --> Products["📦 Productos"]
    CRUD --> Categories["📁 Categorías"]
    CRUD --> Additions["➕ Adiciones"]
    CRUD --> Salsas["🌶️ Salsas (NEW!)"]
    
    Salsas --> ViewSalsas["ViewSalsas<br/>(Listar)"]
    ViewSalsas --> AddSalsa["AddSalsa<br/>(Crear)"]
    ViewSalsas --> UpdateSalsa["UpdateSalsa<br/>(Editar)"]
    ViewSalsas --> Delete["DeleteSalsa<br/>(Eliminar)"]
    
    style Salsas fill:#ccffcc
    style ViewSalsas fill:#ccffcc
    style AddSalsa fill:#ccffcc
    style UpdateSalsa fill:#ccffcc
```

## Data Flow: Toda la Arquitectura

```mermaid
graph TB
    subgraph "UI"
        VS["ViewSalsas<br/>(listView)"]
        AS["AddSalsa<br/>(formulario)"]
        US["UpdateSalsa<br/>(formulario)"]
    end
    
    subgraph "Estado"
        SL["salsasList<br/>ValueNotifier"]
    end
    
    subgraph "Lógica BD"
        GSD["getSalsasData()"]
        CS["createSalsa()"]
        US2["updateSalsa()"]
        DS["deleteSalsa()"]
    end
    
    subgraph "Persistencia"
        SQDB["SQLite<br/>salsas table"]
        OB["sync_outbox"]
    end
    
    subgraph "Sincronización"
        SS["SyncService"]
        SB["Supabase"]
    end
    
    VS -->|listener| SL
    AS -->|onChange| CS
    US -->|onChange| US2
    VS -->|onClick delete| DS
    
    CS -->|INSERT| SQDB
    US2 -->|UPDATE| SQDB
    DS -->|UPDATE soft del| SQDB
    
    CS -->|INSERT| OB
    US2 -->|INSERT| OB
    DS -->|INSERT| OB
    
    GSD -->|carga| SQDB
    SQDB -->|notifica| SL
    
    OB -->|detecta| SS
    SS -->|PUSH| SB
    SB -->|confirmación| OB
    
    style VS fill:#99ccff
    style AS fill:#99ccff
    style US fill:#99ccff
    style SL fill:#ffcc99
    style CS fill:#ccffcc
    style SQDB fill:#ccffcc
    style OB fill:#ffcccc
    style SS fill:#ffffcc
    style SB fill:#ffffcc
```

---

**Diagramas creados:** 21 de Marzo de 2026  
**Listos para referencia: ✅**

