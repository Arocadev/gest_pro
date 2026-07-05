import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'evento_calendario.g.dart';

@HiveType(typeId: 6)
class EventoCalendario extends HiveObject {
  @HiveField(0)
  final DateTime fecha;

  @HiveField(1)
  final String titulo;

  @HiveField(2)
  final int colorValue;

  EventoCalendario({
    required this.fecha,
    required this.titulo,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}