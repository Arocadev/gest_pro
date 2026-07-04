import 'package:flutter/material.dart';

import '../models/evento_calendario.dart';
import '../widgets/tarjeta_evento.dart';

class EventosAgrupadosScreen extends StatelessWidget {
  final String titulo;
  final Map<String, List<EventoCalendario>> grupos;

  const EventosAgrupadosScreen({
    super.key,
    required this.titulo,
    required this.grupos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
      ),
      body: grupos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin eventos en este período',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: grupos.entries.map((grupo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        grupo.key,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...grupo.value.map((e) => TarjetaEvento(
                      color: e.color,
                      texto: e.titulo,
                    )),
                    const SizedBox(height: 8),
                    Divider(indent: 20, endIndent: 20, color: Colors.grey.shade200),
                  ],
                );
              }).toList(),
            ),
    );
  }
}