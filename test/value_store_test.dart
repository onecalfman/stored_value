import 'package:flutter_test/flutter_test.dart';
import 'package:value_store/value_store.dart';
import 'package:value_store/value_store_platform_interface.dart';
import 'package:value_store/value_store_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockValueStorePlatform
    with MockPlatformInterfaceMixin
    implements ValueStorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ValueStorePlatform initialPlatform = ValueStorePlatform.instance;

  test('$MethodChannelValueStore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelValueStore>());
  });

  test('getPlatformVersion', () async {
    ValueStore valueStorePlugin = ValueStore();
    MockValueStorePlatform fakePlatform = MockValueStorePlatform();
    ValueStorePlatform.instance = fakePlatform;

    expect(await valueStorePlugin.getPlatformVersion(), '42');
  });
}
