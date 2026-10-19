#pragma once
#include "os-unix-memory.hpp"
// NetBSD services shared by all selected CPU contexts.
#include <ucontext.h>
#include <sys/mman.h>

namespace factor::os {
inline segment_mapping map_segment(bool executable) {
  auto mapping = default_segment_mapping(executable);
  if (executable) mapping.protection |= PROT_MPROTECT(PROT_EXEC);
  return mapping;
}
}
