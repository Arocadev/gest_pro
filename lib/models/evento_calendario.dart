import 'package:flutter/material.dart';

class EventoCalendario {
  final DateTime fecha;
  final String titulo;
  final Color color;

  EventoCalendario({
    required this.fecha,
    required this.titulo,
    required this.color,
  });
}