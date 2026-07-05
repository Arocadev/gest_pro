import 'package:hive/hive.dart';

part 'material_proyecto.g.dart';

@HiveType(typeId: 1)
class MaterialProyecto extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double cantidad;

  @HiveField(2)
  double precioUnidad;

  MaterialProyecto({
    required this.nombre,
    required this.cantidad,
    required this.precioUnidad,
  });

  double get total => cantidad * precioUnidad;

  double get totalConIva => total * 1.21;
}