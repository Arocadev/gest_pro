import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
        InitializationSettings(
      android: android,
    );

    await _notifications.initialize(
      settings,
    );
  }

  static Future<void>
      mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const detalles =
        NotificationDetails(
      android:
          AndroidNotificationDetails(
        'obras_channel',
        'ObraControl',
        channelDescription:
            'Avisos y recordatorios',
        importance:
            Importance.max,
        priority:
            Priority.high,
      ),
    );

    await _notifications.show(
      id,
      titulo,
      cuerpo,
      detalles,
    );
  }

  static Future<void>
      cancelar(int id) async {
    await _notifications.cancel(
      id,
    );
  }

  static Future<void>
      cancelarTodas() async {
    await _notifications
        .cancelAll();
  }
}