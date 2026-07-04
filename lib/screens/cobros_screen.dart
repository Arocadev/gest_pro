import 'package:flutter/material.dart';

import '../models/cobro.dart';
import '../models/obra.dart';
import '../services/storage_service.dart';

class CobrosScreen extends StatefulWidget {
  const CobrosScreen({super.key});

  @override
  State<CobrosScreen> createState() => _CobrosScreenState();
}

class _CobrosScreenState extends State<CobrosScreen> {
  List<Cobro> cobros = [];
  List<Obra> obras = [];

  @override
  void initState() {
    super.initState();
    cobros = StorageService.cargarCobros();
    obras = StorageService.cargarObras();
  }

  Future<void> guardar() async {
    for (final obra in obras) {
      obra.cobrado = cobros
          .where((c) => c.obraId == obra.id)
          .fold(0.0, (s, c) => s + c.importe);
    }
    await StorageService.guardarCobros(cobros);
    await StorageService.guardarObras(obras);
  }

  Future<bool> confirmarEliminar(Cobro cobro) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar cobro'),
              content: const Text('¿Seguro que quieres eliminar este cobro?'),
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

  Future<void> crearCobro({Cobro? editar, int? indexEditar}) async {
    final importeController = TextEditingController(
      text: editar == null ? '' : editar.importe.toString(),
    );
    final conceptoController = TextEditingController(text: editar?.concepto ?? '');

    DateTime fecha = editar?.fecha ?? DateTime.now();
    Obra? obraSeleccionada;

    if (editar != null) {
      try {
        obraSeleccionada = obras.firstWhere((o) => o.id == editar.obraId);
      } catch (_) {}
    }

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(editar == null ? 'Nuevo cobro' : 'Editar cobro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Obra>(
                      initialValue: obraSeleccionada,
                      decoration: const InputDecoration(labelText: 'Obra'),
                      items: obras.map((obra) {
                        return DropdownMenuItem(
                          value: obra,
                          child: Text(obra.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => obraSeleccionada = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: importeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Importe'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: conceptoController,
                      decoration: const InputDecoration(labelText: 'Concepto'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha'),
                      subtitle: Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final nueva = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (nueva != null) {
                          setDialogState(() => fecha = nueva);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (obraSeleccionada == null ||
                        importeController.text.trim().isEmpty) {
                      return;
                    }

                    final importe = double.tryParse(
                          importeController.text.replaceAll(',', '.'),
                        ) ?? 0;

                    final cobro = Cobro(
                      obraId: obraSeleccionada!.id,
                      importe: importe,
                      fecha: fecha,
                      concepto: conceptoController.text.trim(),
                    );

                    if (editar == null) {
                      cobros.add(cobro);
                    } else {
                      cobros[indexEditar!] = cobro;
                    }

                    await guardar();

                    if (!context.mounted) return;
                    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final total = cobros.fold(0.0, (s, c) => s + c.importe);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: SizedBox(
                width: 200,
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.payments, color: Colors.blue, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Cobrado',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${total.toStringAsFixed(2)} €',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: cobros.isEmpty
                ? const Center(child: Text('No hay cobros'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: cobros.length,
                    itemBuilder: (context, index) {
                      final cobro = cobros[index];

                      Obra? obra;
                      try {
                        obra = obras.firstWhere((o) => o.id == cobro.obraId);
                      } catch (_) {}

                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: const Icon(Icons.payments, color: Colors.blue),
                          title: Text(
                            obra?.nombre ?? 'Obra eliminada',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cobro.importe.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${cobro.fecha.day}/${cobro.fecha.month}/${cobro.fecha.year}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                if (cobro.concepto.isNotEmpty)
                                  Text(
                                    cobro.concepto,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await crearCobro(editar: cobro, indexEditar: index);
                              }
                              if (value == 'delete') {
                                final borrar = await confirmarEliminar(cobro);
                                if (borrar) {
                                  cobros.removeAt(index);
                                  await guardar();
                                  if (!context.mounted) return;
                                  setState(() {});
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
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 10),
        child: SizedBox(
          width: 54,
          height: 54,
          child: FloatingActionButton(
            onPressed: crearCobro,
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ),
    );
  }
}