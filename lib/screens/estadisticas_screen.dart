import 'package:flutter/material.dart';

import '../models/obra.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<Obra> obras =
        StorageService.cargarObras();

    final totalObras =
        obras.length;

    final presupuesto =
        obras.fold<double>(
      0,
      (sum, obra) =>
          sum + obra.presupuesto,
    );

    final cobrado =
        obras.fold<double>(
      0,
      (sum, obra) =>
          sum + obra.cobrado,
    );

    final pendiente =
        presupuesto - cobrado;

    final materiales =
        obras.fold<double>(
      0,
      (sum, obra) {
        final totalObra =
            obra.materiales.fold(
          0.0,
          (s, m) =>
              s + m.total,
        );

        return sum + totalObra;
      },
    );

    final beneficio =
        presupuesto - materiales;

    int tareasHechas = 0;
    int tareasPendientes = 0;

    for (final obra in obras) {
      for (final tarea
          in obra.tareas) {
        if (tarea.hecha) {
          tareasHechas++;
        } else {
          tareasPendientes++;
        }
      }
    }

    Widget tarjeta(
      String titulo,
      String valor,
      IconData icono,
    ) {
      return Card(
        child: ListTile(
          leading: Icon(icono),
          title: Text(titulo),
          subtitle: Text(
            valor,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Estadísticas',
        ),
        actions: [
          IconButton(
            icon:
                const Icon(
              Icons.backup,
            ),
            tooltip:
                'Crear backup',
            onPressed: () async {
              await BackupService
                  .exportarBackup();

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Backup creado',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(
          12,
        ),
        children: [
          tarjeta(
            'Obras',
            '$totalObras',
            Icons.home_work,
          ),
          tarjeta(
            'Presupuesto',
            '${presupuesto.toStringAsFixed(2)} EUR',
            Icons.account_balance_wallet,
          ),
          tarjeta(
            'Cobrado',
            '${cobrado.toStringAsFixed(2)} EUR',
            Icons.payments,
          ),
          tarjeta(
            'Pendiente',
            '${pendiente.toStringAsFixed(2)} EUR',
            Icons.schedule,
          ),
          tarjeta(
            'Materiales',
            '${materiales.toStringAsFixed(2)} EUR',
            Icons.inventory,
          ),
          tarjeta(
            'Beneficio estimado',
            '${beneficio.toStringAsFixed(2)} EUR',
            Icons.trending_up,
          ),
          tarjeta(
            'Tareas terminadas',
            '$tareasHechas',
            Icons.check_circle,
          ),
          tarjeta(
            'Tareas pendientes',
            '$tareasPendientes',
            Icons.pending_actions,
          ),
        ],
      ),
    );
  }
}