// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evento_calendario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventoCalendarioAdapter extends TypeAdapter<EventoCalendario> {
  @override
  final int typeId = 6;

  @override
  EventoCalendario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventoCalendario(
      fecha: fields[0] as DateTime,
      titulo: fields[1] as String,
      colorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EventoCalendario obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fecha)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventoCalendarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
