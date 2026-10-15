#pragma once
// Classic MIPS instruction fields shared by relocation and call-site patching.
// Instruction words use the target's native data byte order; callers provide
// aligned uint32_t storage. Fixed literal templates match cpu.mips.assembler.
namespace factor {
inline uint32_t mips_load_li32(const uint32_t* p) {
  return ((p[0] & 0xffff) << 16) | (p[1] & 0xffff);
}
inline void mips_store_li32(uint32_t* p, uint32_t value) {
  p[0] = (p[0] & 0xffff0000) | (value >> 16);
  p[1] = (p[1] & 0xffff0000) | (value & 0xffff);
}
inline uint64_t mips_load_li64(const uint32_t* p) {
  return (uint64_t(p[0] & 0xffff) << 48) |
      (uint64_t(p[2] & 0xffff) << 32) |
      (uint64_t(p[4] & 0xffff) << 16) | uint64_t(p[6] & 0xffff);
}
inline void mips_store_li64(uint32_t* p, uint64_t value) {
  for (unsigned i = 0; i < 4; ++i)
    p[i * 2] = (p[i * 2] & 0xffff0000) |
        uint32_t((value >> (48 - i * 16)) & 0xffff);
}
inline int32_t mips_branch_displacement(uint32_t instruction) {
  return int32_t(int16_t(instruction & 0xffff)) * 4;
}
inline void mips_store_branch(uint32_t* p, int64_t displacement) {
  FACTOR_ASSERT(displacement >= -131072 && displacement <= 131068 &&
                !(displacement & 3));
  *p = (*p & 0xffff0000) | (uint32_t(displacement / 4) & 0xffff);
}
}
