// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_proyecto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialProyectoAdapter extends TypeAdapter<MaterialProyecto> {
  @override
  final int typeId = 1;

  @override
  MaterialProyecto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialProyecto(
      nombre: fields[0] as String,
      cantidad: fields[1] as double,
      precioUnidad: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialProyecto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.cantidad)
      ..writeByte(2)
      ..write(obj.precioUnidad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialProyectoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
