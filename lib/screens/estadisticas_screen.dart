import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/obra.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Obra> obras = StorageService.cargarObras();

    final totalObras = obras.length;
    final presupuesto = obras.fold<double>(0, (sum, obra) => sum + obra.presupuesto);
    final cobrado = obras.fold<double>(0, (sum, obra) => sum + obra.cobrado);
    final pendiente = presupuesto - cobrado;
    final materiales = obras.fold<double>(0, (sum, obra) {
      final totalObra = obra.materiales.fold(0.0, (s, m) => s + m.total);
      return sum + totalObra;
    });
    final beneficio = presupuesto - materiales;

    int tareasHechas = 0;
    int tareasPendientes = 0;
    for (final obra in obras) {
      for (final tarea in obra.tareas) {
        if (tarea.hecha) {
          tareasHechas++;
        } else {
          tareasPendientes++;
        }
      }
    }

    final double maxY = [presupuesto, cobrado, pendiente, materiales, beneficio]
        .fold(0.0, (a, b) => a > b ? a : b);
    final double yLimit = ((maxY / 2000).ceil() * 2000 + 2000).toDouble();

    Widget leyenda(Color color, String texto) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

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
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icono, color: color, size: 34),
                  const SizedBox(width: 8),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
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
        title: const Text(
          'Resumen',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
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
                if (value == 'import') {
                  await importarBackup();
                }
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
          Row(
            children: [
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Total obras',
                  valor: '$totalObras',
                  subtitulo: 'Obras',
                  icono: Icons.home_work,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Beneficio',
                  valor: '${beneficio.toStringAsFixed(0)} €',
                  subtitulo: 'Estimado',
                  icono: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Presupuesto',
                  valor: '${presupuesto.toStringAsFixed(0)} €',
                  subtitulo: 'Total',
                  icono: Icons.account_balance_wallet,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Cobrado',
                  valor: '${cobrado.toStringAsFixed(0)} €',
                  subtitulo: 'Ingresos',
                  icono: Icons.payments,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Pendiente',
                  valor: '${pendiente.toStringAsFixed(0)} €',
                  subtitulo: 'Por cobrar',
                  icono: Icons.schedule,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Materiales',
                  valor: '${materiales.toStringAsFixed(0)} €',
                  subtitulo: 'Gastos',
                  icono: Icons.inventory,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Terminadas',
                  valor: '$tareasHechas',
                  subtitulo: 'Tareas',
                  icono: Icons.check,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: tarjetaResumen(
                  titulo: 'Pendientes',
                  valor: '$tareasPendientes',
                  subtitulo: 'Tareas',
                  icono: Icons.list,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Gráficas',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(value: cobrado, color: Colors.blue, title: '', radius: 120),
                  PieChartSectionData(value: pendiente, color: Colors.orange, title: '', radius: 120),
                  PieChartSectionData(value: materiales, color: Colors.red, title: '', radius: 120),
                  PieChartSectionData(value: beneficio, color: Colors.green, title: '', radius: 120),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              leyenda(Colors.blue, 'Cobrado'),
              leyenda(Colors.orange, 'Pendiente'),
              leyenda(Colors.red, 'Gastos'),
              leyenda(Colors.green, 'Beneficio'),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: yLimit,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: presupuesto, color: Colors.deepPurple, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: cobrado, color: Colors.blue, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: pendiente, color: Colors.orange, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: materiales, color: Colors.red, width: 18, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: beneficio, color: Colors.green, width: 18, borderRadius: BorderRadius.circular(4))]),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: 2000,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0', style: TextStyle(fontSize: 11));
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const t = ['Pres.', 'Cob.', 'Pend.', 'Gast.', 'Ben.'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(t[value.toInt()], style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}