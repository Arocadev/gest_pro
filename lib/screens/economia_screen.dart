import 'package:flutter/material.dart';
import '../models/obra.dart';

class EconomiaScreen extends StatefulWidget {
  final Obra obra;

  const EconomiaScreen({super.key, required this.obra});

  @override
  State<EconomiaScreen> createState() => _EconomiaScreenState();
}

class _EconomiaScreenState extends State<EconomiaScreen> {
  void editarDinero({
    required String titulo,
    required double valorActual,
    required Function(double) onGuardar,
  }) {
    final controller = TextEditingController(
      text: valorActual == 0 ? '' : valorActual.toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(hintText: '0'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(
                      controller.text.replaceAll(',', '.'),
                    ) ?? 0;
                setState(() => onGuardar(valor));
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

    final materialesGastados = obra.materiales.fold(0.0, (sum, m) => sum + m.total);
    final pendiente = obra.presupuesto - obra.cobrado;
    final beneficio = obra.presupuesto - materialesGastados;

    Widget filaEditable({
      required String titulo,
      required String valor,
      required Color color,
      required VoidCallback onEditar,
    }) {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              valor,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
            onSelected: (value) {
              if (value == 'editar') onEditar();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
            ],
          ),
        ),
      );
    }

    Widget filaInfo({
      required String titulo,
      required String valor,
      required Color color,
    }) {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              valor,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          'Economía',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          filaEditable(
            titulo: 'Presupuesto',
            valor: '${obra.presupuesto.toStringAsFixed(2)} €',
            color: Colors.deepPurple,
            onEditar: () => editarDinero(
              titulo: 'Presupuesto',
              valorActual: obra.presupuesto,
              onGuardar: (valor) => obra.presupuesto = valor,
            ),
          ),
          filaEditable(
            titulo: 'Cobrado',
            valor: '${obra.cobrado.toStringAsFixed(2)} €',
            color: Colors.blue,
            onEditar: () => editarDinero(
              titulo: 'Cobrado',
              valorActual: obra.cobrado,
              onGuardar: (valor) => obra.cobrado = valor,
            ),
          ),
          filaInfo(
            titulo: 'Pendiente de cobro',
            valor: '${pendiente.toStringAsFixed(2)} €',
            color: Colors.orange,
          ),
          filaInfo(
            titulo: 'Materiales gastados',
            valor: '${materialesGastados.toStringAsFixed(2)} €',
            color: Colors.red,
          ),
          filaInfo(
            titulo: 'Beneficio estimado',
            valor: '${beneficio.toStringAsFixed(2)} €',
            color: beneficio >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}