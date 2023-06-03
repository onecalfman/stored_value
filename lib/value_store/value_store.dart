import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:async';

class _HVS {
  static final Set<String> sessionKeys = {};

  static late Box store;

  static init([String boxName = "hydrated_value_store"]) async {
    await Hive.initFlutter(boxName);
    store = await Hive.openBox(boxName);
  }

  static bool checkKeyValidity(String key) {
    final res = !sessionKeys.contains(key);
    sessionKeys.add(key);
    return res;
  }

  static createValue<T>(String key, T? val) {
    if (store.get(key) == null) {
      store.put(key, val);
    }
  }
}

class ValueStore {
  static init() => _HVS.init();
}

mixin Serde<T> {
  dynamic fromJson(Map<String, dynamic> json) => {};
  Map<String, dynamic> toJson(T val);
}

abstract class BaseStoredValue<T> {
  set value(T val);
  T get value;
  ValueListenable<T> get listenable;
  Stream<T> get stream;
}

class StoredValue<T> implements BaseStoredValue<T> {
  final String _key;

  final StreamController<T> _streamController = StreamController.broadcast();

  StoredValue(this._key, [T? _value]) {
    assert(_HVS.checkKeyValidity(_key));
    if (_value != null) {
      _HVS.createValue(_key, _value);
    }
    _feedStream();
  }

  void _feedStream() {
    listenable.addListener(() {
      if (_streamController.hasListener) {
        _streamController.add(value);
      }
    });
  }

  @override
  T get value => _HVS.store.get(_key);

  @override
  set value(T val) => _HVS.store.put(_key, val);

  @override
  ValueListenable<T> get listenable {
    final v = ValueNotifier(value);
    _HVS.store.listenable(keys: [_key]).addListener(() {
      v.value = value;
    });
    return v;
  }

  @override
  Stream<T> get stream => _streamController.stream;
}

class StoredJsonValue<T extends Serde> implements BaseStoredValue<T> {
  final StoredValue _val;

  dynamic Function(Map<String, dynamic> json) fromJson;
  Map<String, dynamic> Function(T val) toJson;

  StoredJsonValue(String key, T value)
      : fromJson = value.fromJson,
        toJson = value.toJson,
        _val = StoredValue<String>(key, jsonEncode(value.toJson(value)));

  @override
  T get value => fromJson(jsonDecode(_val.value));

  @override
  set value(T val) => _val.value = jsonEncode(toJson(val));

  @override
  ValueListenable<T> get listenable {
    final v = ValueNotifier(
        fromJson(jsonDecode(_val.value) as Map<String, dynamic>) as T);

    _val.listenable.addListener(() {
      v.value = fromJson(jsonDecode(_val.value) as Map<String, dynamic>);
    });

    return v;
  }

  @override
  Stream<T> get stream => _val.stream.map((e) => fromJson(e));
}
