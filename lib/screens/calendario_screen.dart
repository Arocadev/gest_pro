import 'package:flutter/material.dart';

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: const Center(
        child: Text(
          'Aquí irá el calendario',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}