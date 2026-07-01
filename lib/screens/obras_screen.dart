import 'package:flutter/material.dart';
import '../models/obra.dart';
import 'detalle_obra_screen.dart';

class ObrasScreen extends StatefulWidget {
  const ObrasScreen({super.key});

  @override
  State<ObrasScreen> createState() => _ObrasScreenState();
}

class _ObrasScreenState extends State<ObrasScreen> {
  final List<Obra> obras = [];

  void crearObra() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nueva obra'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nombre de la obra',
            ),
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
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  obras.add(
                    Obra(
                      nombre: controller.text.trim(),
                    ),
                  );
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

  void eliminarObra(int index) {
    setState(() {
      obras.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obras'),
      ),
      body: obras.isEmpty
          ? const Center(
              child: Text(
                'No hay obras todavía',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: obras.length,
              itemBuilder: (context, index) {
                final obra = obras[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(obra.nombre),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleObraScreen(
                            obra: obra,
                          ),
                        ),
                      );
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          eliminarObra(index);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar obra'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: crearObra,
        child: const Icon(Icons.add),
      ),
    );
  }
}