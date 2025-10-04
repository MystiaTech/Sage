// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      discordWebhookUrl: fields[0] as String?,
      expirationAlertsEnabled: fields[1] as bool,
      discordNotificationsEnabled: fields[2] as bool,
      defaultView: fields[3] as String,
      sortBy: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.discordWebhookUrl)
      ..writeByte(1)
      ..write(obj.expirationAlertsEnabled)
      ..writeByte(2)
      ..write(obj.discordNotificationsEnabled)
      ..writeByte(3)
      ..write(obj.defaultView)
      ..writeByte(4)
      ..write(obj.sortBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
