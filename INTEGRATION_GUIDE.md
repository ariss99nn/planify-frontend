# 📋 Guía de Integración de Features en Planify

## 🏗️ Arquitectura Refactorizada

Tu proyecto Flutter ha sido refactorizado de forma **profesional y escalable**. Aquí está la nueva estructura:

```
lib/
├── config/                          ← NUEVA CARPETA
│   ├── features_exports.dart        ← Todos los imports centralizados
│   ├── app_providers_config.dart    ← Inyección de dependencias
│   ├── app_routes_config.dart       ← Mapeo de todas las rutas
│   └── ... (otros archivos existentes)
├── core/
│   ├── api/
│   ├── theme/
│   └── ... (sin cambios)
├── features/
│   ├── auth/
│   ├── users/
│   ├── aulas/
│   ├── docentes/
│   ├── fichas/
│   ├── alertas/
│   ├── competencias/
│   ├── planificacion/
│   ├── programa/
│   ├── reportes/
│   ├── notificaciones/
│   ├── chatbot/
│   ├── exportacion/
│   ├── analitica/
│   ├── bhorario/
│   └── home/
└── main.dart                        ← REFACTORIZADO (95 líneas)
```

## 📦 Mapeo Completo de Features

### 1. **Auth** - Autenticación
- ✓ 7 Screens (Login, Register, Profile, Edit, Forgot, Reset, Verify)
- ✓ 1 Provider (AuthProvider)
- ✓ Guard para proteger rutas

### 2. **Users** - Gestión de Usuarios
- ✓ 3 Screens (List, Create, Retrieve/Update)
- ✓ 1 Provider (UserProvider)

### 3. **Aulas** - Gestión de Aulas
- ✓ 1 Screen (AulaGestionScreen)
- ✓ 3 Providers (AulaProvider, BloqueProvider, EquipamientoProvider)
- ✓ Detail view incluido

### 4. **Docentes** - Gestión de Docentes
- ✓ 1 Screen (DocenteGestionScreen)
- ✓ 1 Provider (DocenteProvider)

### 5. **Fichas** - Gestión de Fichas
- ✓ 9 Screens (List, Create, Detail, Edit, Estudiante Add, Historial, Reasignaciones)
- ✓ 1 Provider (FichaProvider)

### 6. **Alertas** - Sistema de Alertas
- ✓ 1 Screen (AlertasScreen)
- ✓ 1 Provider (AlertasProvider)
- ✓ Use Cases integrados (ListarAlertas, MarcarLeida)

### 7. **Competencias** - Gestión de Competencias
- ✓ 11 Screens (List, Detail, Form - para Competencias, Asignaturas, RAP)
- ✓ 3 Providers (CompetenciaProvider, AsignaturaProvider, RapProvider)

### 8. **Planificación** - Planificación Académica
- ✓ 4 Screens (List, Form, Detail, ItemForm)
- ✓ 1 Provider (PlanificacionProvider)

### 9. **Programa** - Gestión de Programas
- ✓ 9 Screens (List, Form, Detail - para Programas, Módulos, Versiones)
- ✓ 3 Providers (ProgramaProvider, ModuloProvider, VersionProvider)

### 10. **Reportes** - Sistema de Reportes
- ✓ 3 Screens (Reportes, Novedades, ReporteEstado)
- ✓ 2 Providers (ReporteProvider, NovedadProvider)

### 11. **Notificaciones** - WebSocket Notifications
- ✓ 1 Screen (NotificacionesGestionScreen)
- ✓ 1 Provider (NotificacionesProvider)
- ✓ ProxyProvider para dependencia de Auth

### 12. **Chatbot** - IA Chatbot
- ✓ 1 Screen (ChatScreen)
- ✓ 1 Provider (ChatProvider)
- ✓ Use Cases (SendMessage, ClearConversation)
- ✓ ProxyProvider para token de Auth

### 13. **Exportación** - Exportar Datos
- ✓ 1 Screen (ExportacionGestionScreen)
- ✓ 1 Provider (ExportacionProvider)

### 14. **Analítica** - Datos y Dashboards
- ✓ 1 Screen (AnaliticaGestionScreen)
- ✓ 1 Provider (AnaliticaProvider)
- ✓ Use Cases (GetDashboard, GetSnapshots)

