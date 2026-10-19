#pragma once

namespace factor {
inline uint32_t openrisc_load_li32(const uint32_t* p) {
  return ((p[0] & 0xffff) << 16) | (p[1] & 0xffff);
}
inline void openrisc_store_li32(uint32_t* p, uint32_t value) {
  p[0] = (p[0] & 0xffff0000) | (value >> 16);
  p[1] = (p[1] & 0xffff0000) | (value & 0xffff);
}
}
