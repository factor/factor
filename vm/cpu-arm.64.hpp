namespace factor {

#define FACTOR_CPU_STRING "arm.64"

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char *)start, (char *)(start + len));
}

#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - sizeof(cell) * 6)

// 3 B of LDR=BLR
static const unsigned int call_opcode = 0x14000003;
// X9 BR of LDR=BR
static const unsigned int jmp_opcode = 0xd61f0120;

inline static unsigned int call_site_opcode(cell return_address) {
  return *(unsigned int*)(return_address - 12);
}

inline static void check_call_site(cell return_address) {
  unsigned int opcode = call_site_opcode(return_address);
  FACTOR_ASSERT(opcode == call_opcode || opcode == jmp_opcode);
  (void)opcode; // suppress warning when compiling without assertions
}

inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(*(cell*)(return_address - sizeof(cell)));
}

inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  *(cell*)(return_address - sizeof(cell)) = target;
}

inline static bool tail_call_site_p(cell return_address) {
  switch (call_site_opcode(return_address)) {
    case jmp_opcode:
      return true;
    case call_opcode:
      return false;
    default:
      abort();
      return false;
  }
}

// inline static unsigned int fpu_status(unsigned int status) {
//   unsigned int r = 0;

//   if (status & 0x01)
//     r |= FP_TRAP_INVALID_OPERATION;
//   if (status & 0x04)
//     r |= FP_TRAP_ZERO_DIVIDE;
//   if (status & 0x08)
//     r |= FP_TRAP_OVERFLOW;
//   if (status & 0x10)
//     r |= FP_TRAP_UNDERFLOW;
//   if (status & 0x20)
//     r |= FP_TRAP_INEXACT;

//   return r;
// }

// Must match the stack-frame-size constant in
// basis/bootstrap/assembler/arm.64.factor
static const unsigned JIT_FRAME_SIZE = 64;

// Must match the calculation in word jit-signal-handler-prolog in
// basis/bootstrap/assembler/arm.64.factor
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 288;

static const unsigned FRAME_RETURN_ADDRESS = 8;

}
