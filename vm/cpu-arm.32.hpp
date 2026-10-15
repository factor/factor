namespace factor {

#define FACTOR_CPU_STRING "arm.32"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)

// ARM-state calls use an inline absolute target, so code heaps are not
// constrained by the +/-32 MiB B/BL range. BLX preserves Thumb interworking
// for native functions. The branch following BLX skips the target literal.
//   ldr ip, [pc, #4]; blx ip; b +0; .word target
inline static void check_call_site(cell return_address) {
  const uint32_t* p = (const uint32_t*)(return_address - 8);
  FACTOR_ASSERT(p[0] == 0xe59fc004);
  FACTOR_ASSERT(p[1] == 0xe12fff3c || p[1] == 0xe12fff1c);
  FACTOR_ASSERT(p[2] == 0xea000000);
  (void)p;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)*(cell*)(return_address + 4);
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  *(cell*)(return_address + 4) = target;
  flush_icache(return_address + 4, sizeof(cell));
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return *(uint32_t*)(return_address - 4) == 0xe12fff1c;
}
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 224;
static const unsigned FRAME_RETURN_ADDRESS = 4;

}
