import 'package:flutter/material.dart';

class LeyendaCalendario extends StatelessWidget {
  const LeyendaCalendario({super.key});

  Widget item(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 6,
        children: [
          item(Colors.green, 'Inicio obra'),
          item(Colors.red, 'Fin obra'),
          item(Colors.orange, 'Pago'),
          item(Colors.blue, 'Cobro'),
          item(Colors.purple, 'Recordatorio'),
        ],
      ),
    );
  }
}