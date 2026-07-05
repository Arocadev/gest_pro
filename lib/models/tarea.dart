import 'package:hive/hive.dart';

part 'tarea.g.dart';

@HiveType(typeId: 0)
class Tarea extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  bool hecha;

  @HiveField(2)
  DateTime? fechaInicio;

  @HiveField(3)
  DateTime? fechaLimite;

  Tarea({
    required this.nombre,
    this.hecha = false,
    this.fechaInicio,
    this.fechaLimite,
  });
}