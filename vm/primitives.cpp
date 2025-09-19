#include "master.hpp"

namespace factor {

#define PRIMITIVE(name)                                \
  VM_C_API void primitive_##name(factor_vm * parent) { \
    parent->primitive_##name();                        \
  }

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#endif
EACH_PRIMITIVE(PRIMITIVE)
#ifdef __clang__
#pragma clang diagnostic pop
#endif

}
