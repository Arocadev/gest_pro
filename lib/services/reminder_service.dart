import 'package:hive/hive.dart';

import '../models/recordatorio.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class ReminderService {
  static List<Recordatorio> cargar() {
    final box = Hive.box<Recordatorio>(StorageService.recordatoriosBox);
    return box.values.toList();
  }

  static Future<void> guardar(Recordatorio r) async {
    final box = Hive.box<Recordatorio>(StorageService.recordatoriosBox);
    await box.add(r);

    final baseId = DateTime.now().millisecondsSinceEpoch % 1000000000;

    if (r.avisarDiaAntes) {
      final fecha = r.fecha.subtract(const Duration(days: 1));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: baseId,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'Mañana tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.avisar6HorasAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 6));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: baseId + 1,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'En 6 horas tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.avisar1HoraAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 1));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: baseId + 2,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'En 1 hora tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.fecha.isAfter(DateTime.now())) {
      await NotificationService.programarNotificacion(
        id: baseId + 3,
        titulo: '📋 ${r.titulo}',
        cuerpo: r.descripcion.isNotEmpty
            ? r.descripcion
            : 'Es la hora de tu recordatorio',
        fecha: r.fecha,
      );
    }
  }

  static Future<void> eliminar(int index) async {
    final box = Hive.box<Recordatorio>(StorageService.recordatoriosBox);
    await box.deleteAt(index);
  }

  static Future<void> actualizar(int index, Recordatorio r) async {
    final box = Hive.box<Recordatorio>(StorageService.recordatoriosBox);

    final baseId = index * 10;
    await NotificationService.cancelar(baseId);
    await NotificationService.cancelar(baseId + 1);
    await NotificationService.cancelar(baseId + 2);
    await NotificationService.cancelar(baseId + 3);

    await box.putAt(index, r);

    final newBaseId = DateTime.now().millisecondsSinceEpoch % 1000000000;

    if (r.avisarDiaAntes) {
      final fecha = r.fecha.subtract(const Duration(days: 1));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: newBaseId,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'Mañana tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.avisar6HorasAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 6));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: newBaseId + 1,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'En 6 horas tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.avisar1HoraAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 1));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: newBaseId + 2,
          titulo: '📋 ${r.titulo}',
          cuerpo: 'En 1 hora tienes un recordatorio',
          fecha: fecha,
        );
      }
    }

    if (r.fecha.isAfter(DateTime.now())) {
      await NotificationService.programarNotificacion(
        id: newBaseId + 3,
        titulo: '📋 ${r.titulo}',
        cuerpo: r.descripcion.isNotEmpty
            ? r.descripcion
            : 'Es la hora de tu recordatorio',
        fecha: r.fecha,
      );
    }
  }
}