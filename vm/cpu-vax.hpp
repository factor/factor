#include "vax.hpp"

namespace factor {

#define FACTOR_CPU_STRING "vax.32"

VM_C_API cell vax_get_fpu_state();
VM_C_API void vax_set_fpu_state(cell state);
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - sizeof(cell) * 5)

// JSB pushes one cell; the Factor prolog reserves twelve more bytes.
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned FRAME_RETURN_ADDRESS = 0;
// Injected PC, MOVPSL, and PUSHR's R0..R11/AP/FP register save.
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 4 + 4 + 14 * 4;
// A register specifier follows MOVL's literal before the six-byte JMP.
static const fixnum xt_tail_pic_offset = 7;

inline static void check_call_site(cell return_address) {
  FACTOR_ASSERT(vax_call_site_p((const void*)return_address));
  (void)return_address;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(cell)vax_call_target((const void*)return_address);
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  vax_store_call_target((void*)return_address, (uint32_t)target);
  flush_icache(return_address - 6, 6);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return vax_tail_call_site_p((const void*)return_address);
}

}
