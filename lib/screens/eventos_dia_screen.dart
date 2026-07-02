import 'package:flutter/material.dart';

import '../models/evento_calendario.dart';
import '../widgets/tarjeta_evento.dart';

class EventosDiaScreen
    extends StatelessWidget {
  final DateTime fecha;
  final List<EventoCalendario>
      eventos;
  final String? titulo;

  const EventosDiaScreen({
    super.key,
    required this.fecha,
    required this.eventos,
    this.titulo,
  });

  String textoFecha() {
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month]} de ${fecha.year}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulo ??
              textoFecha(),
        ),
      ),
      body: eventos.isEmpty
          ? const Center(
              child: Text(
                'No hay eventos',
              ),
            )
          : ListView.builder(
              itemCount:
                  eventos.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                final evento =
                    eventos[index];

                return TarjetaEvento(
                  color:
                      evento.color,
                  texto:
                      evento.titulo,
                );
              },
            ),
    );
  }
}