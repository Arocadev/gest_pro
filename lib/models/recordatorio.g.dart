// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recordatorio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordatorioAdapter extends TypeAdapter<Recordatorio> {
  @override
  final int typeId = 5;

  @override
  Recordatorio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recordatorio(
      titulo: fields[0] as String,
      descripcion: fields[1] as String,
      fecha: fields[2] as DateTime,
      completado: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recordatorio obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.completado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordatorioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
