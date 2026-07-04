import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../services/storage_service.dart';
import 'detalle_obra_screen.dart';

class ObrasScreen extends StatefulWidget {
  const ObrasScreen({super.key});

  @override
  State<ObrasScreen> createState() => _ObrasScreenState();
}

class _ObrasScreenState extends State<ObrasScreen> {
  List<Obra> obras = [];

  @override
  void initState() {
    super.initState();
    cargarObras();
  }

  void cargarObras() {
    obras = StorageService.cargarObras();
    setState(() {});
  }

  Future<void> guardarObras() async {
    await StorageService.guardarObras(obras);
  }

  void crearObra() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nueva obra'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre de la obra'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  obras.add(Obra(nombre: controller.text.trim()));
                });

                await guardarObras();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editarObra(int index) async {
    final controller = TextEditingController(text: obras[index].nombre);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar obra'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre de la obra'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  obras[index].nombre = controller.text.trim();
                });

                await guardarObras();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarObra(int index) async {
    setState(() {
      obras.removeAt(index);
    });

    await guardarObras();
  }

  Future<bool> confirmarEliminar(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar obra'),
              content: Text('¿Eliminar "$nombre"?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          'Obras',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600),
        ),
      ),
      body: obras.isEmpty
          ? const Center(child: Text('No hay obras'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: obras.length,
              itemBuilder: (context, index) {
                final obra = obras[index];

               return Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                  title: Text(
                    obra.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        obra.estado,
                        style: TextStyle(
                          color: obra.estado == 'En curso'
                              ? Colors.orange.shade700
                              : obra.estado == 'Terminada'
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
                          builder: (_) => DetalleObraScreen(obra: obra),
                        ),
                      );

                      await guardarObras();

                      setState(() {});
                    },
                    trailing: PopupMenuButton<String>(
                       icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade700,
                        ),
                      onSelected: (value) async {
                        final realIndex = obras.indexOf(obra);

                        if (value == 'edit') {
                          await editarObra(realIndex);
                        }

                        if (value == 'delete') {
                          final borrar = await confirmarEliminar(obra.nombre);

                          if (borrar) {
                            await eliminarObra(realIndex);
                          }
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

   floatingActionButton: Padding(
  padding: const EdgeInsets.only(
    right: 8,
    bottom: 10,
  ),
  child: SizedBox(
    width: 54,
    height: 54,
    child: FloatingActionButton(
      onPressed: crearObra,
      child: const Icon(
        Icons.add,
        size: 26,
      ),
    ),
  ),
),
    );
  }
}