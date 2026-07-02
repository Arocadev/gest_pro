import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/obra.dart';

class PdfService {
  static Future<pw.Document> generarObra(
    Obra obra,
  ) async {
    final pdf = pw.Document();

    final materialesTotal =
        obra.materiales.fold(
      0.0,
      (sum, m) => sum + m.total,
    );

    final pendiente =
        obra.presupuesto - obra.cobrado;

    final beneficio =
        obra.presupuesto -
            materialesTotal;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              obra.nombre,
              style: pw.TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Estado: ${obra.estado}',
          ),
          if (obra.fechaInicio != null)
            pw.Text(
              'Fecha inicio: ${obra.fechaInicio!.day}/${obra.fechaInicio!.month}/${obra.fechaInicio!.year}',
            ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Presupuesto: ${obra.presupuesto.toStringAsFixed(2)} EUR',
          ),
          pw.Text(
            'Cobrado: ${obra.cobrado.toStringAsFixed(2)} EUR',
          ),
          pw.Text(
            'Pendiente: ${pendiente.toStringAsFixed(2)} EUR',
          ),
          pw.Text(
            'Beneficio estimado: ${beneficio.toStringAsFixed(2)} EUR',
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Tareas',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
          ...obra.tareas.map(
            (t) => pw.Text(
              '${t.hecha ? "[X]" : "[ ]"} ${t.nombre}',
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Materiales',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
          ...obra.materiales.map(
            (m) => pw.Text(
              '${m.nombre} - ${m.cantidad} x ${m.precioUnidad.toStringAsFixed(2)} EUR = ${m.total.toStringAsFixed(2)} EUR',
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static Future<File> guardarPdf(
    Obra obra,
  ) async {
    final pdf =
        await generarObra(obra);

    final dir =
        await getTemporaryDirectory();

    final file = File(
      '${dir.path}/${obra.nombre}.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    return file;
  }
}