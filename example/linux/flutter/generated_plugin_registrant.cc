//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <value_store/value_store_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) value_store_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ValueStorePlugin");
  value_store_plugin_register_with_registrar(value_store_registrar);
}
