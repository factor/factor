namespace factor {
#define FACTOR_CPU_STRING "m68k.32"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - sizeof(cell) * 5)
// Hardware JSR pushes a cell; the prolog reserves the remaining 12 bytes.
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned FRAME_RETURN_ADDRESS = 0;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 176;
// MOVEI.L's immediate ends immediately before the six-byte absolute JMP.
static const fixnum xt_tail_pic_offset = 6;
inline static void check_call_site(cell return_address) {
  FACTOR_ASSERT(m68k_call_site_p((const void*)return_address));
  (void)return_address;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(cell)m68k_call_target((const void*)return_address);
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  m68k_store_call_target((void*)return_address, (uint32_t)target);
  flush_icache(return_address - 6, 6);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return m68k_tail_call_site_p((const void*)return_address);
}
}
