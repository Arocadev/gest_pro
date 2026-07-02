import 'package:flutter/material.dart';

class LeyendaCalendario
    extends StatelessWidget {
  const LeyendaCalendario({
    super.key,
  });

  Widget item(
    Color color,
    String texto,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          texto,
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          item(
            Colors.green,
            'Inicio',
          ),
          const SizedBox(width: 20),
          item(
            Colors.red,
            'Fin',
          ),
          const SizedBox(width: 20),
          item(
            Colors.orange,
            'Pago',
          ),
          const SizedBox(width: 20),
          item(
            Colors.blue,
            'Cobro',
          ),
          const SizedBox(width: 20),
          item(
            Colors.purple,
            'Recordatorio',
          ),
        ],
      ),
    );
  }
}