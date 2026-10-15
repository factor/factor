#pragma once
#include "os-unix-memory.hpp"
#include <image.h>

namespace factor {
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

// Haiku exposes __sighandler_t, rather than the BSD sig_t alias.
typedef __sighandler_t sig_t;
}

namespace factor::os {
inline segment_mapping map_segment(bool executable) {
  return default_segment_mapping(executable);
}
}
