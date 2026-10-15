#pragma once
// PA-RISC 1.1 32-bit instruction fields. Addresses use an LDIL/LDO pair.
// The 21-bit LDIL immediate is permuted; LDO uses low-sign encoding.
namespace factor {
inline uint32_t hppa_encode_21(uint32_t value) {
  return ((value & 0x100000u) >> 20) | ((value & 0xffe00u) >> 8) |
         ((value & 0x180u) << 7) | ((value & 0x7cu) << 14) |
         ((value & 3u) << 12);
}
inline uint32_t hppa_decode_21(uint32_t field) {
  return ((field & 1u) << 20) | ((field & 0xffeu) << 8) |
         ((field & 0xc000u) >> 7) | ((field & 0x1f0000u) >> 14) |
         ((field & 0x3000u) >> 12);
}
inline uint32_t hppa_encode_14(int32_t value) {
  return ((uint32_t(value) & 0x1fffu) << 1) |
         ((uint32_t(value) >> 13) & 1u);
}
inline int32_t hppa_decode_14(uint32_t field) {
  return int32_t((field >> 1) & 0x1fffu) - int32_t((field & 1u) << 13);
}
inline uint32_t hppa_load_address(const uint32_t* p) {
  return (hppa_decode_21(p[0] & 0x1fffffu) << 11) +
         uint32_t(hppa_decode_14(p[1] & 0x3fffu));
}
inline void hppa_store_address(uint32_t* p, uint32_t address) {
  p[0] = (p[0] & ~0x1fffffu) | hppa_encode_21(address >> 11);
  p[1] = (p[1] & ~0x3fffu) | hppa_encode_14(address & 0x7ffu);
}
inline uintptr_t hppa_function_field(uintptr_t pointer, unsigned field) {
  if ((pointer & 2u) == 0) return field == 0 ? pointer : 0;
  return reinterpret_cast<const uintptr_t*>(pointer & ~uintptr_t(3))[field];
}
}
