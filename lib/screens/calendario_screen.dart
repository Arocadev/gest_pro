import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/evento_calendario.dart';
import '../services/storage_service.dart';
import '../widgets/leyenda_calendario.dart';
import 'eventos_agrupados_screen.dart';
import 'eventos_dia_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => cargarEventos());
  }

  String nombreMes(int mes) {
    const meses = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return meses[mes];
  }

  void cargarEventos() {
    todosEventos.clear();
    final proyectos = StorageService.cargarProyectos();
    final pagos = StorageService.cargarPagos();
    final cobros = StorageService.cargarCobros();

    for (final proyecto in proyectos) {
      if (proyecto.fechaInicio != null) {
        todosEventos.add(EventoCalendario(
          fecha: proyecto.fechaInicio!,
          titulo: 'Inicio: ${proyecto.nombre}',
          colorValue: Colors.green.toARGB32(),
        ));
      }
      if (proyecto.fechaFin != null) {
        todosEventos.add(EventoCalendario(
          fecha: proyecto.fechaFin!,
          titulo: 'Fin: ${proyecto.nombre}',
          colorValue: Colors.red.toARGB32(),
        ));
      }
      for (final tarea in proyecto.tareas) {
        if (tarea.fechaInicio != null) {
          todosEventos.add(EventoCalendario(
            fecha: tarea.fechaInicio!,
            titulo: '▶ ${tarea.nombre} (${proyecto.nombre})',
            colorValue: Colors.indigo.toARGB32(),
          ));
        }
        if (tarea.fechaLimite != null) {
          todosEventos.add(EventoCalendario(
            fecha: tarea.fechaLimite!,
            titulo: '⚑ ${tarea.nombre} (${proyecto.nombre})',
            colorValue: Colors.deepOrange.toARGB32(),
          ));
        }
      }
    }

    for (final pago in pagos) {
      if (!pago.pagado) {
        todosEventos.add(EventoCalendario(
          fecha: pago.fecha,
          titulo: 'Pago a ${pago.persona} - ${pago.importe.toStringAsFixed(2)} €',
          colorValue: Colors.orange.toARGB32(),
        ));
      }
    }

    for (final cobro in cobros) {
      String nombreProyecto = 'Proyecto';
      try {
        nombreProyecto = proyectos.firstWhere((p) => p.id == cobro.proyectoId).nombre;
      } catch (_) {}
      todosEventos.add(EventoCalendario(
        fecha: cobro.fecha,
        titulo: 'Cobro $nombreProyecto - ${cobro.importe.toStringAsFixed(2)} €',
        colorValue: Colors.blue.toARGB32(),
      ));
    }

    final eventoBox = Hive.box<EventoCalendario>('eventos_libres');
    for (final e in eventoBox.values) {
      todosEventos.add(e);
    }

    setState(() {});
  }

  List<EventoCalendario> eventosDia(DateTime dia) {
    return todosEventos.where((e) =>
        e.fecha.year == dia.year &&
        e.fecha.month == dia.month &&
        e.fecha.day == dia.day).toList();
  }

  Map<String, List<EventoCalendario>> eventosSemanaAgrupados() {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final mapa = <String, List<EventoCalendario>>{};
    final hoy = DateTime.now();
    final inicioSemana = DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: hoy.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));
    for (final e in todosEventos) {
      final f = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      if (!f.isBefore(inicioSemana) && !f.isAfter(finSemana)) {
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
    return Map.fromEntries(mapa.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  Future<void> crearEventoLibre(DateTime fecha) async {
    final tituloController = TextEditingController();
    DateTime fechaSeleccionada = fecha;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo evento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month, color: Colors.orange),
                    title: const Text('Fecha'),
                    trailing: Text(
                      '${fechaSeleccionada.day.toString().padLeft(2, '0')}/${fechaSeleccionada.month.toString().padLeft(2, '0')}/${fechaSeleccionada.year}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    onTap: () async {
                      final nueva = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (nueva != null) setDialogState(() => fechaSeleccionada = nueva);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (tituloController.text.trim().isEmpty) return;
                    final box = Hive.box<EventoCalendario>('eventos_libres');
                    await box.add(EventoCalendario(
                      fecha: fechaSeleccionada,
                      titulo: tituloController.text.trim(),
                      colorValue: Colors.purple.toARGB32(),
                    ));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    cargarEventos();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final inicioSemana = DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: hoy.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));

    final eventosHoy = eventosDia(DateTime.now());
    final eventosSemana = todosEventos.where((e) {
      final f = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      return !f.isBefore(inicioSemana) && !f.isAfter(finSemana);
    }).toList();
    final eventosMes = todosEventos.where((e) =>
        e.fecha.month == diaEnfocado.month && e.fecha.year == diaEnfocado.year).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        toolbarHeight: 70,
        title: Image.asset('assets/logo.png', height: 90, fit: BoxFit.contain),
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
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            calendarFormat: CalendarFormat.month,
            eventLoader: eventosDia,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => diaEnfocado = focusedDay);
              final eventos = eventosDia(selectedDay);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.3,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Text(
                                  '${selectedDay.day.toString().padLeft(2, '0')}/${selectedDay.month.toString().padLeft(2, '0')}/${selectedDay.year}',
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Divider(),
                              Expanded(
                                child: eventos.isEmpty
                                    ? const Center(child: Text('Sin eventos', style: TextStyle(color: Colors.black38)))
                                    : ListView.builder(
                                        controller: scrollController,
                                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                                        itemCount: eventos.length,
                                        itemBuilder: (context, index) {
                                          final evento = eventos[index];
                                          return Card(
                                            elevation: 0.5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              side: BorderSide(color: Colors.grey.shade200),
                                            ),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              leading: Container(
                                                width: 4,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: evento.color,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              title: Text(evento.titulo,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: MediaQuery.of(ctx).padding.bottom + 16,
                            right: 16,
                            child: SizedBox(
                              width: 54,
                              height: 54,
                              child: FloatingActionButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await crearEventoLibre(selectedDay);
                                },
                                child: const Icon(Icons.add, size: 26),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            onPageChanged: (focusedDay) => setState(() => diaEnfocado = focusedDay),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.transparent),
            ),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) {
                final texto = '${day.day}';
                return Center(
                  child: Container(
                    width: texto.length > 1 ? 36 : 30,
                    height: 30,
                    decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                    child: Center(
                      child: Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    children: coloresUnicos.map((color) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        )).toList(),
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
                Expanded(child: _itemResumen(context, Icons.today, 'Hoy', eventosHoy.length, eventosHoy)),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Expanded(child: _itemResumen(context, Icons.calendar_view_week, 'Semanal', eventosSemana.length, eventosSemana)),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Expanded(child: _itemResumen(context, Icons.calendar_month, 'Mensual', eventosMes.length, eventosMes)),
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

  Widget _itemResumen(BuildContext context, IconData icono, String tituloResumen,
      int cantidad, List<EventoCalendario> eventos) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (tituloResumen == 'Semanal') {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => EventosAgrupadosScreen(titulo: 'Esta semana', grupos: eventosSemanaAgrupados())));
          return;
        }
        if (tituloResumen == 'Mensual') {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => EventosAgrupadosScreen(
                  titulo: '${nombreMes(diaEnfocado.month)} ${diaEnfocado.year}',
                  grupos: eventosMesAgrupados())));
          return;
        }
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => EventosDiaScreen(fecha: DateTime.now(), eventos: eventos, titulo: tituloResumen)));
      },
      child: Column(
        children: [
          Icon(icono, size: 22, color: Colors.black54),
          const SizedBox(height: 4),
          Text(tituloResumen, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text('$cantidad eventos', style: const TextStyle(color: Colors.black54, fontSize: 11)),
        ],
      ),
    );
  }
}