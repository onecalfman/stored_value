// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'values.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimedStringAdapter extends TypeAdapter<TimedString> {
  @override
  final int typeId = 3;

  @override
  TimedString read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimedString(
      fields[1] as String,
      fields[0] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimedString obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.word);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedStringAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unserializable _$UnserializableFromJson(Map<String, dynamic> json) =>
    Unserializable(
      json['a'] as int? ?? 3,
      json['b'] as int? ?? 2,
    );

Map<String, dynamic> _$UnserializableToJson(Unserializable instance) =>
    <String, dynamic>{
      'a': instance.a,
      'b': instance.b,
    };
