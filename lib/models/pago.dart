import 'package:hive/hive.dart';

part 'pago.g.dart';

@HiveType(typeId: 3)
class Pago extends HiveObject {
  @HiveField(0)
  String persona;

  @HiveField(1)
  double importe;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  String? proyectoId;

  @HiveField(4)
  String? tarea;

  @HiveField(5)
  bool pagado;

  Pago({
    required this.persona,
    required this.importe,
    required this.fecha,
    this.proyectoId,
    this.tarea,
    this.pagado = false,
  });
}