import 'package:flutter/material.dart';
import '../models/proyecto.dart';
import '../models/tarea.dart';

class TareasScreen extends StatefulWidget {
  final Proyecto proyecto;

  const TareasScreen({super.key, required this.proyecto});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  Future<void> crearTarea({Tarea? editar, int? index}) async {
    final controller = TextEditingController(text: editar?.nombre ?? '');
    DateTime? fechaInicio = editar?.fechaInicio;
    DateTime? fechaLimite = editar?.fechaLimite;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(editar == null ? 'Nueva tarea' : 'Editar tarea'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.play_circle_outline, color: Colors.green),
                      title: const Text('Fecha inicio'),
                      trailing: Text(
                        fechaInicio != null
                            ? '${fechaInicio!.day.toString().padLeft(2, '0')}/${fechaInicio!.month.toString().padLeft(2, '0')}/${fechaInicio!.year}'
                            : 'Sin fecha',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      onTap: () async {
                        final nueva = await showDatePicker(
                          context: context,
                          initialDate: fechaInicio ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (nueva != null) setDialogState(() => fechaInicio = nueva);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.flag_outlined, color: Colors.red),
                      title: const Text('Fecha límite'),
                      trailing: Text(
                        fechaLimite != null
                            ? '${fechaLimite!.day.toString().padLeft(2, '0')}/${fechaLimite!.month.toString().padLeft(2, '0')}/${fechaLimite!.year}'
                            : 'Sin fecha',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      onTap: () async {
                        final nueva = await showDatePicker(
                          context: context,
                          initialDate: fechaLimite ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (nueva != null) setDialogState(() => fechaLimite = nueva);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    setState(() {
                      if (editar == null) {
                        widget.proyecto.tareas.add(Tarea(
                          nombre: controller.text.trim(),
                          fechaInicio: fechaInicio,
                          fechaLimite: fechaLimite,
                        ));
                      } else {
                        editar.nombre = controller.text.trim();
                        editar.fechaInicio = fechaInicio;
                        editar.fechaLimite = fechaLimite;
                      }
                    });
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

  void eliminarTarea(int index) {
    setState(() => widget.proyecto.tareas.removeAt(index));
  }

  Future<bool> confirmarEliminar(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar tarea'),
              content: Text('¿Eliminar "$nombre"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
              ],
            );
          },
        ) ?? false;
  }

  String _fecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tareas = widget.proyecto.tareas;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text('Tareas', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                return Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(
                      tarea.hecha ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: tarea.hecha ? Colors.green : Colors.grey.shade400,
                    ),
                    title: Text(
                      tarea.nombre,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        decoration: tarea.hecha ? TextDecoration.lineThrough : null,
                        color: tarea.hecha ? Colors.grey.shade500 : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tarea.fechaInicio != null)
                          Row(
                            children: [
                              const Icon(Icons.play_circle_outline, size: 13, color: Colors.green),
                              const SizedBox(width: 4),
                              Text('Inicio: ${_fecha(tarea.fechaInicio)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        if (tarea.fechaLimite != null)
                          Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 13,
                                  color: tarea.fechaLimite!.isBefore(DateTime.now()) && !tarea.hecha
                                      ? Colors.red
                                      : Colors.orange),
                              const SizedBox(width: 4),
                              Text('Límite: ${_fecha(tarea.fechaLimite)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: tarea.fechaLimite!.isBefore(DateTime.now()) && !tarea.hecha
                                          ? Colors.red
                                          : Colors.grey.shade600)),
                            ],
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      onSelected: (value) async {
                        if (value == 'toggle') setState(() => tarea.hecha = !tarea.hecha);
                        if (value == 'edit') await crearTarea(editar: tarea, index: index);
                        if (value == 'delete') {
                          final borrar = await confirmarEliminar(tarea.nombre);
                          if (borrar) eliminarTarea(index);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'toggle',
                            child: Text(tarea.hecha ? 'Marcar como pendiente' : 'Marcar como terminada')),
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
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
          child: FloatingActionButton(onPressed: crearTarea, child: const Icon(Icons.add, size: 26)),
        ),
      ),
    );
  }
}