### 15. **Horarios (bhorario)** - Gestión de Horarios
- ✓ 1 Screen (HorarioScreen)
- ✓ 1 Provider (HorarioProvider)

### 16. **Home** - Pantalla de Inicio
- ✓ 1 Screen (HomeScreen)
- ✓ Protegida con AuthGuard

---

## 🔄 Flujo de Inicialización

```dart
main()
  └─> CargarConfig(.env)
  └─> ConfigurarAPI
  └─> runApp(PlanifyApp)
      └─> AppProvidersConfig.build()
          └─> Crear todos los providers (29)
          └─> Inyectar dependencias
          └─> ProxyProviders (Auth, Chatbot, Notificaciones)
      └─> MaterialApp
          └─> AppRoutesConfig.staticRoutes (28 rutas)
          └─> AppRoutesConfig.onGenerateRoute (dinámicas)
```

## 🛣️ Sistema de Rutas

### Rutas Estáticas (sin parámetros)
```
/login, /register, /profile, /edit-profile, /forgot-password
/home, /users, /users/create, /aulas, /horarios, /docentes
/fichas, /fichas/create, /fichas/historial, /fichas/reasignaciones
/alertas, /competencias, /planificacion, /planificacion/create
/programas, /programas/create, /reportes, /novedades
/exportacion, /analitica, /notificaciones, /chatbot
```

### Rutas Dinámicas (con ID)
```
/aulas/<id>                          # Detalle de aula
/users/edit/<id>                     # Editar usuario
/fichas/<id>                         # Detalle de ficha
/fichas/<id>/edit                    # Editar ficha
/fichas/<id>/estudiante              # Agregar estudiante
/programas/<id>                      # Detalle de programa
/programas/<id>/edit                 # Editar programa
/modulos/<id>                        # Detalle de módulo
/modulos/create                      # Crear módulo
/versiones/<id>                      # Detalle de versión
/versiones/create                    # Crear versión
/planificacion/<id>                  # Detalle de plan
/planificacion/<id>/items            # Items del plan
/reportes/<id>                       # Detalle de reporte
```

## 💻 Cómo Usar

### Importar un Screen desde main
```dart
import 'config/features_exports.dart';

// En cualquier parte de la app:
Navigator.pushNamed(context, '/fichas/create');
```

### Acceder a un Provider
```dart
// En un widget:
final fichaProvider = context.read<FichaProvider>();
final fichaWatch = context.watch<FichaProvider>();
```

### Agregar Nueva Feature

1. Crear la carpeta `lib/features/mi_feature/`
2. Agregar screens y providers
3. Actualizar `lib/config/features_exports.dart` con los exports
4. Actualizar `lib/config/app_providers_config.dart` con el provider
5. Actualizar `lib/config/app_routes_config.dart` con las rutas

**Sin tocar main.dart nunca más.**

## 📊 Estadísticas

| Métrica | Cantidad |
|---------|----------|
| Features | 16 |
| Screens | 53 |
| Providers | 29 |
| Rutas Estáticas | 28 |
| Rutas Dinámicas | 12+ |
| Líneas en main.dart | 95 |
| Archivos de Configuración | 3 |

## 🎯 Ventajas de Esta Arquitectura

✅ **DRY** - Sin duplicación de código
✅ **SOLID** - Principios de diseño aplicados
✅ **Escalable** - Fácil de extender
✅ **Mantenible** - Cambios centralizados
✅ **Testeable** - DI clara y aislada
✅ **Legible** - main.dart enfocado
✅ **Performance** - Sin re-instanciaciones innecesarias
✅ **Profesional** - Estructura industrial

## 📖 Referencia Rápida

| Archivo | Responsabilidad |
|---------|-----------------|
| `main.dart` | Punto de entrada, carga config |
| `features_exports.dart` | Centraliza todos los imports |
| `app_providers_config.dart` | Define y configura providers |
| `app_routes_config.dart` | Define todas las rutas |

---

**¿Necesitas agregar una nueva feature? Solo crea los archivos y actualiza los 3 archivos config. ¡No toques main.dart!**
