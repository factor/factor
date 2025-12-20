namespace factor {

#define FACTOR_CPU_STRING "arm.64"

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char *)start, (char *)(start + len));
}

#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end)

inline static unsigned int call_site_opcode(cell return_address) {
  return *(unsigned int*)(return_address - 4);
}

inline static void check_call_site(cell return_address) {
  unsigned int opcode = call_site_opcode(return_address);
  FACTOR_ASSERT((opcode & 0x7c000000) == 0x14000000);
  (void)opcode;
}

inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(return_address + ((*(int*)(return_address - 4) & 0x03ffffff) << 6 >> 4));
}

inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  *(unsigned int*)(return_address - 4) = (*(unsigned int*)(return_address - 4) & 0xfc000000) | ((target - return_address + 4) >> 2 & 0x03ffffff);
}

inline static bool tail_call_site_p(cell return_address) {
  return !(call_site_opcode(return_address) >> 31);
}

static const unsigned JIT_FRAME_SIZE = 16;

// Must match the calculation in word jit-signal-handler-prolog in
// basis/bootstrap/assembler/arm.64.factor
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 288;

static const unsigned FRAME_RETURN_ADDRESS = 8;

}
