import 'package:flutter/material.dart';
import '../models/material_proyecto.dart';
import '../models/proyecto.dart';

class MaterialesScreen extends StatefulWidget {
  final Proyecto proyecto;

  const MaterialesScreen({super.key, required this.proyecto});

  @override
  State<MaterialesScreen> createState() => _MaterialesScreenState();
}

class _MaterialesScreenState extends State<MaterialesScreen> {
  void crearMaterial() {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nuevo material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 12),
                TextField(controller: cantidadController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cantidad')),
                const SizedBox(height: 12),
                TextField(controller: precioController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Precio unidad (€)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.trim().isEmpty) return;
                final cantidad = double.tryParse(cantidadController.text.replaceAll(',', '.')) ?? 0;
                final precio = double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0;
                setState(() {
                  widget.proyecto.materiales.add(MaterialProyecto(
                    nombre: nombreController.text.trim(),
                    cantidad: cantidad,
                    precioUnidad: precio,
                  ));
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

  void editarMaterial(int index) {
    final material = widget.proyecto.materiales[index];
    final nombreController = TextEditingController(text: material.nombre);
    final cantidadController = TextEditingController(text: material.cantidad == 0 ? '' : material.cantidad.toString());
    final precioController = TextEditingController(text: material.precioUnidad == 0 ? '' : material.precioUnidad.toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 12),
                TextField(controller: cantidadController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cantidad')),
                const SizedBox(height: 12),
                TextField(controller: precioController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Precio unidad (€)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final cantidad = double.tryParse(cantidadController.text.replaceAll(',', '.')) ?? 0;
                final precio = double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0;
                setState(() {
                  material.nombre = nombreController.text.trim();
                  material.cantidad = cantidad;
                  material.precioUnidad = precio;
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

  Future<bool> confirmarEliminar(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Eliminar material'),
              content: Text('¿Eliminar "$nombre"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
              ],
            );
          },
        ) ?? false;
  }

  double get total => widget.proyecto.materiales.fold<double>(0, (sum, m) => sum + m.total);
  double get totalConIva => widget.proyecto.materiales.fold<double>(0, (sum, m) => sum + m.totalConIva);

  @override
  Widget build(BuildContext context) {
    final materiales = widget.proyecto.materiales;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text('Materiales', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).padding.bottom + 12),
        child: Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${total.toStringAsFixed(2)} €',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total + IVA (21%): ${totalConIva.toStringAsFixed(2)} €',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
      body: materiales.isEmpty
          ? const Center(child: Text('No hay materiales'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: materiales.length,
              itemBuilder: (context, index) {
                final material = materiales[index];
                return Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(material.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${material.cantidad} x ${material.precioUnidad.toStringAsFixed(2)} € = ${material.total.toStringAsFixed(2)} €',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                      onSelected: (value) async {
                        if (value == 'edit') editarMaterial(index);
                        if (value == 'delete') {
                          final borrar = await confirmarEliminar(material.nombre);
                          if (borrar) setState(() => materiales.removeAt(index));
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
        padding: const EdgeInsets.only(right: 8, bottom: 120),
        child: SizedBox(
          width: 54,
          height: 54,
          child: FloatingActionButton(onPressed: crearMaterial, child: const Icon(Icons.add, size: 26)),
        ),
      ),
    );
  }
}