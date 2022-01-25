namespace factor {

#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - sizeof(cell) * 5) // omg

// void c_to_factor(cell quot);
// void lazy_jit_compile(cell quot);

// static const fixnum xt_tail_pic_offset = 4 + 1; // or 4 or whatever else...


// omg
inline static unsigned char call_site_opcode(cell return_address) {
  return *(unsigned char*)(return_address - 5);
}

// omg
inline static void check_call_site(cell return_address) {
  unsigned char opcode = call_site_opcode(return_address);
  FACTOR_ASSERT(opcode == call_opcode || opcode == jmp_opcode);
  (void)opcode; // suppress warning when compiling without assertions
}

// omg
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(*(int*)(return_address - 4) + return_address);
}

// omg
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  *(int*)(return_address - 4) = (uint32_t)(target - return_address);
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

}
