// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#if defined(__OpenBSD__)
#include "sparc-openbsd-stackghost.h"
#endif
namespace factor {
#ifdef FACTOR_64
#define FACTOR_CPU_STRING "sparc.64"
static const cell SPARC_STACK_BIAS = 2047;
static const unsigned JIT_FRAME_SIZE = 176;
#else
#define FACTOR_CPU_STRING "sparc.32"
static const cell SPARC_STACK_BIAS = 0;
static const unsigned JIT_FRAME_SIZE = 96;
#endif
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - JIT_FRAME_SIZE)
static const unsigned FRAME_RETURN_ADDRESS = 15 * sizeof(cell);
static const unsigned SPARC_FRAME_LINK = 14 * sizeof(cell);
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = JIT_FRAME_SIZE + 256;

inline cell sparc_frame_predecessor(cell frame) {
  return *(cell*)(frame + SPARC_FRAME_LINK) + SPARC_STACK_BIAS;
}
inline cell sparc_frame_return_address(cell frame) {
  cell saved = *(cell*)(frame + FRAME_RETURN_ADDRESS);
#if defined(__OpenBSD__)
  saved = factor_sparc_decode_i7(saved, factor_sparc_window_cookie);
#endif
  return saved + 8;
}
inline void sparc_set_frame_return_address(cell frame, cell address) {
#if defined(__OpenBSD__)
  cell* saved = (cell*)(frame + FRAME_RETURN_ADDRESS);
  *saved = factor_sparc_encode_i7(*saved, address - 8, factor_sparc_window_cookie);
#else
  *(cell*)(frame + FRAME_RETURN_ADDRESS) = address - 8;
#endif
}
inline bool sparc_indirect_call_site(cell return_address) {
  return (sparc_load_instruction((void*)(return_address - 8)) & 0xc1ffffff) == 0x81c06000;
}
inline cell sparc_call_literal_site(cell return_address) {
  return return_address - 8 - (sizeof(cell) == 8 ? 24 : 8);
}
inline void check_call_site(cell return_address) {
  const uint32_t instruction = sparc_load_instruction((void*)(return_address - 8));
  if (sparc_indirect_call_site(return_address)) {
    const uint8_t* p = (const uint8_t*)sparc_call_literal_site(return_address);
    if (sizeof(cell) == 4) {
      if ((sparc_load_instruction(p) & 0xffc00000) != 0x03000000 ||
          (sparc_load_instruction(p + 4) & 0xfffffc00) != 0x82106000) ::abort();
    } else {
      const uint32_t first = sparc_load_instruction(p);
      const uint32_t scratch = (first >> 25) & 31;
      if ((first & 0xc1c00000) != 0x01000000 || scratch == 0 || scratch == 1 ||
          (sparc_load_instruction(p + 4) & 0xfffffc00) !=
              (0x80102000 | (scratch << 25) | (scratch << 14)) ||
          sparc_load_instruction(p + 8) !=
              (0x81283020 | (scratch << 25) | (scratch << 14)) ||
          (sparc_load_instruction(p + 12) & 0xffc00000) != 0x03000000 ||
          (sparc_load_instruction(p + 16) & 0xfffffc00) != 0x82106000 ||
          sparc_load_instruction(p + 20) != (0x82104000 | scratch)) ::abort();
    }
    return;
  }
  if ((instruction >> 30) == 1) return;
  if ((instruction >> 30) == 0 && ((instruction >> 25) & 15) == 8 &&
      (((instruction >> 22) & 7) == 2 || ((instruction >> 22) & 7) == 1)) return;
  ::abort();
}
inline void* get_call_target(cell return_address) {
  check_call_site(return_address);
  if (sparc_indirect_call_site(return_address)) {
    void* literal = (void*)sparc_call_literal_site(return_address);
    return (void*)(cell)(sizeof(cell) == 8 ? sparc_load_set64(literal) : sparc_load_set32(literal));
  }
  const cell site = return_address - 8;
  return (void*)(site + sparc_branch_displacement((void*)site));
}
inline void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  if (sparc_indirect_call_site(return_address)) {
    const cell literal = sparc_call_literal_site(return_address);
    if (sizeof(cell) == 8) sparc_store_set64((void*)literal, target);
    else sparc_store_set32((void*)literal, target);
    flush_icache(literal, return_address - literal);
  } else {
    const cell site = return_address - 8;
    sparc_store_branch((void*)site, (fixnum)(target - site));
    flush_icache(site, 8);
  }
}
inline bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  const uint32_t instruction = sparc_load_instruction((void*)(return_address - 8));
  return sparc_indirect_call_site(return_address) ? ((instruction >> 25) & 31) == 0
                                               : instruction >> 30 == 0;
}
}
