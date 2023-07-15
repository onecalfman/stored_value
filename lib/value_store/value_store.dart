import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:async';

class StoredValueFactory {
  StoredValueFactory(this._box);

  final Set<String> _sessionKeys = {};

  late final Box _box;

  bool _checkKeyValidity(String key) {
    final res = !_sessionKeys.contains(key);
    _sessionKeys.add(key);
    return res;
  }

  _createValue<T>(String key, T? val) {
    if (_box.get(key) == null) {
      _box.put(key, val);
    }
  }

  StoredValue<T> storedValue<T>(String key,
          {bool allowExisting = false, T? defaultValue}) =>
      StoredValue(this, key,
          allowExisting: allowExisting, defaultValue: defaultValue);

  StoredJsonValue<T> storedJsonValue<T extends Serde>(String key, T value,
          {bool allowExisting = false}) =>
      StoredJsonValue<T>(this, key, value, allowExisting: allowExisting);
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
  final StoredValueFactory _factory;

  final StreamController<T> _streamController = StreamController.broadcast();

  StoredValue(this._factory, this._key,
      {bool allowExisting = false, T? defaultValue}) {
    if (!allowExisting) {
      assert(_factory._checkKeyValidity(_key));
    }
    if (defaultValue != null) {
      _factory._createValue(_key, defaultValue);
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
    final v = _factory._box.get(_key);
    if (_onGet != null) _onGet!(v);
    return v;
  }

  @override
  set value(T val) {
    if (_onSet != null) _onSet!(val);
    _factory._box.put(_key, val);
  }

  @override
  ValueListenable<T> get listenable {
    final v = ValueNotifier(value);
    _factory._box.listenable(keys: [_key]).addListener(() {
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

  StoredJsonValue(StoredValueFactory factory, String key, T value, {bool allowExisting = false})
      : fromJson = value.fromJson,
        toJson = value.toJson,
        _val = StoredValue<String>(factory, key,
            defaultValue: jsonEncode(value.toJson(value)), allowExisting : true);

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
