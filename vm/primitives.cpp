#include "master.hpp"

namespace factor {

#define PRIMITIVE(name)                                \
  VM_C_API void primitive_##name(factor_vm * parent) { \
    JIT_WRITABLE                                       \
    parent->primitive_##name();                        \
    JIT_EXECUTABLE                                     \
  }

EACH_PRIMITIVE(PRIMITIVE)

}
