import 'package:hive/hive.dart';

import '../models/cobro.dart';
import '../models/obra.dart';
import '../models/pago.dart';
import '../models/recordatorio.dart';

class StorageService {
  static const String obrasBox = 'obras_box';
  static const String pagosBox = 'pagos_box';
  static const String cobrosBox = 'cobros_box';
  static const String recordatoriosBox = 'recordatorios_box';

  // OBRAS
  static Future<void> guardarObras(List<Obra> obras) async {
    final box = Hive.box<Obra>(obrasBox);
    await box.clear();
    for (final obra in obras) {
      await box.add(obra);
    }
  }

  static List<Obra> cargarObras() {
    return Hive.box<Obra>(obrasBox).values.toList();
  }

  // PAGOS
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

  // COBROS
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

  // RECORDATORIOS
  static List<Recordatorio> cargarRecordatorios() {
    return Hive.box<Recordatorio>(recordatoriosBox).values.toList();
  }
}