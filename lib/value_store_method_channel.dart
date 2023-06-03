import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'value_store_platform_interface.dart';

/// An implementation of [ValueStorePlatform] that uses method channels.
class MethodChannelValueStore extends ValueStorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('value_store');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
