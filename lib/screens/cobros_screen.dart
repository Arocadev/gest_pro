import 'package:flutter/material.dart';

import '../models/cobro.dart';
import '../models/obra.dart';
import '../services/storage_service.dart';

class CobrosScreen extends StatefulWidget {
  const CobrosScreen({
    super.key,
  });

  @override
  State<CobrosScreen> createState() =>
      _CobrosScreenState();
}

class _CobrosScreenState
    extends State<CobrosScreen> {
  List<Cobro> cobros = [];
  List<Obra> obras = [];

  @override
  void initState() {
    super.initState();

    cobros =
        StorageService.cargarCobros();

    obras =
        StorageService.cargarObras();
  }

  Future<void> guardar() async {
    for (final obra in obras) {
      obra.cobrado = cobros
          .where(
            (c) =>
                c.obraId == obra.id,
          )
          .fold(
            0.0,
            (s, c) =>
                s + c.importe,
          );
    }

    await StorageService
        .guardarCobros(
      cobros,
    );

    await StorageService
        .guardarObras(
      obras,
    );
  }

  Future<bool> confirmarEliminar(
    Cobro cobro,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title:
                  const Text(
                'Eliminar cobro',
              ),
              content: const Text(
                '¿Seguro que quieres eliminar este cobro?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child:
                      const Text(
                    'Cancelar',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child:
                      const Text(
                    'Eliminar',
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> crearCobro({
    Cobro? editar,
    int? indexEditar,
  }) async {
    final importeController =
        TextEditingController(
      text: editar == null
          ? ''
          : editar.importe
              .toString(),
    );

    final conceptoController =
        TextEditingController(
      text:
          editar?.concepto ?? '',
    );

    DateTime fecha =
        editar?.fecha ??
            DateTime.now();

    Obra? obraSeleccionada;

    if (editar != null) {
      try {
        obraSeleccionada =
            obras.firstWhere(
          (o) =>
              o.id ==
              editar.obraId,
        );
      } catch (_) {}
    }

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder:
              (
                context,
                setDialogState,
              ) {
            return AlertDialog(
              title: Text(
                editar == null
                    ? 'Nuevo cobro'
                    : 'Editar cobro',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<
                        Obra>(
                      initialValue:
                          obraSeleccionada,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Obra',
                      ),
                      items: obras
                          .map(
                            (
                              obra,
                            ) {
                              return DropdownMenuItem(
                                value:
                                    obra,
                                child:
                                    Text(
                                  obra.nombre,
                                ),
                              );
                            },
                          )
                          .toList(),
                      onChanged:
                          (
                            value,
                          ) {
                        setDialogState(
                          () {
                            obraSeleccionada =
                                value;
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller:
                          importeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal:
                            true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Importe',
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller:
                          conceptoController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Concepto',
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title:
                          const Text(
                        'Fecha',
                      ),
                      subtitle:
                          Text(
                        '${fecha.day}/${fecha.month}/${fecha.year}',
                      ),
                      trailing:
                          const Icon(
                        Icons.calendar_month,
                      ),
                      onTap:
                          () async {
                        final nueva =
                            await showDatePicker(
                          context:
                              context,
                          initialDate:
                              fecha,
                          firstDate:
                              DateTime(
                                  2020),
                          lastDate:
                              DateTime(
                                  2100),
                        );

                        if (nueva !=
                            null) {
                          setDialogState(
                            () {
                              fecha =
                                  nueva;
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text(
                    'Cancelar',
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      () async {
                    if (obraSeleccionada ==
                            null ||
                        importeController
                            .text
                            .trim()
                            .isEmpty) {
                      return;
                    }

                    final importe =
                        double.tryParse(
                              importeController
                                  .text
                                  .replaceAll(
                                    ',',
                                    '.',
                                  ),
                            ) ??
                            0;

                    final cobro =
                        Cobro(
                      obraId:
                          obraSeleccionada!
                              .id,
                      importe:
                          importe,
                      fecha:
                          fecha,
                      concepto:
                          conceptoController
                              .text
                              .trim(),
                    );

                    if (editar ==
                        null) {
                      cobros.add(
                        cobro,
                      );
                    } else {
                      cobros[indexEditar!] =
                          cobro;
                    }

                    await guardar();

                    if (mounted) {
                      setState(() {});
                      Navigator.pop(
                        context,
                      );
                    }
                  },
                  child:
                      const Text(
                    'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final total =
        cobros.fold(
      0.0,
      (s, c) =>
          s + c.importe,
    );

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              12,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Cobrado:',
                    ),
                    const Spacer(),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                cobros.isEmpty
                    ? const Center(
                        child:
                            Text(
                          'No hay cobros',
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            cobros.length,
                        itemBuilder:
                            (
                              context,
                              index,
                            ) {
                          final cobro =
                              cobros[index];

                          Obra? obra;

                          try {
                            obra =
                                obras.firstWhere(
                              (
                                o,
                              ) =>
                                  o.id ==
                                  cobro
                                      .obraId,
                            );
                          } catch (_) {}

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  12,
                              vertical:
                                  6,
                            ),
                            child:
                                ListTile(
                              title:
                                  Text(
                                obra?.nombre ??
                                    'Obra eliminada',
                              ),
                              subtitle:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Importe: ${cobro.importe.toStringAsFixed(2)} €',
                                  ),
                                  Text(
                                    'Fecha: ${cobro.fecha.day}/${cobro.fecha.month}/${cobro.fecha.year}',
                                  ),
                                  if (cobro
                                      .concepto
                                      .isNotEmpty)
                                    Text(
                                      'Concepto: ${cobro.concepto}',
                                    ),
                                ],
                              ),
                              trailing:
                                  PopupMenuButton<
                                      String>(
                                onSelected:
                                    (
                                      value,
                                    ) async {
                                  if (value ==
                                      'edit') {
                                    await crearCobro(
                                      editar:
                                          cobro,
                                      indexEditar:
                                          index,
                                    );
                                  }

                                  if (value ==
                                      'delete') {
                                    final borrar =
                                        await confirmarEliminar(
                                      cobro,
                                    );

                                    if (borrar) {
                                      cobros.removeAt(
                                        index,
                                      );

                                      await guardar();

                                      setState(
                                        () {},
                                      );
                                    }
                                  }
                                },
                                itemBuilder:
                                    (_) =>
                                        const [
                                  PopupMenuItem(
                                    value:
                                        'edit',
                                    child:
                                        Text(
                                      'Editar',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value:
                                        'delete',
                                    child:
                                        Text(
                                      'Eliminar',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed:
            crearCobro,
        child:
            const Icon(
          Icons.add,
        ),
      ),
    );
  }
}