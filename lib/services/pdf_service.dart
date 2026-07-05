import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/proyecto.dart';

class PdfService {
  static final _colorPrimario = PdfColor.fromHex('1E3A5F');
  static final _colorAcento = PdfColor.fromHex('2E86AB');
  static final _colorFondo = PdfColor.fromHex('F5F7FA');
  static final _colorVerde = PdfColor.fromHex('27AE60');
  static final _colorNaranja = PdfColor.fromHex('E67E22');
  static final _colorRojo = PdfColor.fromHex('E74C3C');

  static String _fecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  static Future<pw.Document> generarProyecto(Proyecto proyecto) async {
    final pdf = pw.Document();

    final materialesTotal = proyecto.materiales.fold(0.0, (sum, m) => sum + m.total);
    final pendiente = proyecto.presupuesto - proyecto.cobrado;
    final beneficio = proyecto.cobrado - materialesTotal;
    final tareasHechas = proyecto.tareas.where((t) => t.hecha).length;
    final tareasTotales = proyecto.tareas.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [

          // CABECERA
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: _colorPrimario,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'GestPro',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      proyecto.nombre,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    proyecto.estado,
                    style: pw.TextStyle(
                      color: _colorPrimario,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // FECHAS
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _colorFondo,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Fecha inicio',
                          style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(_fecha(proyecto.fechaInicio),
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Fecha fin',
                          style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(_fecha(proyecto.fechaFin),
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tareas',
                          style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('$tareasHechas / $tareasTotales completadas',
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // RESUMEN ECONÓMICO
          pw.Text(
            'Resumen económico',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _colorPrimario,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _tarjetaEconomica('Presupuesto', '${proyecto.presupuesto.toStringAsFixed(2)} €', _colorAcento),
              pw.SizedBox(width: 8),
              _tarjetaEconomica('Cobrado', '${proyecto.cobrado.toStringAsFixed(2)} €', _colorVerde),
              pw.SizedBox(width: 8),
              _tarjetaEconomica('Pendiente', '${pendiente.toStringAsFixed(2)} €', _colorNaranja),
              pw.SizedBox(width: 8),
              _tarjetaEconomica('Beneficio', '${beneficio.toStringAsFixed(2)} €',
                  beneficio >= 0 ? _colorVerde : _colorRojo),
            ],
          ),

          pw.SizedBox(height: 24),

          // TAREAS
          if (proyecto.tareas.isNotEmpty) ...[
            pw.Text(
              'Tareas',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _colorPrimario,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _colorPrimario),
                  children: [
                    _celdaHeader('Tarea'),
                    _celdaHeader('Estado'),
                  ],
                ),
                ...proyecto.tareas.map((t) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: proyecto.tareas.indexOf(t) % 2 == 0
                        ? PdfColors.white
                        : _colorFondo,
                  ),
                  children: [
                    _celda(t.nombre),
                    _celda(t.hecha ? '✓ Completada' : 'Pendiente',
                        color: t.hecha ? _colorVerde : _colorNaranja),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // MATERIALES
          if (proyecto.materiales.isNotEmpty) ...[
            pw.Text(
              'Materiales',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _colorPrimario,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _colorPrimario),
                  children: [
                    _celdaHeader('Material'),
                    _celdaHeader('Cantidad'),
                    _celdaHeader('Precio/u'),
                    _celdaHeader('Total'),
                    _celdaHeader('Total + IVA'),
                  ],
                ),
                ...proyecto.materiales.map((m) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: proyecto.materiales.indexOf(m) % 2 == 0
                        ? PdfColors.white
                        : _colorFondo,
                  ),
                  children: [
                    _celda(m.nombre),
                    _celda('${m.cantidad}'),
                    _celda('${m.precioUnidad.toStringAsFixed(2)} €'),
                    _celda('${m.total.toStringAsFixed(2)} €'),
                    _celda('${m.totalConIva.toStringAsFixed(2)} €'),
                  ],
                )),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _colorFondo),
                  children: [
                    _celdaHeader('TOTAL', align: pw.TextAlign.right),
                    _celda(''),
                    _celda(''),
                    _celdaHeader('${materialesTotal.toStringAsFixed(2)} €'),
                    _celdaHeader('${(materialesTotal * 1.21).toStringAsFixed(2)} €'),
                  ],
                ),
              ],
            ),
          ],

          pw.SizedBox(height: 30),

          // PIE
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generado con GestPro · Gestión de todo, en un solo lugar',
            style: pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _tarjetaEconomica(String titulo, String valor, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(titulo,
                style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
            pw.SizedBox(height: 4),
            pw.Text(valor,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _celdaHeader(String texto,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _celda(String texto, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 10,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static Future<File> guardarPdf(Proyecto proyecto) async {
    final pdf = await generarProyecto(proyecto);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${proyecto.nombre}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}