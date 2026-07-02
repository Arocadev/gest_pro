import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/cobro.dart';
import '../models/evento_calendario.dart';
import '../models/obra.dart';
import '../models/pago.dart';
import '../services/storage_service.dart';
import '../widgets/leyenda_calendario.dart';
import 'eventos_dia_screen.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({
    super.key,
  });

  @override
  State<CalendarioScreen> createState() =>
      _CalendarioScreenState();
}

class _CalendarioScreenState
    extends State<CalendarioScreen> {
  DateTime diaEnfocado =
      DateTime.now();

  List<EventoCalendario>
      todosEventos = [];

  @override
  void initState() {
    super.initState();
    cargarEventos();
  }

  String nombreMes(
    int mes,
  ) {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return meses[mes];
  }

  void cargarEventos() {
    todosEventos.clear();

    final obras =
        StorageService.cargarObras();

    final pagos =
        StorageService.cargarPagos();

    final cobros =
        StorageService.cargarCobros();

    for (final obra in obras) {
      if (obra.fechaInicio != null) {
        todosEventos.add(
          EventoCalendario(
            fecha:
                obra.fechaInicio!,
            titulo:
                'Inicio: ${obra.nombre}',
            color:
                Colors.green,
          ),
        );
      }

      if (obra.fechaFin != null) {
        todosEventos.add(
          EventoCalendario(
            fecha:
                obra.fechaFin!,
            titulo:
                'Fin: ${obra.nombre}',
            color:
                Colors.red,
          ),
        );
      }
    }

    for (final pago in pagos) {
      if (!pago.pagado) {
        todosEventos.add(
          EventoCalendario(
            fecha:
                pago.fecha,
            titulo:
                'Pago a ${pago.persona} - ${pago.importe.toStringAsFixed(2)} €',
            color:
                Colors.orange,
          ),
        );
      }
    }

    for (final cobro in cobros) {
      String nombreObra =
          'Obra';

      try {
        nombreObra =
            obras
                .firstWhere(
                  (o) =>
                      o.id ==
                      cobro.obraId,
                )
                .nombre;
      } catch (_) {}

      todosEventos.add(
        EventoCalendario(
          fecha:
              cobro.fecha,
          titulo:
              'Cobro $nombreObra - ${cobro.importe.toStringAsFixed(2)} €',
          color:
              Colors.blue,
        ),
      );
    }

    setState(() {});
  }

  List<EventoCalendario>
      eventosDia(
    DateTime dia,
  ) {
    return todosEventos.where(
      (e) {
        return e.fecha.year ==
                dia.year &&
            e.fecha.month ==
                dia.month &&
            e.fecha.day ==
                dia.day;
      },
    ).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final eventosHoy =
        eventosDia(
      DateTime.now(),
    );

    final eventosSemana =
        todosEventos.where(
      (e) {
        final diferencia =
            e.fecha
                .difference(
                  DateTime.now(),
                )
                .inDays;

        return diferencia >= 0 &&
            diferencia < 7;
      },
    ).toList();

    final eventosMes =
        todosEventos.where(
      (e) {
        return e.fecha.month ==
                diaEnfocado.month &&
            e.fecha.year ==
                diaEnfocado.year;
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario',
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay:
                DateTime(2020),
            lastDay:
                DateTime(2100),
            focusedDay:
                diaEnfocado,
            rowHeight: 72,
            daysOfWeekHeight:
                40,
            availableCalendarFormats:
                const {
              CalendarFormat.month:
                  'Mes',
            },
            calendarFormat:
                CalendarFormat.month,
            eventLoader:
                eventosDia,
            onDaySelected:
                (
                  selectedDay,
                  focusedDay,
                ) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EventosDiaScreen(
                    fecha:
                        selectedDay,
                    eventos:
                        eventosDia(
                      selectedDay,
                    ),
                  ),
                ),
              );

              setState(() {
                diaEnfocado =
                    focusedDay;
              });
            },
            calendarStyle:
                const CalendarStyle(
              todayDecoration:
                  BoxDecoration(
                color:
                    Colors.transparent,
              ),
              selectedDecoration:
                  BoxDecoration(
                color:
                    Colors.deepOrange,
                shape:
                    BoxShape.circle,
              ),
            ),
            calendarBuilders:
                CalendarBuilders(
              todayBuilder:
                  (
                    context,
                    day,
                    focusedDay,
                  ) {
                final texto =
                    '${day.day}';

                final dobleDigito =
                    texto.length >
                        1;

                return Center(
                  child:
                      Container(
                    width:
                        dobleDigito
                            ? 36
                            : 30,
                    height:
                        30,
                    decoration:
                        const BoxDecoration(
                      color:
                          Colors.red,
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        Center(
                      child:
                          Text(
                        texto,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
              markerBuilder:
                  (
                    context,
                    day,
                    events,
                  ) {
                final lista =
                    eventosDia(
                  day,
                );

                if (lista.isEmpty) {
                  return null;
                }

                return Positioned(
                  bottom: 8,
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      for (
                        int i = 0;
                        i <
                                lista.length &&
                            i < 3;
                        i++
                      )
                        Container(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal:
                                1,
                          ),
                          width:
                              6,
                          height:
                              6,
                          decoration:
                              BoxDecoration(
                            color:
                                lista[i]
                                    .color,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                      if (lista.length >
                          3)
                        Text(
                          '+${lista.length - 3}',
                          style:
                              const TextStyle(
                            fontSize:
                                8,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _itemResumen(
                    context,
                    Icons.today,
                    'Hoy',
                    eventosHoy.length,
                    eventosHoy,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color:
                      Colors.grey.shade300,
                ),
                Expanded(
                  child:
                      _itemResumen(
                    context,
                    Icons.calendar_view_week,
                    'Semanal',
                    eventosSemana.length,
                    eventosSemana,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color:
                      Colors.grey.shade300,
                ),
                Expanded(
                  child:
                      _itemResumen(
                    context,
                    Icons.calendar_month,
                    'Mensual',
                    eventosMes.length,
                    eventosMes,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(
            height: 4,
          ),
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
    List<EventoCalendario>
        eventos,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      onTap: () {
        String? titulo;

        if (tituloResumen ==
            'Semanal') {
          final inicio =
              DateTime.now();

          final fin =
              inicio.add(
            const Duration(
              days: 6,
            ),
          );

          titulo =
              'Semana del ${inicio.day}/${inicio.month} al ${fin.day}/${fin.month}';
        } else if (tituloResumen ==
            'Mensual') {
          titulo =
              '${nombreMes(diaEnfocado.month)} ${diaEnfocado.year}';
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EventosDiaScreen(
              fecha:
                  DateTime.now(),
              eventos:
                  eventos,
              titulo:
                  titulo,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Icon(
            icono,
            size: 22,
            color:
                Colors.black54,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            tituloResumen,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            '$cantidad eventos',
            style:
                const TextStyle(
              color:
                  Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}