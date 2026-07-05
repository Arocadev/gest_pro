import 'package:flutter/material.dart';
import '../models/proyecto.dart';
import '../services/storage_service.dart';
import 'detalle_proyecto_screen.dart';

class ProyectosScreen extends StatefulWidget {
  const ProyectosScreen({super.key});

  @override
  State<ProyectosScreen> createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreen> {
  List<Proyecto> proyectos = [];

  @override
  void initState() {
    super.initState();
    cargarProyectos();
  }

  void cargarProyectos() {
    proyectos = StorageService.cargarProyectos();
    setState(() {});
  }

  Future<void> guardarProyectos() async {
    await StorageService.guardarProyectos(proyectos);
  }

  void crearProyecto() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nuevo proyecto'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre del proyecto'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                setState(() => proyectos.add(Proyecto(nombre: controller.text.trim())));
                await guardarProyectos();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editarProyecto(int index) async {
    final controller = TextEditingController(text: proyectos[index].nombre);
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar proyecto'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre del proyecto'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                setState(() => proyectos[index].nombre = controller.text.trim());
                await guardarProyectos();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarProyecto(int index) async {
    setState(() => proyectos.removeAt(index));
    await guardarProyectos();
  }

  Future<bool> confirmarEliminar(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar proyecto'),
              content: Text('¿Eliminar "$nombre"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
              ],
            );
          },
        ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        toolbarHeight: 70,
        title: Image.asset('assets/logo.png', height: 90, fit: BoxFit.contain),
      ),
      body: proyectos.isEmpty
          ? const Center(child: Text('No hay proyectos'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: proyectos.length,
              itemBuilder: (context, index) {
                final proyecto = proyectos[index];
                return Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      proyecto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        proyecto.estado,
                        style: TextStyle(
                          color: proyecto.estado == 'En curso'
                              ? Colors.orange.shade700
                              : proyecto.estado == 'Terminado'
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleProyectoScreen(proyecto: proyecto),
                        ),
                      );
                      await guardarProyectos();
                      setState(() {});
                    },
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      onSelected: (value) async {
                        final realIndex = proyectos.indexOf(proyecto);
                        if (value == 'edit') await editarProyecto(realIndex);
                        if (value == 'delete') {
                          final borrar = await confirmarEliminar(proyecto.nombre);
                          if (borrar) await eliminarProyecto(realIndex);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
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
            onPressed: crearProyecto,
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ),
    );
  }
}