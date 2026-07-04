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
          titulo: 'Recordatorio mañana',
          cuerpo: r.titulo,
          fecha: fecha,
        );
      }
    }

    if (r.avisar6HorasAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 6));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: baseId + 1,
          titulo: 'Recordatorio en 6 horas',
          cuerpo: r.titulo,
          fecha: fecha,
        );
      }
    }

    if (r.avisar1HoraAntes) {
      final fecha = r.fecha.subtract(const Duration(hours: 1));
      if (fecha.isAfter(DateTime.now())) {
        await NotificationService.programarNotificacion(
          id: baseId + 2,
          titulo: 'Recordatorio en 1 hora',
          cuerpo: r.titulo,
          fecha: fecha,
        );
      }
    }

    if (r.fecha.isAfter(DateTime.now())) {
      await NotificationService.programarNotificacion(
        id: baseId + 3,
        titulo: 'Recordatorio',
        cuerpo: r.titulo,
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
    await box.putAt(index, r);
  }
}