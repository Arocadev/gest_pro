import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/evento_calendario.dart';
import '../services/storage_service.dart';
import '../widgets/leyenda_calendario.dart';
import 'eventos_dia_screen.dart';
import 'recordatorios_screen.dart';
import 'eventos_agrupados_screen.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime diaEnfocado = DateTime.now();
  List<EventoCalendario> todosEventos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarEventos();
    });
  }

  String nombreMes(int mes) {
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return meses[mes];
  }

  void cargarEventos() {
    todosEventos.clear();

    final obras = StorageService.cargarObras();
    final pagos = StorageService.cargarPagos();
    final cobros = StorageService.cargarCobros();
    final recordatorios = StorageService.cargarRecordatorios();

    for (final obra in obras) {
      if (obra.fechaInicio != null) {
        todosEventos.add(EventoCalendario(
          fecha: obra.fechaInicio!,
          titulo: 'Inicio: ${obra.nombre}',
          color: Colors.green,
        ));
      }
      if (obra.fechaFin != null) {
        todosEventos.add(EventoCalendario(
          fecha: obra.fechaFin!,
          titulo: 'Fin: ${obra.nombre}',
          color: Colors.red,
        ));
      }
    }

    for (final pago in pagos) {
      if (!pago.pagado) {
        todosEventos.add(EventoCalendario(
          fecha: pago.fecha,
          titulo: 'Pago a ${pago.persona} - ${pago.importe.toStringAsFixed(2)} €',
          color: Colors.orange,
        ));
      }
    }

    for (final cobro in cobros) {
      String nombreObra = 'Obra';
      try {
        nombreObra = obras.firstWhere((o) => o.id == cobro.obraId).nombre;
      } catch (_) {}

      todosEventos.add(EventoCalendario(
        fecha: cobro.fecha,
        titulo: 'Cobro $nombreObra - ${cobro.importe.toStringAsFixed(2)} €',
        color: Colors.blue,
      ));
    }

    for (final r in recordatorios) {
      if (!r.completado) {
        final hora =
            '${r.fecha.hour.toString().padLeft(2, '0')}:${r.fecha.minute.toString().padLeft(2, '0')}';
        todosEventos.add(EventoCalendario(
          fecha: r.fecha,
          titulo: '$hora · ${r.titulo}',
          color: Colors.purple,
        ));
      }
    }

    setState(() {});
  }

  List<EventoCalendario> eventosDia(DateTime dia) {
    return todosEventos.where((e) {
      return e.fecha.year == dia.year &&
          e.fecha.month == dia.month &&
          e.fecha.day == dia.day;
    }).toList();
  }

  Map<String, List<EventoCalendario>> eventosSemanaAgrupados() {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final mapa = <String, List<EventoCalendario>>{};

    final hoy = DateTime.now();
    final inicioSemana = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(Duration(days: hoy.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));

    for (final e in todosEventos) {
      final fechaEvento = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      if (!fechaEvento.isBefore(inicioSemana) && !fechaEvento.isAfter(finSemana)) {
        final nombre = dias[e.fecha.weekday - 1];
        mapa.putIfAbsent(nombre, () => []);
        mapa[nombre]!.add(e);
      }
    }
    return mapa;
  }

  Map<String, List<EventoCalendario>> eventosMesAgrupados() {
    final mapa = <String, List<EventoCalendario>>{};

    for (final e in todosEventos) {
      if (e.fecha.month == diaEnfocado.month && e.fecha.year == diaEnfocado.year) {
        final semana = ((e.fecha.day - 1) ~/ 7) + 1;
        final titulo = 'Semana $semana';
        mapa.putIfAbsent(titulo, () => []);
        mapa[titulo]!.add(e);
      }
    }

    return Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final inicioSemana = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(Duration(days: hoy.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));

    final eventosHoy = eventosDia(DateTime.now());

    final eventosSemana = todosEventos.where((e) {
      final fechaEvento = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      return !fechaEvento.isBefore(inicioSemana) && !fechaEvento.isAfter(finSemana);
    }).toList();

    final eventosMes = todosEventos.where((e) {
      return e.fecha.month == diaEnfocado.month && e.fecha.year == diaEnfocado.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          'Calendario',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecordatoriosScreen(),
                    ),
                  );
                  cargarEventos();
                },
              ),
              if (StorageService.cargarRecordatorios()
                  .where((r) => !r.completado)
                  .isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${StorageService.cargarRecordatorios().where((r) => !r.completado).length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: diaEnfocado,
            rowHeight: 58,
            daysOfWeekHeight: 32,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mes',
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: eventosDia,
            onDaySelected: (selectedDay, focusedDay) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventosDiaScreen(
                    fecha: selectedDay,
                    eventos: eventosDia(selectedDay),
                  ),
                ),
              );
              setState(() => diaEnfocado = focusedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() => diaEnfocado = focusedDay);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.transparent),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) {
                final texto = '${day.day}';
                final dobleDigito = texto.length > 1;
                return Center(
                  child: Container(
                    width: dobleDigito ? 36 : 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        texto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                final lista = eventosDia(day);
                if (lista.isEmpty) return null;

                final coloresUnicos = lista.map((e) => e.color).toSet().toList();

                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: coloresUnicos.map((color) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _itemResumen(
                    context, Icons.today, 'Hoy',
                    eventosHoy.length, eventosHoy,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Expanded(
                  child: _itemResumen(
                    context, Icons.calendar_view_week, 'Semanal',
                    eventosSemana.length, eventosSemana,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Expanded(
                  child: _itemResumen(
                    context, Icons.calendar_month, 'Mensual',
                    eventosMes.length, eventosMes,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 4),
          const LeyendaCalendario(),
        ],
      ),
    );
  }

  Widget _itemResumen(
    BuildContext context,
    IconData icono,
    String tituloResumen,
    int cantidad,
    List<EventoCalendario> eventos,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (tituloResumen == 'Semanal') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventosAgrupadosScreen(
                titulo: 'Esta semana',
                grupos: eventosSemanaAgrupados(),
              ),
            ),
          );
          return;
        }

        if (tituloResumen == 'Mensual') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventosAgrupadosScreen(
                titulo: '${nombreMes(diaEnfocado.month)} ${diaEnfocado.year}',
                grupos: eventosMesAgrupados(),
              ),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventosDiaScreen(
              fecha: DateTime.now(),
              eventos: eventos,
              titulo: tituloResumen,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Icon(icono, size: 22, color: Colors.black54),
          const SizedBox(height: 4),
          Text(
            tituloResumen,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '$cantidad eventos',
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}