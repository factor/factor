#include "powerpc.hpp"

namespace factor {

#ifdef FACTOR_64
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define FACTOR_CPU_STRING "ppc.64le"
#else
#define FACTOR_CPU_STRING "ppc.64"
#endif
#else
#define FACTOR_CPU_STRING "ppc.32"
#endif

static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 672;

static const unsigned JIT_FRAME_SIZE =
#if defined(FACTOR_64) && defined(_CALL_ELF) && _CALL_ELF == 2
    128;
#elif defined(FACTOR_64)
    144;
#else
    80;
#endif

static const unsigned FRAME_RETURN_ADDRESS =
#ifdef FACTOR_64
    16;
#else
    4;
#endif

#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)

// The target load operand ends before mtctr and bctr: eight bytes
// before the synthetic tail return address stored in r6.
static const fixnum xt_tail_pic_offset = 8;

VM_C_API void flush_icache(cell start, cell len);

// New sites load an unrestricted target into r12, then mtctr/bctr(l).
// Keep the relative form readable for previously generated images.
inline static bool long_call_site_p(cell return_address) {
  uint32_t branch = ppc_instruction(return_address - 4);
  if ((branch & ~uint32_t(1)) != 0x4e800420)
    return false;
  if (ppc_instruction(return_address - 8) != 0x7d8903a6)
    return false;
  cell start = return_address - (sizeof(cell) == 8 ? 28 : 16);
  if (sizeof(cell) == 8) {
    return (ppc_instruction(start) & 0xffff0000) == 0x3d800000 &&
           (ppc_instruction(start + 4) & 0xffff0000) == 0x618c0000 &&
           ppc_instruction(start + 8) == 0x798c07c6 &&
           (ppc_instruction(start + 12) & 0xffff0000) == 0x658c0000 &&
           (ppc_instruction(start + 16) & 0xffff0000) == 0x618c0000;
  }
  return (ppc_instruction(start) & 0xffff0000) == 0x3d800000 &&
         (ppc_instruction(start + 4) & 0xffff0000) == 0x618c0000;
}

inline static void check_call_site(cell return_address) {
  uint32_t insn = ppc_instruction(return_address - 4);
  FACTOR_ASSERT(long_call_site_p(return_address) ||
                (insn & 0xfc000002) == 0x48000000);
}

static const uint32_t b_mask = 0x3fffffc;

inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  if (long_call_site_p(return_address))
    return (void*)(cell)ppc_load_absolute(return_address - 8);
  uint32_t insn = ppc_instruction(return_address - 4);
  int32_t signed_addr = (int32_t)((insn & b_mask) << 6) >> 6;
  return (void*)(signed_addr + return_address - 4);
}

inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  cell start;
  cell size;
  if (long_call_site_p(return_address)) {
    ppc_store_absolute(return_address - 8, (fixnum)target);
    size = sizeof(cell) == 8 ? 28 : 16;
    start = return_address - size;
  } else {
    start = return_address - 4;
    size = 4;
    ppc_store_relative(return_address, (fixnum)target);
  }
  // Publish every modified load word, including sequences crossing a line.
  flush_icache(start, size);
}

inline static bool tail_call_site_p(cell return_address) {
  return (ppc_instruction(return_address - 4) & 0x1) == 0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x20000000)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x10000000)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08000000)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x04000000)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x02000000)
    r |= FP_TRAP_INEXACT;

  return r;
}

}
