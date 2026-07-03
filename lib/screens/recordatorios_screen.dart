import 'package:flutter/material.dart';

import '../models/recordatorio.dart';
import '../services/reminder_service.dart';
import 'formulario_recordatorio_screen.dart';

class RecordatoriosScreen
    extends StatefulWidget {
  const RecordatoriosScreen({
    super.key,
  });

  @override
  State<RecordatoriosScreen>
      createState() =>
          _RecordatoriosScreenState();
}

class _RecordatoriosScreenState
    extends State<
        RecordatoriosScreen> {
  List<Recordatorio>
      recordatorios = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() {
    final lista =
        ReminderService.cargar();

    lista.sort(
      (a, b) =>
          a.fecha.compareTo(
        b.fecha,
      ),
    );

    setState(() {
      recordatorios = lista;
    });
  }

  Future<void>
      eliminarCompletados() async {
    final lista =
        ReminderService.cargar();

    for (int i =
            lista.length - 1;
        i >= 0;
        i--) {
      if (lista[i]
          .completado) {
        await ReminderService
            .eliminar(i);
      }
    }

    cargar();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recordatorios',
        ),
        actions: [
          PopupMenuButton<
              String>(
            onSelected:
                (value) async {
              if (value ==
                  'borrar') {
                await eliminarCompletados();
              }
            },
            itemBuilder:
                (_) => const [
              PopupMenuItem(
                value: 'borrar',
                child: Text(
                  'Eliminar completados',
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () async {
          final creado =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const FormularioRecordatorioScreen(),
            ),
          );

          if (creado ==
              true) {
            cargar();
          }
        },
      ),
      body:
          recordatorios.isEmpty
              ? const Center(
                  child: Text(
                    'No hay recordatorios',
                  ),
                )
              : ListView.builder(
                  itemCount:
                      recordatorios
                          .length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                    final r =
                        recordatorios[
                            index];

                    return Card(
                      child:
                          ListTile(
                        onTap: () {
                          if (r
                              .descripcion
                              .trim()
                              .isEmpty) {
                            return;
                          }

                          showDialog(
                            context:
                                context,
                            builder:
                                (_) =>
                                    AlertDialog(
                              title:
                                  Text(
                                r.titulo,
                              ),
                              content:
                                  Text(
                                r.descripcion,
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  child:
                                      const Text(
                                    'Cerrar',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        leading:
                            Icon(
                          r.completado
                              ? Icons
                                  .check_circle
                              : Icons
                                  .notifications,
                          color:
                              r.completado
                                  ? Colors
                                      .green
                                  : Colors
                                      .purple,
                        ),
                        title:
                            Text(
                          r.titulo,
                          style:
                              TextStyle(
                            decoration:
                                r.completado
                                    ? TextDecoration
                                        .lineThrough
                                    : null,
                          ),
                        ),
                        subtitle:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              '${r.fecha.day.toString().padLeft(2, '0')}/'
                              '${r.fecha.month.toString().padLeft(2, '0')}/'
                              '${r.fecha.year} · '
                              '${r.fecha.hour.toString().padLeft(2, '0')}:'
                              '${r.fecha.minute.toString().padLeft(2, '0')}',
                            ),
                            if (!r.completado &&
                                r.fecha.isBefore(
                                  DateTime
                                      .now(),
                                ))
                              const Text(
                                'Vencido',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.red,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            PopupMenuButton<
                                String>(
                          onSelected:
                              (
                                value,
                              ) async {
                            if (value ==
                                'completar') {
                              r.completado =
                                  !r.completado;

                              await r
                                  .save();

                              cargar();
                            }

                            if (value ==
                                'eliminar') {
                              await ReminderService
                                  .eliminar(
                                index,
                              );

                              cargar();
                            }

                            if (value ==
                                'editar') {
                              final editado =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FormularioRecordatorioScreen(
                                    recordatorio:
                                        r,
                                    indice:
                                        index,
                                  ),
                                ),
                              );

                              if (editado ==
                                  true) {
                                cargar();
                              }
                            }
                          },
                          itemBuilder:
                              (
                                context,
                              ) =>
                                  [
                            const PopupMenuItem(
                              value:
                                  'editar',
                              child:
                                  Text(
                                'Editar',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'completar',
                              child:
                                  Text(
                                r.completado
                                    ? 'Marcar pendiente'
                                    : 'Marcar completado',
                              ),
                            ),
                            const PopupMenuItem(
                              value:
                                  'eliminar',
                              child:
                                  Text(
                                'Eliminar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}