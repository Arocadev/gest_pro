import 'package:hive/hive.dart';

import '../models/cobro.dart';
import '../models/proyecto.dart';
import '../models/pago.dart';

class StorageService {
  static const String proyectosBox = 'proyectos_box';
  static const String pagosBox = 'pagos_box';
  static const String cobrosBox = 'cobros_box';

  static Future<void> guardarProyectos(List<Proyecto> proyectos) async {
    final box = Hive.box<Proyecto>(proyectosBox);
    await box.clear();
    for (final p in proyectos) {
      await box.add(p);
    }
  }

  static List<Proyecto> cargarProyectos() {
    return Hive.box<Proyecto>(proyectosBox).values.toList();
  }

  static Future<void> guardarPagos(List<Pago> pagos) async {
    final box = Hive.box<Pago>(pagosBox);
    await box.clear();
    for (final pago in pagos) {
      await box.add(pago);
    }
  }

  static List<Pago> cargarPagos() {
    return Hive.box<Pago>(pagosBox).values.toList();
  }

  static Future<void> guardarCobros(List<Cobro> cobros) async {
    final box = Hive.box<Cobro>(cobrosBox);
    await box.clear();
    for (final cobro in cobros) {
      await box.add(cobro);
    }
  }

  static List<Cobro> cargarCobros() {
    return Hive.box<Cobro>(cobrosBox).values.toList();
  }
}