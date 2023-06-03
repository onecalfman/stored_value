import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:value_store/value_store.dart';

part 'main.g.dart';

void main() async {
  await ValueStore.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

@JsonSerializable()
class Unser with Serde<Unser> {
  int a;
  int b;

  Unser([this.a = 3, this.b = 2]);

  @override
  fromJson(json) => _$UnserFromJson(json);

  @override
  Map<String, dynamic> toJson(Unser t) => _$UnserToJson(t);
}

class _MyAppState extends State<MyApp> {
  final val = StoredValue("teother", 104);
  final val2 = StoredJsonValue("teother3", Unser());

  void updater() {
    Timer(const Duration(seconds: 1), () => val.value = val.value + 1);
    Timer.periodic(
        const Duration(seconds: 5),
        (_) =>
            val2.value = Unser(Random().nextInt(100), Random().nextInt(100)));
  }

  @override
  Widget build(BuildContext context) {
    updater();

    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Value Store'),
        ),
        body: Center(
          child: Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: val.listenable,
                  builder: (context, value, _) => Text(value.toString())),
              ValueListenableBuilder(
                  valueListenable: val2.listenable,
                  builder: (context, value, _) =>
                      Text(value.toJson(value).toString())),
            ],
          ),
        ),
      ),
    );
  }
}
