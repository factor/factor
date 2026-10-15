#include "mips.hpp"

namespace factor {
#if defined(FACTOR_MIPS64)
#if defined(__MIPSEL__)
#define FACTOR_CPU_STRING "mipsel.64"
#else
#define FACTOR_CPU_STRING "mips.64"
#endif
static const unsigned MIPS_CALL_BYTES = 36;
static const unsigned MIPS_LITERAL_BYTES = 28;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 592;
static const unsigned FRAME_RETURN_ADDRESS = 8;
#else
#if defined(__MIPSEL__)
#define FACTOR_CPU_STRING "mipsel.32"
#else
#define FACTOR_CPU_STRING "mips.32"
#endif
static const unsigned MIPS_CALL_BYTES = 16;
static const unsigned MIPS_LITERAL_BYTES = 8;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 320;
static const unsigned FRAME_RETURN_ADDRESS = 4;
#endif
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
static const unsigned JIT_FRAME_SIZE = 16;
inline static void check_call_site(cell return_address) {
  const uint32_t* p = (const uint32_t*)(return_address - MIPS_CALL_BYTES);
#ifdef FACTOR_MIPS64
  FACTOR_ASSERT((p[0] & 0xffff0000) == 0x34190000);
  for (unsigned i = 1; i < 6; i += 2) {
    FACTOR_ASSERT(p[i] == 0x0019cc38);
    FACTOR_ASSERT((p[i + 1] & 0xffff0000) == 0x37390000);
  }
#else
  FACTOR_ASSERT((p[0] & 0xffff0000) == 0x3c190000);
  FACTOR_ASSERT((p[1] & 0xffff0000) == 0x37390000);
#endif
  const unsigned jump = MIPS_LITERAL_BYTES / 4;
  FACTOR_ASSERT(p[jump] == 0x0320f809 || p[jump] == 0x03200008);
  FACTOR_ASSERT(p[jump + 1] == 0);
  (void)p;
  (void)jump;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  const uint32_t* p = (const uint32_t*)(return_address - MIPS_CALL_BYTES);
#ifdef FACTOR_MIPS64
  return (void*)mips_load_li64(p);
#else
  return (void*)cell(mips_load_li32(p));
#endif
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  uint32_t* p = (uint32_t*)(return_address - MIPS_CALL_BYTES);
#ifdef FACTOR_MIPS64
  mips_store_li64(p, target);
#else
  mips_store_li32(p, target);
#endif
  flush_icache(return_address - MIPS_CALL_BYTES, MIPS_LITERAL_BYTES);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return *(uint32_t*)(return_address - 8) == 0x03200008;
}
}
