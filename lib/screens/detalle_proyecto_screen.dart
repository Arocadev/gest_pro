import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/proyecto.dart';
import '../services/pdf_service.dart';
import 'economia_screen.dart';
import 'materiales_screen.dart';
import 'tareas_screen.dart';

class DetalleProyectoScreen extends StatefulWidget {
  final Proyecto proyecto;

  const DetalleProyectoScreen({super.key, required this.proyecto});

  @override
  State<DetalleProyectoScreen> createState() => _DetalleProyectoScreenState();
}

class _DetalleProyectoScreenState extends State<DetalleProyectoScreen> {
  Future<void> editarEstado() async {
    String estado = widget.proyecto.estado;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Estado del proyecto'),
              content: DropdownButton<String>(
                value: estado,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'En curso', child: Text('En curso')),
                  DropdownMenuItem(value: 'Terminado', child: Text('Terminado')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => estado = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => widget.proyecto.estado = estado);
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: widget.proyecto.fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => widget.proyecto.fechaInicio = fecha);
  }

  Future<void> seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: widget.proyecto.fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => widget.proyecto.fechaFin = fecha);
  }

  String textoFecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Widget filaDetalle({
    required IconData icono,
    required Color iconColor,
    required String titulo,
    required String subtitulo,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icono, color: iconColor),
        title: Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitulo, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ),
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey.shade400) : null),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proyecto = widget.proyecto;
    final tareasPendientes = proyecto.tareas.where((t) => !t.hecha).length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: Text(
          proyecto.nombre,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final file = await PdfService.guardarPdf(proyecto);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Resumen del proyecto ${proyecto.nombre}',
                  subject: 'Resumen de proyecto',
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          filaDetalle(
            icono: Icons.pending_actions,
            iconColor: proyecto.estado == 'En curso'
                ? Colors.orange
                : proyecto.estado == 'Terminado'
                    ? Colors.green
                    : Colors.grey,
            titulo: 'Estado',
            subtitulo: proyecto.estado,
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
              onSelected: (value) {
                if (value == 'editar') editarEstado();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
              ],
            ),
          ),
          filaDetalle(
            icono: Icons.calendar_month,
            iconColor: Colors.indigo,
            titulo: 'Fecha inicio',
            subtitulo: textoFecha(proyecto.fechaInicio),
            onTap: seleccionarFechaInicio,
          ),
          filaDetalle(
            icono: Icons.event_available,
            iconColor: Colors.indigo,
            titulo: 'Fecha fin',
            subtitulo: textoFecha(proyecto.fechaFin),
            onTap: seleccionarFechaFin,
          ),
          filaDetalle(
            icono: Icons.task,
            iconColor: Colors.blue,
            titulo: 'Tareas',
            subtitulo: '$tareasPendientes pendientes',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TareasScreen(proyecto: proyecto)),
              );
              setState(() {});
            },
          ),
          filaDetalle(
            icono: Icons.inventory,
            iconColor: Colors.red,
            titulo: 'Materiales',
            subtitulo: '${proyecto.materiales.length} materiales',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MaterialesScreen(proyecto: proyecto)),
              );
              setState(() {});
            },
          ),
          filaDetalle(
            icono: Icons.euro,
            iconColor: Colors.green,
            titulo: 'Economía',
            subtitulo: 'Presupuesto: ${proyecto.presupuesto.toStringAsFixed(0)} €',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EconomiaScreen(proyecto: proyecto)),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}