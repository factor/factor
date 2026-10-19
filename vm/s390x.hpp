#pragma once
// System z instruction and FPC fields shared by the VM and its oracles.
// Bytes are accessed individually: instructions are only halfword aligned.
namespace factor {
inline uint32_t s390x_load_u32(const unsigned char* p) {
  return (uint32_t(p[0]) << 24) | (uint32_t(p[1]) << 16) |
         (uint32_t(p[2]) << 8) | uint32_t(p[3]);
}
inline void s390x_store_u32(unsigned char* p, uint32_t value) {
  p[0] = value >> 24; p[1] = value >> 16;
  p[2] = value >> 8; p[3] = value;
}
inline int64_t s390x_branch_displacement(const unsigned char* p) {
  return int64_t(int32_t(s390x_load_u32(p + 2))) * 2;
}
inline void s390x_store_branch(unsigned char* p, int64_t value) {
  FACTOR_ASSERT(!(value & 1) && value >= INT64_C(-4294967296) &&
                value <= INT64_C(4294967294));
  s390x_store_u32(p + 2, uint32_t(value / 2));
}
inline uint64_t s390x_load_immediate(const unsigned char* p) {
  return (uint64_t(s390x_load_u32(p + 2)) << 32) | s390x_load_u32(p + 8);
}
inline void s390x_store_immediate(unsigned char* p, uint64_t value) {
  s390x_store_u32(p + 2, value >> 32);
  s390x_store_u32(p + 8, value);
}
// Scalar traps encode IEEE bits in DXC; vector traps encode an element
// index and VIC 1..5 in that byte. Trapped vector instructions do not update
// accrued flags, so decode their VIC independently of the element index.
inline unsigned int s390x_fpc_exceptions(unsigned int fpc) {
  unsigned int vic = (fpc >> 8) & 0xf;
  unsigned int trapped = vic >= 1 && vic <= 5
      ? 0x00800000u >> (vic - 1)
      : (fpc & 0x0000f800u) << 8;
  return (fpc | trapped) & 0x00f80000u;
}
}
