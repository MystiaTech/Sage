// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 0;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItem()
      ..name = fields[0] as String
      ..barcode = fields[1] as String?
      ..quantity = fields[2] as int
      ..unit = fields[3] as String?
      ..purchaseDate = fields[4] as DateTime
      ..expirationDate = fields[5] as DateTime
      ..locationIndex = fields[6] as int
      ..category = fields[7] as String?
      ..photoUrl = fields[8] as String?
      ..notes = fields[9] as String?
      ..userId = fields[10] as String?
      ..householdId = fields[11] as String?
      ..lastModified = fields[12] as DateTime?
      ..syncedToCloud = fields[13] as bool;
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.purchaseDate)
      ..writeByte(5)
      ..write(obj.expirationDate)
      ..writeByte(6)
      ..write(obj.locationIndex)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.photoUrl)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.householdId)
      ..writeByte(12)
      ..write(obj.lastModified)
      ..writeByte(13)
      ..write(obj.syncedToCloud);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 1;

  @override
  Location read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Location.fridge;
      case 1:
        return Location.freezer;
      case 2:
        return Location.pantry;
      case 3:
        return Location.spiceRack;
      case 4:
        return Location.countertop;
      case 5:
        return Location.other;
      default:
        return Location.fridge;
    }
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    switch (obj) {
      case Location.fridge:
        writer.writeByte(0);
        break;
      case Location.freezer:
        writer.writeByte(1);
        break;
      case Location.pantry:
        writer.writeByte(2);
        break;
      case Location.spiceRack:
        writer.writeByte(3);
        break;
      case Location.countertop:
        writer.writeByte(4);
        break;
      case Location.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpirationStatusAdapter extends TypeAdapter<ExpirationStatus> {
  @override
  final int typeId = 2;

  @override
  ExpirationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpirationStatus.fresh;
      case 1:
        return ExpirationStatus.caution;
      case 2:
        return ExpirationStatus.warning;
      case 3:
        return ExpirationStatus.critical;
      case 4:
        return ExpirationStatus.expired;
      default:
        return ExpirationStatus.fresh;
    }
  }

  @override
  void write(BinaryWriter writer, ExpirationStatus obj) {
    switch (obj) {
      case ExpirationStatus.fresh:
        writer.writeByte(0);
        break;
      case ExpirationStatus.caution:
        writer.writeByte(1);
        break;
      case ExpirationStatus.warning:
        writer.writeByte(2);
        break;
      case ExpirationStatus.critical:
        writer.writeByte(3);
        break;
      case ExpirationStatus.expired:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpirationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
