#include "master.hpp"

namespace factor {

#define PRIMITIVE(name)                                \
  VM_C_API void primitive_##name(factor_vm * parent) { \
    parent->primitive_##name();                        \
  }

// The primitive_exit function is marked [[noreturn]] in its implementation
// but the macro-generated wrapper can't inherit that attribute.
// This is a known limitation of the macro system, so we keep the minimal pragma.
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#endif
EACH_PRIMITIVE(PRIMITIVE)
#ifdef __clang__
#pragma clang diagnostic pop
#endif

}
