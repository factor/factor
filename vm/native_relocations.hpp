// The two remaining four-bit relocation classes are interpreted by the CPU.
// Operands point immediately after their instruction or fixed load sequence.
#pragma once
#if defined(FACTOR_M88K)
#include "m88k.hpp"
#elif defined(FACTOR_LOONGARCH64)
#include "loongarch.hpp"
#elif defined(FACTOR_HPPA)
#include "hppa.hpp"
#elif defined(FACTOR_MIPS)
#include "mips.hpp"
#elif defined(FACTOR_PPC)
#include "powerpc.hpp"
#elif defined(FACTOR_SPARC) || defined(FACTOR_SPARC32) || defined(FACTOR_SPARC64)
#include "sparc.hpp"
#elif defined(FACTOR_S390X)
#include "s390x.hpp"
#endif

namespace factor {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
#if defined(FACTOR_M88K)
  if (klass == RC_NATIVE_0)
    return m88k_load_literal32((const uint32_t*)(pointer - 8));
  uint32_t instruction;
  memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
  return relative_to - 4 + m88k_branch_displacement(instruction);
#elif defined(FACTOR_LOONGARCH64)
  if (klass == RC_NATIVE_1)
    return fixnum(loongarch_load_literal((const uint32_t*)(pointer - 32)));
  return fixnum(relative_to - 8 + loongarch_pair_displacement((const uint32_t*)(pointer - 8)));
#elif defined(FACTOR_ALPHA)
  (void)relative_to;
  if (klass == RC_NATIVE_1) {
    cell literal;
    memcpy(&literal, (void*)(pointer - 28), sizeof(literal));
    return fixnum(literal);
  }
  uint32_t instruction;
  memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
  fixnum displacement = instruction & 0x1fffff;
  if (displacement & 0x100000) displacement -= 0x200000;
  return relative_to + displacement * 4;
#elif defined(FACTOR_HPPA)
  (void)relative_to;
  const auto* p = (const uint32_t*)pointer;
  return klass == RC_NATIVE_0 ? fixnum(hppa_load_address(p - 2))
                             : fixnum(hppa_decode_14(p[-1] & 0x3fff));
#elif defined(FACTOR_MIPS)
  (void)relative_to;
  if (klass == RC_NATIVE_1) {
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    return int16_t(instruction & 0xffff);
  }
  if (sizeof(cell) == 8) {
    uint32_t words[7];
    memcpy(words, (void*)(pointer - 28), sizeof(words));
    return fixnum(mips_load_li64(words));
  }
  uint32_t words[2];
  memcpy(words, (void*)(pointer - 8), sizeof(words));
  return fixnum(mips_load_li32(words));
#elif defined(FACTOR_PPC)
  return klass == RC_NATIVE_0 ? ppc_load_absolute(pointer)
                              : ppc_load_relative(pointer, relative_to);
#elif defined(FACTOR_SPARC) || defined(FACTOR_SPARC32) || defined(FACTOR_SPARC64)
  if (klass == RC_NATIVE_1)
    return sizeof(cell) == 8 ? fixnum(sparc_load_set64((void*)(pointer - 24)))
                            : fixnum(sparc_load_set32((void*)(pointer - 8)));
  const unsigned bits = sparc_branch_bits((void*)(pointer - 4));
  if (!bits) critical_error("Unsupported SPARC branch template", pointer);
  return fixnum(relative_to - 4 + cell(sparc_displacement((void*)(pointer - 4), bits)));
#elif defined(FACTOR_S390X)
  if (klass == RC_NATIVE_1)
    return fixnum(s390x_load_immediate((const unsigned char*)(pointer - 12)));
  return fixnum(relative_to - 6 + cell(s390x_branch_displacement(
      (const unsigned char*)(pointer - 6))));
#else
  (void)pointer; (void)relative_to;
  critical_error("Native relocation class is unsupported on this CPU", klass);
  return 0;
#endif
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
#if defined(FACTOR_M88K)
  if (klass == RC_NATIVE_0)
    m88k_store_literal32((uint32_t*)(pointer - 8), uint32_t(absolute));
  else
    m88k_store_branch((uint32_t*)(pointer - 4), int32_t(absolute - pointer + 4));
#elif defined(FACTOR_LOONGARCH64)
  if (klass == RC_NATIVE_1)
    loongarch_store_literal((uint32_t*)(pointer - 32), cell(absolute));
  else
    loongarch_store_pair((uint32_t*)(pointer - 8), int64_t(absolute) - int64_t(pointer - 8));
#elif defined(FACTOR_ALPHA)
  if (klass == RC_NATIVE_1) {
    memcpy((void*)(pointer - 28), &absolute, sizeof(absolute));
  } else {
    fixnum displacement = absolute - pointer;
    if ((displacement & 3) || displacement < -4194304 || displacement > 4194300)
      critical_error("Alpha branch displacement out of range", displacement);
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
    instruction = (instruction & 0xffe00000) | ((uint32_t)(displacement / 4) & 0x1fffff);
    memcpy((void*)(pointer - 4), &instruction, sizeof(instruction));
  }
#elif defined(FACTOR_HPPA)
  auto* p = (uint32_t*)pointer;
  if (klass == RC_NATIVE_0) hppa_store_address(p - 2, cell(absolute));
  else {
    if (absolute < -8192 || absolute > 8191)
      critical_error("HPPA signed immediate out of range", absolute);
    p[-1] = (p[-1] & ~0x3fffu) | hppa_encode_14(absolute);
  }
#elif defined(FACTOR_MIPS)
  if (klass == RC_NATIVE_1) {
    if (absolute < -32768 || absolute > 32767)
      critical_error("MIPS instruction immediate out of range", absolute);
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    instruction = (instruction & 0xffff0000) | (uint32_t(absolute) & 0xffff);
    memcpy((void*)(pointer - 4), &instruction, 4);
  } else if (sizeof(cell) == 8) {
    uint32_t words[7];
    memcpy(words, (void*)(pointer - 28), sizeof(words));
    mips_store_li64(words, cell(absolute));
    memcpy((void*)(pointer - 28), words, sizeof(words));
  } else {
    uint32_t words[2];
    memcpy(words, (void*)(pointer - 8), sizeof(words));
    mips_store_li32(words, cell(absolute));
    memcpy((void*)(pointer - 8), words, sizeof(words));
  }
#elif defined(FACTOR_PPC)
  if (klass == RC_NATIVE_0) ppc_store_absolute(pointer, absolute);
  else ppc_store_relative(pointer, absolute);
#elif defined(FACTOR_SPARC) || defined(FACTOR_SPARC32) || defined(FACTOR_SPARC64)
  if (klass == RC_NATIVE_1) {
    if (sizeof(cell) == 8) sparc_store_set64((void*)(pointer - 24), cell(absolute));
    else sparc_store_set32((void*)(pointer - 8), cell(absolute));
  } else {
    const unsigned bits = sparc_branch_bits((void*)(pointer - 4));
    if (!bits) critical_error("Unsupported SPARC branch template", pointer);
    const fixnum displacement = fixnum(cell(absolute) - pointer + 4);
    const int64_t limit = INT64_C(1) << (bits + 1);
    if ((displacement & 3) || displacement < -limit || displacement >= limit)
      critical_error("SPARC branch displacement out of range", displacement);
    sparc_store_displacement((void*)(pointer - 4), displacement, bits);
  }
#elif defined(FACTOR_S390X)
  if (klass == RC_NATIVE_1)
    s390x_store_immediate((unsigned char*)(pointer - 12), cell(absolute));
  else {
    const fixnum displacement = fixnum(cell(absolute) - pointer + 6);
    if ((displacement & 1) || displacement < INT64_C(-4294967296) ||
        displacement > INT64_C(4294967294))
      critical_error("System z branch displacement out of range", displacement);
    s390x_store_branch((unsigned char*)(pointer - 6), displacement);
  }
#else
  (void)pointer; (void)absolute;
  critical_error("Native relocation class is unsupported on this CPU", klass);
#endif
}
}
