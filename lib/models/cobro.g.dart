// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cobro.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CobroAdapter extends TypeAdapter<Cobro> {
  @override
  final int typeId = 4;

  @override
  Cobro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cobro(
      proyectoId: fields[0] as String,
      importe: fields[1] as double,
      fecha: fields[2] as DateTime,
      concepto: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Cobro obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.proyectoId)
      ..writeByte(1)
      ..write(obj.importe)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.concepto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CobroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
