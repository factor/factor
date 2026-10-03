// RISC-V instruction fields shared by relocations and inline-cache patching.
namespace factor {

inline int64_t riscv_signed_field(uint32_t value, unsigned bits) {
  const uint32_t mask = (uint32_t(1) << bits) - 1;
  value &= mask;
  return (value & (uint32_t(1) << (bits - 1)))
      ? int64_t(value) - (int64_t(1) << bits) : int64_t(value);
}

inline int64_t riscv_pair_displacement(const uint32_t* p) {
  return int64_t(int32_t(p[0] & 0xfffff000)) + riscv_signed_field(p[1] >> 20, 12);
}

inline void riscv_store_pair(uint32_t* p, int64_t value) {
  FACTOR_ASSERT(value >= INT32_MIN && value <= INT32_MAX - 2048);
  const int64_t low = riscv_signed_field(uint32_t(value), 12);
  p[0] = (p[0] & 0xfff) | (uint32_t(value - low) & 0xfffff000);
  p[1] = (p[1] & 0x000fffff) | ((uint32_t(low) & 0xfff) << 20);
}

inline int64_t riscv_jal_displacement(uint32_t p) {
  return riscv_signed_field(((p >> 31) << 20) | (((p >> 21) & 0x3ff) << 1) |
      (((p >> 20) & 1) << 11) | (p & 0xff000), 21);
}

inline int64_t riscv_branch_displacement(uint32_t p) {
  return riscv_signed_field(((p >> 31) << 12) | (((p >> 25) & 0x3f) << 5) |
      (((p >> 8) & 0xf) << 1) | (((p >> 7) & 1) << 11), 13);
}

inline uint32_t riscv_jal_bits(int64_t value) {
  FACTOR_ASSERT(value >= -1048576 && value < 1048576 && !(value & 1));
  uint32_t n = uint32_t(value);
  return ((n & 0x100000) << 11) | ((n & 0x7fe) << 20) |
      ((n & 0x800) << 9) | (n & 0xff000);
}

inline uint32_t riscv_branch_bits(int64_t value) {
  FACTOR_ASSERT(value >= -4096 && value < 4096 && !(value & 1));
  uint32_t n = uint32_t(value);
  return ((n & 0x1000) << 19) | ((n & 0x7e0) << 20) |
      ((n & 0x1e) << 7) | ((n & 0x800) >> 4);
}

// RV32 arithmetic wraps modulo 2^32. This also handles the rounded LUI
// immediate crossing INT32_MAX when the low ADDI immediate is negative.
inline uint32_t riscv_load_li32(const uint32_t* p) {
  return (p[0] & 0xfffff000) + uint32_t(riscv_signed_field(p[1] >> 20, 12));
}

inline void riscv_store_pair32(uint32_t* p, uint32_t value) {
  const uint32_t low = uint32_t(riscv_signed_field(value, 12));
  p[0] = (p[0] & 0xfff) | ((value - low) & 0xfffff000);
  p[1] = (p[1] & 0x000fffff) | ((low & 0xfff) << 20);
}

inline void riscv_store_li32(uint32_t* p, uint32_t value) {
  riscv_store_pair32(p, value);
}

inline uint64_t riscv_load_li(const uint32_t* p) {
  uint64_t value = uint64_t(int64_t(int32_t(p[0] & 0xfffff000)) +
      riscv_signed_field(p[1] >> 20, 12));
  for (unsigned i = 3; i < 8; i += 2)
    value = (value << 12) + uint64_t(riscv_signed_field(p[i] >> 20, 12));
  return value;
}

inline void riscv_store_li(uint32_t* p, uint64_t value) {
  int64_t v = int64_t(value);
  for (int i = 7; i >= 3; i -= 2) {
    int64_t low = riscv_signed_field(uint32_t(v), 12);
    p[i] = (p[i] & 0xfffff) | ((uint32_t(low) & 0xfff) << 20);
    v = (v >> 12) + (low < 0);
  }
  const int64_t low = riscv_signed_field(uint32_t(v), 12);
  p[0] = (p[0] & 0xfff) | (uint32_t(v - low) & 0xfffff000);
  p[1] = (p[1] & 0xfffff) | ((uint32_t(low) & 0xfff) << 20);
}

}
