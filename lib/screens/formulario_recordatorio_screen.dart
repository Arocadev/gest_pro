import 'package:flutter/material.dart';

import '../models/recordatorio.dart';
import '../services/notification_service.dart';
import '../services/reminder_service.dart';
import '../widgets/selector_recordatorio.dart';

class FormularioRecordatorioScreen extends StatefulWidget {
  final Recordatorio? recordatorio;
  final int? indice;

  const FormularioRecordatorioScreen({
    super.key,
    this.recordatorio,
    this.indice,
  });

  @override
  State<FormularioRecordatorioScreen> createState() =>
      _FormularioRecordatorioScreenState();
}

class _FormularioRecordatorioScreenState
    extends State<FormularioRecordatorioScreen> {
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  DateTime fecha = DateTime.now();
  bool diaAntes = true;
  bool horas6 = false;
  bool hora1 = false;

  @override
  void initState() {
    super.initState();
    final r = widget.recordatorio;
    if (r != null) {
      tituloController.text = r.titulo;
      descripcionController.text = r.descripcion;
      fecha = r.fecha;
      diaAntes = r.avisarDiaAntes;
      horas6 = r.avisar6HorasAntes;
      hora1 = r.avisar1HoraAntes;
    }
  }

  Future<void> guardar() async {
    if (tituloController.text.trim().isEmpty) return;

    final recordatorio = Recordatorio(
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      fecha: fecha,
      completado: widget.recordatorio?.completado ?? false,
      avisarDiaAntes: diaAntes,
      avisar6HorasAntes: horas6,
      avisar1HoraAntes: hora1,
    );

    if (widget.indice == null) {
      await ReminderService.guardar(recordatorio);
      await NotificationService.mostrarNotificacion(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        titulo: 'Recordatorio creado',
        cuerpo: recordatorio.titulo,
      );
    } else {
      await ReminderService.actualizar(widget.indice!, recordatorio);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
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
          widget.recordatorio == null ? 'Nuevo recordatorio' : 'Editar recordatorio',
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: Colors.grey.shade200),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                  title: const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text(
                    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  onTap: () async {
                    final nueva = await showDatePicker(
                      context: context,
                      initialDate: fecha,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (nueva == null) return;
                    setState(() {
                      fecha = DateTime(nueva.year, nueva.month, nueva.day, fecha.hour, fecha.minute);
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: const Icon(Icons.access_time, color: Colors.indigo),
                  title: const Text('Hora', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text(
                    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  onTap: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: fecha.hour, minute: fecha.minute),
                    );
                    if (hora == null) return;
                    setState(() {
                      fecha = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  SelectorRecordatorio(
                    texto: 'Avisar 1 día antes',
                    valor: diaAntes,
                    onChanged: (v) => setState(() => diaAntes = v ?? false),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  SelectorRecordatorio(
                    texto: 'Avisar 6 horas antes',
                    valor: horas6,
                    onChanged: (v) => setState(() => horas6 = v ?? false),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  SelectorRecordatorio(
                    texto: 'Avisar 1 hora antes',
                    valor: hora1,
                    onChanged: (v) => setState(() => hora1 = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: guardar,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              widget.recordatorio == null ? 'Guardar' : 'Actualizar',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}