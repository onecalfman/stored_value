#include "include/value_store/value_store_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "value_store_plugin.h"

void ValueStorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  value_store::ValueStorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
