import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:async';

class _HVS {
  static final Set<String> sessionKeys = {};

  static late final Box box;

  static init(Box box) => _HVS.box = box;

  static bool checkKeyValidity(String key) {
    final res = !sessionKeys.contains(key);
    sessionKeys.add(key);
    return res;
  }

  static createValue<T>(String key, T? val) {
    if (box.get(key) == null) {
      box.put(key, val);
    }
  }
}

class ValueStore {
  static init(Box box) => _HVS.init(box);
}

mixin Serde<T> {
  dynamic fromJson(Map<String, dynamic> json) => {};
  Map<String, dynamic> toJson(T val);
}

typedef TypeCallback<T> = void Function(T value);

abstract class BaseStoredValue<T> {
  void onSet(TypeCallback<T> cb);
  void onGet(TypeCallback<T> cb);
  set value(T val);
  T get value;
  ValueListenable<T> get listenable;
  Stream<T> get stream;
}

class StoredValue<T> implements BaseStoredValue<T> {
  final String _key;

  final StreamController<T> _streamController = StreamController.broadcast();

  StoredValue(this._key, {bool allowExisting = false, T? defaultValue}) {
    if (!allowExisting) {
      assert(_HVS.checkKeyValidity(_key));
    }
    if (defaultValue != null) {
      _HVS.createValue(_key, defaultValue);
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

  TypeCallback<T>? _onSet;

  TypeCallback<T>? _onGet;

  @override
  void onSet(TypeCallback<T> cb) => _onSet = cb;

  @override
  void onGet(TypeCallback<T> cb) => _onGet = cb;

  @override
  T get value {
    final v = _HVS.box.get(_key);
    if (_onGet != null) _onGet!(v);
    return v;
  }

  @override
  set value(T val) {
    if (_onSet != null) _onSet!(val);
    _HVS.box.put(_key, val);
  }

  @override
  ValueListenable<T> get listenable {
    final v = ValueNotifier(value);
    _HVS.box.listenable(keys: [_key]).addListener(() {
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
        _val = StoredValue<String>(key,
            defaultValue: jsonEncode(value.toJson(value)));

  TypeCallback<T>? _onSet;

  TypeCallback<T>? _onGet;

  @override
  void onSet(TypeCallback<T> cb) => _onSet = cb;

  @override
  void onGet(TypeCallback<T> cb) => _onGet = cb;

  @override
  T get value {
    final v = fromJson(jsonDecode(_val.value));
    if (_onGet != null) _onGet!(v);
    return v;
  }

  @override
  set value(T val) {
    if (_onSet != null) _onSet!(val);
    _val.value = jsonEncode(toJson(val));
  }

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
