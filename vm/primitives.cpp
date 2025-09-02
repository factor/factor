#include "master.hpp"

namespace factor {

#define PRIMITIVE(name)                                \
  VM_C_API void primitive_##name(factor_vm * parent) { \
    parent->primitive_##name();                        \
  }

// Suppress warning for primitive_exit since it's correctly marked noreturn
// in the implementation but the macro-generated wrapper can't be
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"
EACH_PRIMITIVE(PRIMITIVE)
#pragma clang diagnostic pop

}
