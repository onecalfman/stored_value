import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:value_store/value_store.dart';

part 'values.g.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(OtherAdapter());
  Hive.registerAdapter(TimedStringAdapter());

  final box = await Hive.openBox("kv_box");
  await ValueStore.init(box);
}

class StoredValueBuilder<T> extends ValueListenableBuilder<T> {
  StoredValueBuilder(
      {required BaseStoredValue<T> value, required super.builder, super.key})
      : super(valueListenable: value.listenable);
}

@JsonSerializable()
class Unserializable with Serde<Unserializable> {
  int a;
  int b;

  Unserializable([this.a = 3, this.b = 2]);

  @override
  fromJson(json) => _$UnserializableFromJson(json);

  @override
  Map<String, dynamic> toJson(Unserializable val) =>
      _$UnserializableToJson(val);

  @override
  String toString() => jsonEncode(toJson(this));
}

class Other {
  int b;

  Other(this.b);

  @override
  String toString() => "Other { $b }";
}

class OtherAdapter extends TypeAdapter<Other> {
  @override
  Other read(BinaryReader reader) {
    return Other(reader.read() as int);
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, Other obj) {
    writer.write(obj.b);
  }
}

@HiveType(typeId: 3)
class TimedString {
  @HiveField(0)
  DateTime time;
  @HiveField(1)
  String word;

  TimedString(this.word, [DateTime? time]) : time = time ?? DateTime.now();

  @override
  String toString() {
    return """{
  time: $time
  word: $word
}""";
  }
}
