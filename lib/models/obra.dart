import 'material_obra.dart';
import 'tarea.dart';

class Obra {
  String nombre;
  double presupuesto;
  double cobrado;
  List<Tarea> tareas;
  List<MaterialObra> materiales;

  Obra({
    required this.nombre,
    this.presupuesto = 0,
    this.cobrado = 0,
    List<Tarea>? tareas,
    List<MaterialObra>? materiales,
  })  : tareas = tareas ?? [],
        materiales = materiales ?? [];
}