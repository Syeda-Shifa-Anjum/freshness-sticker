// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fresh_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FreshItemModelAdapter extends TypeAdapter<FreshItemModel> {
  @override
  final int typeId = 0;

  @override
  FreshItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreshItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      scanDate: fields[2] as DateTime,
      spoilageDate: fields[3] as DateTime?,
      statusIndex: fields[4] as int,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FreshItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.scanDate)
      ..writeByte(3)
      ..write(obj.spoilageDate)
      ..writeByte(4)
      ..write(obj.statusIndex)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreshItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
