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

    final presupuesto = obras.fold<double>(
      0,
      (sum, obra) => sum + obra.presupuesto,
    );

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

    Widget tarjetaResumen({
      required String titulo,
      required String valor,
      required String subtitulo,
      required IconData icono,
      required Color color,
    }) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    color.withValues(
                      alpha: 0.15,
                    ),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valor,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
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

      if (file == null) {
        return;
      }

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
        title: const Text('Resumen'),
        actions: [
          PopupMenuButton<String>(
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
          const SizedBox(height: 30),
          const Text(
            'Gráficas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: cobrado,
                    color: Colors.blue,
                    title: 'Cob.',
                  ),
                  PieChartSectionData(
                    value: pendiente,
                    color: Colors.orange,
                    title: 'Pend.',
                  ),
                  PieChartSectionData(
                    value: materiales,
                    color: Colors.red,
                    title: 'Gast.',
                  ),
                  PieChartSectionData(
                    value: beneficio,
                    color: Colors.green,
                    title: 'Ben.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: presupuesto,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: cobrado, color: Colors.blue),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: pendiente, color: Colors.orange),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: materiales, color: Colors.red),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(toY: beneficio, color: Colors.green),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const t = ['Pres.', 'Cob.', 'Pend.', 'Gast.', 'Ben.'];

                        return Text(t[value.toInt()]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
