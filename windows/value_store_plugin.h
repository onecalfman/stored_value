#ifndef FLUTTER_PLUGIN_VALUE_STORE_PLUGIN_H_
#define FLUTTER_PLUGIN_VALUE_STORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace value_store {

class ValueStorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ValueStorePlugin();

  virtual ~ValueStorePlugin();

  // Disallow copy and assign.
  ValueStorePlugin(const ValueStorePlugin&) = delete;
  ValueStorePlugin& operator=(const ValueStorePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace value_store

#endif  // FLUTTER_PLUGIN_VALUE_STORE_PLUGIN_H_
