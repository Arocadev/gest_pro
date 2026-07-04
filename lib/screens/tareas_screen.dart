import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../models/tarea.dart';

class TareasScreen extends StatefulWidget {
  final Obra obra;

  const TareasScreen({super.key, required this.obra});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  void crearTarea() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nueva tarea'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                setState(() {
                  widget.obra.tareas.add(Tarea(nombre: controller.text.trim()));
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void editarTarea(int index) {
    final controller = TextEditingController(text: widget.obra.tareas[index].nombre);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                setState(() {
                  widget.obra.tareas[index].nombre = controller.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarTarea(int index) {
    setState(() => widget.obra.tareas.removeAt(index));
  }

  Future<bool> confirmarEliminar(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar tarea'),
              content: Text('¿Eliminar "$nombre"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final tareas = widget.obra.tareas;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          'Tareas',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
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
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      onSelected: (value) async {
                        if (value == 'toggle') {
                          setState(() => tarea.hecha = !tarea.hecha);
                        }
                        if (value == 'edit') {
                          editarTarea(index);
                        }
                        if (value == 'delete') {
                          final borrar = await confirmarEliminar(tarea.nombre);
                          if (borrar) eliminarTarea(index);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(tarea.hecha ? 'Marcar como pendiente' : 'Marcar como terminada'),
                        ),
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
          child: FloatingActionButton(
            onPressed: crearTarea,
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ),
    );
  }
}