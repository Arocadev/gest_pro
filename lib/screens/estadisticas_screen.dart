import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/proyecto.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  void _mostrarInfo(BuildContext context, String titulo, String descripcion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          ],
        ),
        content: Text(descripcion, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
        ],
      ),
    );
  }

  Widget _seccionGrafica({
    required BuildContext context,
    required String titulo,
    required String infoTexto,
    required Widget grafica,
    Widget? leyenda,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 4),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.orange, size: 22),
              onPressed: () => _mostrarInfo(context, titulo, infoTexto),
            ),
          ],
        ),
        const SizedBox(height: 12),
        grafica,
        if (leyenda != null) ...[const SizedBox(height: 16), leyenda],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Proyecto> proyectos = StorageService.cargarProyectos();

    final totalProyectos = proyectos.length;
    final presupuesto = proyectos.fold<double>(0, (sum, p) => sum + p.presupuesto);
    final cobrado = proyectos.fold<double>(0, (sum, p) => sum + p.cobrado);
    final pendiente = presupuesto - cobrado;
    final materiales = proyectos.fold<double>(0, (sum, p) =>
        sum + p.materiales.fold(0.0, (s, m) => s + m.total));
    final beneficio = presupuesto - materiales;

    int tareasHechas = 0;
    int tareasPendientes = 0;
    for (final p in proyectos) {
      for (final tarea in p.tareas) {
        if (tarea.hecha) {
          tareasHechas++;
        } else {
          tareasPendientes++;
        }
      }
    }

    final nPendientes = proyectos.where((p) => p.estado == 'Pendiente').length;
    final nEnCurso = proyectos.where((p) => p.estado == 'En curso').length;
    final nTerminados = proyectos.where((p) => p.estado == 'Terminado').length;

    final double maxVal = [presupuesto, cobrado, pendiente, materiales, beneficio > 0 ? beneficio : 0.0]
        .fold<double>(0.0, (a, b) => (a > b ? a : b).toDouble());
    final double intervalo = maxVal <= 1000 ? 200
        : maxVal <= 5000 ? 500
        : maxVal <= 20000 ? 2000
        : maxVal <= 100000 ? 10000
        : 50000;
    final double yLimit = ((maxVal / intervalo).ceil() * intervalo + intervalo).toDouble();

    final proyectosOrdenados = List<Proyecto>.from(proyectos)
      ..sort((a, b) => b.presupuesto.compareTo(a.presupuesto));
    final top5 = proyectosOrdenados.take(5).toList();
    final maxPres = top5.isEmpty ? 1.0 : top5.first.presupuesto;

    Widget tarjetaResumen({
      required String titulo,
      required String valor,
      required String subtitulo,
      required IconData icono,
      required Color color,
    }) {
      return Card(
        elevation: 0.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(titulo, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icono, color: color, size: 34),
                  const SizedBox(width: 8),
                  Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitulo, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    Future<void> importarBackup() async {
      const typeGroup = XTypeGroup(label: 'json', extensions: ['json']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      final contenido = await File(file.path).readAsString();
      await BackupService.importarBackup(contenido);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restaurado correctamente')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        toolbarHeight: 70,
        title: Image.asset('assets/logo.png', height: 90, fit: BoxFit.contain),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'export') {
                  await BackupService.exportarBackup();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup creado')),
                    );
                  }
                }
                if (value == 'import') await importarBackup();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('Exportar backup')),
                PopupMenuItem(value: 'import', child: Text('Importar backup')),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(children: [
            Expanded(child: tarjetaResumen(titulo: 'Total proyectos', valor: '$totalProyectos', subtitulo: 'Proyectos', icono: Icons.folder_open, color: Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(child: tarjetaResumen(titulo: 'Beneficio', valor: '${beneficio.toStringAsFixed(0)} €', subtitulo: 'Estimado', icono: Icons.trending_up, color: Colors.green)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: tarjetaResumen(titulo: 'Presupuesto', valor: '${presupuesto.toStringAsFixed(0)} €', subtitulo: 'Total', icono: Icons.account_balance_wallet, color: Colors.deepPurple)),
            const SizedBox(width: 12),
            Expanded(child: tarjetaResumen(titulo: 'Cobrado', valor: '${cobrado.toStringAsFixed(0)} €', subtitulo: 'Ingresos', icono: Icons.payments, color: Colors.blue)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: tarjetaResumen(titulo: 'Pendiente', valor: '${pendiente.toStringAsFixed(0)} €', subtitulo: 'Por cobrar', icono: Icons.schedule, color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: tarjetaResumen(titulo: 'Materiales', valor: '${materiales.toStringAsFixed(0)} €', subtitulo: 'Gastos', icono: Icons.inventory, color: Colors.red)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: tarjetaResumen(titulo: 'Terminadas', valor: '$tareasHechas', subtitulo: 'Tareas', icono: Icons.check, color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: tarjetaResumen(titulo: 'Pendientes', valor: '$tareasPendientes', subtitulo: 'Tareas', icono: Icons.list, color: Colors.orange)),
          ]),
          const SizedBox(height: 24),

          _seccionGrafica(
            context: context,
            titulo: 'Distribución financiera',
            infoTexto: 'Muestra cómo se distribuye el dinero entre lo cobrado, lo pendiente de cobro, los gastos en materiales y el beneficio estimado. Cuanto mayor sea el sector verde, mejor va el negocio.',
            grafica: SizedBox(
              height: 260,
              child: PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(value: cobrado, color: Colors.blue, title: '', radius: 120),
                  PieChartSectionData(value: pendiente, color: Colors.orange, title: '', radius: 120),
                  PieChartSectionData(value: materiales, color: Colors.red, title: '', radius: 120),
                  PieChartSectionData(value: beneficio > 0 ? beneficio : 0, color: Colors.green, title: '', radius: 120),
                ],
              )),
            ),
            leyenda: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _leyenda(Colors.blue, 'Cobrado'),
                _leyenda(Colors.orange, 'Pendiente'),
                _leyenda(Colors.red, 'Gastos'),
                _leyenda(Colors.green, 'Beneficio'),
              ],
            ),
          ),

          _seccionGrafica(
            context: context,
            titulo: 'Comparativa económica',
            infoTexto: 'Compara en barras verticales el presupuesto total, lo cobrado, lo pendiente, los gastos en materiales y el beneficio estimado.',
            grafica: SizedBox(
              height: 260,
              child: BarChart(BarChartData(
                minY: 0,
                maxY: yLimit,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: presupuesto, color: Colors.deepPurple, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: cobrado, color: Colors.blue, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: pendiente, color: Colors.orange, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: materiales, color: Colors.red, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: beneficio > 0 ? beneficio : 0, color: Colors.green, width: 18, borderRadius: BorderRadius.circular(4))]),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: intervalo,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('0', style: TextStyle(fontSize: 11));
                      if (intervalo >= 1000) return Text('${(value / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 11));
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 11));
                    },
                  )),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const t = ['Pres.', 'Cob.', 'Pend.', 'Gast.', 'Ben.'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(t[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    },
                  )),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: intervalo,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
              )),
            ),
          ),

          _seccionGrafica(
            context: context,
            titulo: 'Estado de proyectos',
            infoTexto: 'Muestra el porcentaje de proyectos según su estado: pendientes, en curso y terminados. Útil para saber cuánta carga de trabajo tienes activa.',
            grafica: SizedBox(
              height: 220,
              child: totalProyectos == 0
                  ? const Center(child: Text('Sin proyectos', style: TextStyle(color: Colors.black38)))
                  : PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: [
                        if (nPendientes > 0) PieChartSectionData(value: nPendientes.toDouble(), color: Colors.grey, title: '$nPendientes', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), radius: 70),
                        if (nEnCurso > 0) PieChartSectionData(value: nEnCurso.toDouble(), color: Colors.orange, title: '$nEnCurso', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), radius: 70),
                        if (nTerminados > 0) PieChartSectionData(value: nTerminados.toDouble(), color: Colors.green, title: '$nTerminados', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), radius: 70),
                      ],
                    )),
            ),
            leyenda: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _leyenda(Colors.grey, 'Pendiente'),
                _leyenda(Colors.orange, 'En curso'),
                _leyenda(Colors.green, 'Terminado'),
              ],
            ),
          ),

          _seccionGrafica(
            context: context,
            titulo: 'Top proyectos por presupuesto',
            infoTexto: 'Muestra los 5 proyectos con mayor presupuesto. Permite identificar rápidamente cuáles son los más importantes económicamente.',
            grafica: top5.isEmpty
                ? const Center(child: Text('Sin proyectos', style: TextStyle(color: Colors.black38)))
                : SizedBox(
                    height: top5.length * 52.0 + 20,
                    child: BarChart(BarChartData(
                      barGroups: top5.asMap().entries.map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [BarChartRodData(toY: e.value.presupuesto, color: Colors.indigo, width: 20, borderRadius: BorderRadius.circular(4))],
                      )).toList(),
                      maxY: maxPres * 1.2,
                      minY: 0,
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= top5.length) return const SizedBox();
                            final nombre = top5[idx].nombre;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(nombre.length > 8 ? '${nombre.substring(0, 8)}.' : nombre, style: const TextStyle(fontSize: 10)),
                            );
                          },
                        )),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    )),
                  ),
          ),

          _seccionGrafica(
            context: context,
            titulo: 'Progreso de tareas',
            infoTexto: 'Muestra el ratio entre tareas completadas y tareas pendientes en todos los proyectos. Un sector verde grande indica buen progreso general.',
            grafica: SizedBox(
              height: 220,
              child: (tareasHechas + tareasPendientes) == 0
                  ? const Center(child: Text('Sin tareas', style: TextStyle(color: Colors.black38)))
                  : PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: [
                        if (tareasHechas > 0) PieChartSectionData(value: tareasHechas.toDouble(), color: Colors.green, title: '$tareasHechas', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), radius: 70),
                        if (tareasPendientes > 0) PieChartSectionData(value: tareasPendientes.toDouble(), color: Colors.orange, title: '$tareasPendientes', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), radius: 70),
                      ],
                    )),
            ),
            leyenda: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _leyenda(Colors.green, 'Completadas'),
                _leyenda(Colors.orange, 'Pendientes'),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}