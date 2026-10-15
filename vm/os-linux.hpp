#pragma once
#include "os-unix-memory.hpp"
#include <sys/syscall.h>


namespace factor::os {
inline segment_mapping map_segment(bool executable) {
  return default_segment_mapping(executable);
}
}
