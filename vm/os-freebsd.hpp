#pragma once
#include "os-unix-memory.hpp"
namespace factor {

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}

namespace factor::os {
inline segment_mapping map_segment(bool executable) {
  return default_segment_mapping(executable);
}
}
