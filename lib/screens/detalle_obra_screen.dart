import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/obra.dart';
import '../services/pdf_service.dart';
import 'economia_screen.dart';
import 'materiales_screen.dart';
import 'tareas_screen.dart';

class DetalleObraScreen extends StatefulWidget {
  final Obra obra;

  const DetalleObraScreen({
    super.key,
    required this.obra,
  });

  @override
  State<DetalleObraScreen> createState() =>
      _DetalleObraScreenState();
}

class _DetalleObraScreenState
    extends State<DetalleObraScreen> {
  Future<void> editarEstado() async {
    String estado = widget.obra.estado;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Estado de la obra',
              ),
              content:
                  DropdownButton<String>(
                value: estado,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Pendiente',
                    child: Text(
                      'Pendiente',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'En curso',
                    child:
                        Text('En curso'),
                  ),
                  DropdownMenuItem(
                    value: 'Terminada',
                    child:
                        Text('Terminada'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setDialogState(() {
                    estado = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.obra.estado =
                          estado;
                    });

                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void>
      seleccionarFechaInicio() async {
    final fecha =
        await showDatePicker(
      context: context,
      initialDate:
          widget.obra.fechaInicio ??
              DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        widget.obra.fechaInicio =
            fecha;
      });
    }
  }

  String textoFecha() {
    final fecha =
        widget.obra.fechaInicio;

    if (fecha == null) {
      return 'Sin fecha';
    }

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final obra = widget.obra;

    final tareasPendientes =
        obra.tareas
            .where((t) => !t.hecha)
            .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(obra.nombre),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
            ),
            onPressed: () async {
              final pdf =
                  await PdfService
                      .generarObra(
                obra,
              );

              await Printing.layoutPdf(
                onLayout:
                    (format) async =>
                        pdf.save(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            margin:
                const EdgeInsets.all(
              12,
            ),
            child: ListTile(
              leading:
                  const Icon(
                Icons.flag,
              ),
              title:
                  Text(obra.estado),
              subtitle:
                  Text(textoFecha()),
              onTap:
                  seleccionarFechaInicio,
              trailing:
                  IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed:
                    editarEstado,
              ),
            ),
          ),
          Card(
            margin:
                const EdgeInsets.all(
              12,
            ),
            child: ListTile(
              leading:
                  const Icon(
                Icons.task,
              ),
              title:
                  const Text(
                'Tareas',
              ),
              subtitle: Text(
                '$tareasPendientes pendientes',
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TareasScreen(
                      obra: obra,
                    ),
                  ),
                );

                setState(() {});
              },
            ),
          ),
          Card(
            margin:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
            ),
            child: ListTile(
              leading:
                  const Icon(
                Icons.inventory,
              ),
              title:
                  const Text(
                'Materiales',
              ),
              subtitle: Text(
                '${obra.materiales.length} materiales',
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MaterialesScreen(
                      obra: obra,
                    ),
                  ),
                );

                setState(() {});
              },
            ),
          ),
          Card(
            margin:
                const EdgeInsets.all(
              12,
            ),
            child: ListTile(
              leading:
                  const Icon(
                Icons.euro,
              ),
              title:
                  const Text(
                'Economía',
              ),
              subtitle: Text(
                'Presupuesto: ${obra.presupuesto.toStringAsFixed(0)} €',
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EconomiaScreen(
                      obra: obra,
                    ),
                  ),
                );

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}