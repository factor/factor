// Shared mmap defaults; selected OS headers provide map_segment().
#pragma once
#include <sys/mman.h>

namespace factor::os {
struct segment_mapping {
  int protection;
  int flags;
  bool separate_execute;
};

constexpr segment_mapping default_segment_mapping(bool executable) {
  return {PROT_READ | PROT_WRITE | (executable ? PROT_EXEC : 0),
          MAP_ANON | MAP_PRIVATE, false};
}
}
