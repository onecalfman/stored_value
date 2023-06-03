import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'value_store_method_channel.dart';

abstract class ValueStorePlatform extends PlatformInterface {
  /// Constructs a ValueStorePlatform.
  ValueStorePlatform() : super(token: _token);

  static final Object _token = Object();

  static ValueStorePlatform _instance = MethodChannelValueStore();

  /// The default instance of [ValueStorePlatform] to use.
  ///
  /// Defaults to [MethodChannelValueStore].
  static ValueStorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ValueStorePlatform] when
  /// they register themselves.
  static set instance(ValueStorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
