import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/proyecto.dart';
import '../models/tarea.dart';
import '../models/material_proyecto.dart';
import 'storage_service.dart';

class BackupService {
  static Future<void> exportarBackup() async {
    final proyectos = StorageService.cargarProyectos();

    final datos = proyectos.map((p) {
      return {
        'nombre': p.nombre,
        'presupuesto': p.presupuesto,
        'cobrado': p.cobrado,
        'estado': p.estado,
        'fechaInicio': p.fechaInicio?.toIso8601String(),
        'fechaFin': p.fechaFin?.toIso8601String(),
        'tareas': p.tareas.map((t) => {
          'nombre': t.nombre,
          'hecha': t.hecha,
        }).toList(),
        'materiales': p.materiales.map((m) => {
          'nombre': m.nombre,
          'cantidad': m.cantidad,
          'precioUnidad': m.precioUnidad,
        }).toList(),
      };
    }).toList();

    final json = const JsonEncoder.withIndent('  ').convert(datos);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/gestpro_backup.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Backup de GestPro',
    );
  }

  static Future<void> importarBackup(String contenido) async {
    final List<dynamic> datos = jsonDecode(contenido);
    final List<Proyecto> proyectos = [];

    for (final item in datos) {
      final tareas = (item['tareas'] as List).map((t) => Tarea(
        nombre: t['nombre'],
        hecha: t['hecha'],
      )).toList();

      final materiales = (item['materiales'] as List).map((m) => MaterialProyecto(
        nombre: m['nombre'],
        cantidad: (m['cantidad'] as num).toDouble(),
        precioUnidad: (m['precioUnidad'] as num).toDouble(),
      )).toList();

      proyectos.add(Proyecto(
        nombre: item['nombre'],
        presupuesto: (item['presupuesto'] as num).toDouble(),
        cobrado: (item['cobrado'] as num).toDouble(),
        estado: item['estado'] ?? 'Pendiente',
        fechaInicio: item['fechaInicio'] != null
            ? DateTime.parse(item['fechaInicio'])
            : null,
        fechaFin: item['fechaFin'] != null
            ? DateTime.parse(item['fechaFin'])
            : null,
        tareas: tareas,
        materiales: materiales,
      ));
    }

    await StorageService.guardarProyectos(proyectos);
  }
}