// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proyecto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProyectoAdapter extends TypeAdapter<Proyecto> {
  @override
  final int typeId = 2;

  @override
  Proyecto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Proyecto(
      nombre: fields[0] as String,
      presupuesto: fields[1] as double,
      cobrado: fields[2] as double,
      estado: fields[5] as String,
      fechaInicio: fields[6] as DateTime?,
      fechaFin: fields[7] as DateTime?,
      id: fields[8] as String?,
      tareas: (fields[3] as List?)?.cast<Tarea>(),
      materiales: (fields[4] as List?)?.cast<MaterialProyecto>(),
    );
  }

  @override
  void write(BinaryWriter writer, Proyecto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.presupuesto)
      ..writeByte(2)
      ..write(obj.cobrado)
      ..writeByte(3)
      ..write(obj.tareas)
      ..writeByte(4)
      ..write(obj.materiales)
      ..writeByte(5)
      ..write(obj.estado)
      ..writeByte(6)
      ..write(obj.fechaInicio)
      ..writeByte(7)
      ..write(obj.fechaFin)
      ..writeByte(8)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProyectoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
