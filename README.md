<div align="center">

# GestPro

**App móvil de gestión de proyectos y finanzas**  
*Mobile app for project and finance management*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-6.0+-green?logo=android)](https://android.com)
[![Hive](https://img.shields.io/badge/DB-Hive-yellow)](https://pub.dev/packages/hive)

</div>

---

## ¿Qué es GestPro?

GestPro es una aplicación Android diseñada para autónomos y pequeñas empresas que necesitan gestionar proyectos, finanzas y tareas desde el móvil. Nació como proyecto personal de construcción, evolucionó en un encargo freelance para un cliente real, y finalmente se generalizó para adaptarse a cualquier sector.

---

## ✨ Funcionalidades principales

### 📁 Gestión de proyectos
Crea y organiza proyectos con estado (Pendiente / En curso / Terminado), fechas de inicio y fin, y seguimiento completo de tareas y materiales.

### ✅ Tareas con fechas
Lista de tareas por proyecto con fecha de inicio y fecha límite. Las tareas con límite vencido se marcan automáticamente en rojo.

### 🧱 Materiales
Registro de materiales con cantidad, precio unitario, total e IVA (21%). Totales siempre visibles en la parte inferior de la pantalla.

### 💶 Economía
Panel económico por proyecto: presupuesto, cobrado, pendiente de cobro, gastos en materiales y beneficio estimado. Presupuesto y cobrado editables directamente al pulsar.

### 💸 Pagos y cobros
Control de pagos a personas con estado pagado/pendiente, vinculados opcionalmente a proyectos y tareas. Registro de cobros por proyecto con concepto y fecha.

### 📊 Resumen con 5 gráficas
Dashboard global con tarjetas de totales y 5 gráficas interactivas, cada una con botón de información explicativa:

| Gráfica | Tipo | Descripción |
|---------|------|-------------|
| Distribución financiera | Pie | Cobrado, pendiente, gastos y beneficio |
| Comparativa económica | Barras | Comparación de todos los indicadores |
| Estado de proyectos | Donut | Proyectos por estado |
| Top proyectos | Barras | Los 5 proyectos con mayor presupuesto |
| Progreso de tareas | Donut | Tareas completadas vs pendientes |

### 📅 Calendario
Vista mensual con marcadores de colores para inicio/fin de proyectos, inicio/límite de tareas, pagos pendientes, cobros y eventos libres. Resumen de eventos por día, semana y mes.

### 🗓️ Eventos personalizados
Crea eventos directamente desde el calendario para cualquier fecha.

### 📄 PDF profesional
Genera y comparte un resumen en PDF de cada proyecto con diseño profesional: cabecera, resumen económico, tabla de tareas y tabla de materiales con IVA.

### 💾 Backup
Exporta e importa todos los datos en formato JSON para no perder nada al cambiar de dispositivo.

---

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

---

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

---

## 🚀 Instalación y arranque

```bash
git clone https://github.com/Arocadev/gest-pro
cd gest-pro

# Instalar dependencias
flutter pub get

# Generar adaptadores Hive
dart run build_runner build --delete-conflicting-outputs

# Generar icono
dart run flutter_launcher_icons

# Arrancar la app
flutter run

# Generar APK de release
flutter build apk --release
```

---

## 📱 Requisitos

- Android 6.0 (API 23) o superior
- Flutter 3.x
- Dart 3.x

---

## 💾 Backup y restauración de datos

Los datos se almacenan localmente en el dispositivo con Hive. Para no perder los datos al cambiar de dispositivo o desinstalar:

- **Exportar** → Pantalla Resumen → menú ··· → Exportar backup
- **Importar** → Pantalla Resumen → menú ··· → Importar backup

---

## 🗺️ Roadmap

- [ ] Capturas de pantalla y demo en vídeo
- [ ] APK disponible en GitHub Releases
- [ ] Despliegue en aroca.dev

---

## 🌱 Origen del proyecto

GestPro surgió como **ObrasControl**, una app personal para gestionar obras de construcción. Tras desarrollar **Vulldecor Gestiones** como encargo freelance para un cliente real, el proceso reveló que la app original podía generalizarse para cualquier sector — naciendo así GestPro como versión genérica y definitiva.

---

## 👤 Autor

**Alejandro Rodríguez Calabuig**  
[github.com/ArocaDev](https://github.com/ArocaDev) · [LinkedIn](https://www.linkedin.com/in/alejandro-rodriguez-calabuig-a871a1230)

---

## 📄 Licencia

Proyecto personal de portfolio — no licenciado para uso comercial.  
Personal portfolio project — not licensed for commercial use.
