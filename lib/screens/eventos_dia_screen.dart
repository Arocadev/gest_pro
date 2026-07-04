import 'package:flutter/material.dart';

import '../models/evento_calendario.dart';
import '../widgets/tarjeta_evento.dart';

class EventosDiaScreen extends StatelessWidget {
  final DateTime fecha;
  final List<EventoCalendario> eventos;
  final String? titulo;

  const EventosDiaScreen({
    super.key,
    required this.fecha,
    required this.eventos,
    this.titulo,
  });

  String textoFecha() {
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month]} de ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: Text(
          titulo ?? textoFecha(),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
      ),
      body: eventos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin eventos este día',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return TarjetaEvento(
                  color: evento.color,
                  texto: evento.titulo,
                );
              },
            ),
    );
  }
}