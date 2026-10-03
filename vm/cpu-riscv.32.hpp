namespace factor {
#define FACTOR_CPU_STRING "riscv.32"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)

inline static void check_call_site(cell return_address) {
  const uint32_t* p = (const uint32_t*)(return_address - 8);
  FACTOR_ASSERT((p[0] & 0xfff) == 0x297); // AUIPC t0
  FACTOR_ASSERT((p[1] & 0xfffff) == 0x280e7 || (p[1] & 0xfffff) == 0x28067);
  (void)p;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(return_address - 8 + riscv_pair_displacement((const uint32_t*)(return_address - 8)));
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  riscv_store_pair32((uint32_t*)(return_address - 8), target - (return_address - 8));
  flush_icache(return_address - 8, 8);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return (*(uint32_t*)(return_address - 4) & 0xf80) == 0;
}
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 416;
static const unsigned FRAME_RETURN_ADDRESS = 4;
}
