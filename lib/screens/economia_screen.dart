import 'package:flutter/material.dart';
import '../models/obra.dart';

class EconomiaScreen extends StatefulWidget {
  final Obra obra;

  const EconomiaScreen({
    super.key,
    required this.obra,
  });

  @override
  State<EconomiaScreen> createState() =>
      _EconomiaScreenState();
}

class _EconomiaScreenState
    extends State<EconomiaScreen> {
  void editarDinero({
    required String titulo,
    required double valorActual,
    required Function(double) onGuardar,
  }) {
    final controller =
        TextEditingController(
      text: valorActual.toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration:
                const InputDecoration(
              hintText: '0',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final valor =
                    double.tryParse(
                          controller.text
                              .replaceAll(
                            ',',
                            '.',
                          ),
                        ) ??
                        0;

                setState(() {
                  onGuardar(valor);
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

  @override
  Widget build(BuildContext context) {
    final obra = widget.obra;

    final materialesGastados =
        obra.materiales.fold(
      0.0,
      (sum, material) =>
          sum + material.total,
    );

    final pendiente =
        obra.presupuesto - obra.cobrado;

    final beneficio =
        obra.presupuesto -
            materialesGastados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Economía'),
      ),
      body: ListView(
        children: [
          Card(
            margin:
                const EdgeInsets.all(12),
            child: ListTile(
              title:
                  const Text('Presupuesto'),
              subtitle: Text(
                '${obra.presupuesto.toStringAsFixed(2)} €',
              ),
              onTap: () {
                editarDinero(
                  titulo:
                      'Presupuesto',
                  valorActual:
                      obra.presupuesto,
                  onGuardar:
                      (valor) {
                    obra.presupuesto =
                        valor;
                  },
                );
              },
            ),
          ),
          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: ListTile(
              title:
                  const Text('Cobrado'),
              subtitle: Text(
                '${obra.cobrado.toStringAsFixed(2)} €',
              ),
              onTap: () {
                editarDinero(
                  titulo: 'Cobrado',
                  valorActual:
                      obra.cobrado,
                  onGuardar:
                      (valor) {
                    obra.cobrado =
                        valor;
                  },
                );
              },
            ),
          ),
          Card(
            margin:
                const EdgeInsets.all(12),
            child: ListTile(
              title:
                  const Text('Pendiente'),
              subtitle: Text(
                '${pendiente.toStringAsFixed(2)} €',
              ),
            ),
          ),
          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: ListTile(
              title: const Text(
                'Beneficio estimado',
              ),
              subtitle: Text(
                '${beneficio.toStringAsFixed(2)} €',
              ),
            ),
          ),
        ],
      ),
    );
  }
}