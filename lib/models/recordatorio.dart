import 'package:hive/hive.dart';

part 'recordatorio.g.dart';

@HiveType(typeId: 5)
class Recordatorio extends HiveObject {
  @HiveField(0)
  String titulo;

  @HiveField(1)
  String descripcion;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  bool completado;

  Recordatorio({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.completado = false,
  });
}