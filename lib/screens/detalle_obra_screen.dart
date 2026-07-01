import 'package:flutter/material.dart';
import '../models/obra.dart';
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
  @override
  Widget build(BuildContext context) {
    final obra = widget.obra;

    final tareasPendientes = obra.tareas
        .where((t) => !t.hecha)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(obra.nombre),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tareas'),
              subtitle:
                  Text('$tareasPendientes pendientes'),
              trailing:
                  const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TareasScreen(
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
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.inventory),
              title:
                  const Text('Materiales'),
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
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.euro),
              title: const Text('Economía'),
              subtitle: Text(
                'Presupuesto: ${obra.presupuesto.toStringAsFixed(0)} €',
              ),
              trailing:
                  const Icon(Icons.chevron_right),
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