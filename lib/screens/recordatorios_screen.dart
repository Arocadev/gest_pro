import 'package:flutter/material.dart';

import '../models/recordatorio.dart';
import '../services/reminder_service.dart';
import 'formulario_recordatorio_screen.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  List<Recordatorio> recordatorios = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() {
    final lista = ReminderService.cargar();
    lista.sort((a, b) => a.fecha.compareTo(b.fecha));
    setState(() => recordatorios = lista);
  }

  Future<void> eliminarCompletados() async {
    final lista = ReminderService.cargar();
    for (int i = lista.length - 1; i >= 0; i--) {
      if (lista[i].completado) await ReminderService.eliminar(i);
    }
    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          'Recordatorios',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'borrar') await eliminarCompletados();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'borrar', child: Text('Eliminar completados')),
              ],
            ),
          ),
        ],
      ),
      body: recordatorios.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Sin recordatorios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: recordatorios.length,
              itemBuilder: (context, index) {
                final r = recordatorios[index];
                final vencido = !r.completado && r.fecha.isBefore(DateTime.now());

                return Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    onTap: () {
                      if (r.descripcion.trim().isEmpty) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(r.titulo),
                          content: Text(r.descripcion),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Icon(
                      r.completado ? Icons.check_circle : Icons.notifications,
                      color: r.completado ? Colors.green : Colors.purple,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.titulo,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              decoration: r.completado ? TextDecoration.lineThrough : null,
                              color: r.completado ? Colors.grey.shade500 : Colors.black87,
                            ),
                          ),
                        ),
                        if (vencido)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Vencido',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${r.fecha.day.toString().padLeft(2, '0')}/'
                        '${r.fecha.month.toString().padLeft(2, '0')}/'
                        '${r.fecha.year} · '
                        '${r.fecha.hour.toString().padLeft(2, '0')}:'
                        '${r.fecha.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      onSelected: (value) async {
                        if (value == 'completar') {
                          r.completado = !r.completado;
                          await r.save();
                          if (!context.mounted) return;
                          cargar();
                        }
                        if (value == 'eliminar') {
                          await ReminderService.eliminar(index);
                          if (!context.mounted) return;
                          cargar();
                        }
                        if (value == 'editar') {
                          final editado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormularioRecordatorioScreen(
                                recordatorio: r,
                                indice: index,
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          if (editado == true) cargar();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'completar',
                          child: Text(r.completado ? 'Marcar pendiente' : 'Marcar completado'),
                        ),
                        const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 10),
        child: SizedBox(
          width: 54,
          height: 54,
          child: FloatingActionButton(
            onPressed: () async {
              final creado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormularioRecordatorioScreen(),
                ),
              );
              if (!context.mounted) return;
              if (creado == true) cargar();
            },
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ),
    );
  }
}