# GestPro

App móvil de gestión de proyectos y finanzas | Mobile app for project and finance management

---

🇪🇸 **Español**

GestPro es una aplicación Android para gestionar proyectos, tareas, materiales, pagos, cobros, calendario y eventos desde el móvil. Diseñada para autónomos y pequeñas empresas que necesitan controlar su actividad desde el móvil.

## ✨ Funcionalidades

📁 **Gestión de proyectos** — crea y organiza tus proyectos con estado, fechas de inicio y fin  
✅ **Tareas** — lista de tareas por proyecto con seguimiento de completadas y pendientes  
🧱 **Materiales** — registro de materiales con cantidad, precio unitario, total e IVA  
💶 **Economía** — presupuesto, cobrado, pendiente, gastos y beneficio estimado por proyecto  
💸 **Pagos** — control de pagos con estado pagado/pendiente  
🏦 **Cobros** — registro de cobros por proyecto con concepto y fecha  
📊 **Resumen** — dashboard con totales globales, 5 gráficas interactivas y explicaciones  
📅 **Calendario** — vista mensual con eventos de proyectos, pagos, cobros y eventos libres  
🗓️ **Eventos** — crea eventos personalizados directamente desde el calendario  
📄 **PDF** — genera y comparte un resumen en PDF de cada proyecto  
💾 **Backup** — exporta e importa todos los datos en formato JSON  

## 🛠️ Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3 + Dart |
| Base de datos local | Hive |
| Gráficas | fl_chart |
| Calendario | table_calendar |
| PDF | pdf + printing |
| Fuentes | Google Fonts (Inter) |
| Backup | share_plus + file_selector |

## 📁 Estructura del proyecto

```
lib/
├── models/
│   ├── proyecto.dart
│   ├── tarea.dart
│   ├── material_proyecto.dart
│   ├── pago.dart
│   ├── cobro.dart
│   └── evento_calendario.dart
├── screens/
│   ├── home_screen.dart
│   ├── splash_screen.dart
│   ├── proyectos_screen.dart
│   ├── detalle_proyecto_screen.dart
│   ├── tareas_screen.dart
│   ├── materiales_screen.dart
│   ├── economia_screen.dart
│   ├── finanzas_screen.dart
│   ├── pagos_screen.dart
│   ├── cobros_screen.dart
│   ├── estadisticas_screen.dart
│   ├── calendario_screen.dart
│   ├── eventos_dia_screen.dart
│   └── eventos_agrupados_screen.dart
├── services/
│   ├── storage_service.dart
│   ├── backup_service.dart
│   └── pdf_service.dart
├── widgets/
│   ├── tarjeta_evento.dart
│   └── leyenda_calendario.dart
└── main.dart
```

## 🚀 Instalación y arranque

```bash
# Clonar el repositorio
git clone https://github.com/Arocadev/gest-pro
cd gest-pro

# Instalar dependencias
flutter pub get

# Generar adaptadores Hive
dart run build_runner build

# Generar icono
dart run flutter_launcher_icons

# Arrancar la app
flutter run
```

## 📱 Requisitos

- Android 6.0 (API 23) o superior
- Flutter 3.x
- Dart 3.x

## 💾 Backup y restauración de datos

Los datos se almacenan localmente en el dispositivo con Hive. Para no perder los datos al desinstalar la app, usa la función de backup:

- **Exportar** → Pantalla Resumen → menú ··· → Exportar backup
- **Importar** → Pantalla Resumen → menú ··· → Importar backup

---

🇬🇧 **English**

GestPro is an Android app to manage projects, tasks, materials, payments, invoicing, calendar and events from your phone. Designed for freelancers and small companies that need to control their activity on the go.

## ✨ Features

📁 **Project management** — create and organize your projects with status and dates  
✅ **Tasks** — task list per project with completed/pending tracking  
🧱 **Materials** — material registry with quantity, unit price, total and VAT  
💶 **Economy** — budget, collected, pending, expenses and estimated profit per project  
💸 **Payments** — payment tracking with paid/pending status  
🏦 **Invoicing** — invoice registry per project with concept and date  
📊 **Summary** — global dashboard with 5 interactive charts and explanations  
📅 **Calendar** — monthly view with project, payment, invoice and custom events  
🗓️ **Events** — create custom events directly from the calendar  
📄 **PDF** — generate and share a PDF summary of each project  
💾 **Backup** — export and import all data in JSON format  

## 🚀 Getting Started

```bash
git clone https://github.com/Arocadev/gest-pro
cd gest-pro
flutter pub get
dart run build_runner build
flutter run
```

## 👤 Autor / Author

Alejandro Rodríguez Calabuig — [github.com/Arocadev](https://github.com/Arocadev) · [LinkedIn](https://linkedin.com/in/alejandro-rodriguez-calabuig-a871a1230)

## 📄 Licencia / License

Proyecto personal de portfolio. Personal portfolio project.