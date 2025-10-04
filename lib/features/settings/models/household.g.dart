// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HouseholdAdapter extends TypeAdapter<Household> {
  @override
  final int typeId = 4;

  @override
  Household read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Household(
      id: fields[0] as String,
      name: fields[1] as String,
      ownerName: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      members: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Household obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ownerName)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.members);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
