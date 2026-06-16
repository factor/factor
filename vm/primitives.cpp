#include "master.hpp"

namespace factor {

#define PRIMITIVE(name)                                \
  VM_C_API void primitive_##name(factor_vm * parent) { \
    parent->primitive_##name();                        \
  }

EACH_PRIMITIVE(PRIMITIVE)

}
