import 'package:flutter/material.dart';

class TarjetaEvento
    extends StatelessWidget {
  final Color color;
  final String texto;

  const TarjetaEvento({
    super.key,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              color,
          radius: 8,
        ),
        title: Text(texto),
      ),
    );
  }
}