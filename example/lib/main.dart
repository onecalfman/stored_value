import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:value_store/value_store.dart';

import 'values.dart';

void main() async {
  await initHive();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final val1 = StoredValue("one", 104);
  final val2 = StoredJsonValue("two", Unserializable());
  final val3 = StoredValue("three", Other(5));
  final val4 = StoredValue("four", TimedString("ok"));

  void updater() {
    Timer(const Duration(seconds: 1), () => val1.value = val1.value + 1);
    Timer.periodic(const Duration(seconds: 5), (_) {
      val2.value = Unserializable(Random().nextInt(100), Random().nextInt(100));
      val3.value = Other(val2.value.a * 11);
      val4.value = TimedString(Random().nextInt(40).toString());
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...[val1, val2, val3, val4]
                    .map((e) => StoredValueBuilder(
                        value: e as BaseStoredValue,
                        builder: (context, value, _) => Text(
                              value.toString(),
                              textScaleFactor: 1.4,
                            )))
                    .toList(),
                OutlinedButton(
                    onPressed: () => exit(0),
                    child: const Text("kill", textScaleFactor: 2))
              ]),
        ),
      ),
    );
  }
}
