namespace factor {

#define FACTOR_CPU_STRING "arm.64"

#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 16)

inline static unsigned int call_site_opcode(cell return_address) {
  return *(unsigned int*)(return_address - 4);
}

inline static void check_call_site(cell return_address) {
  unsigned int opcode = call_site_opcode(return_address);
  FACTOR_ASSERT((opcode & 0x7c000000) == 0x14000000);
  (void)opcode;
}

constexpr fixnum arm64_branch_displacement(uint32_t opcode) {
  uint32_t imm26 = opcode & 0x03ffffff;
  fixnum signed_imm =
      (imm26 & 0x02000000) ? (fixnum)imm26 - ((fixnum)1 << 26) : imm26;
  return signed_imm * 4;
}

constexpr cell decode_arm64_call_target(cell return_address, uint32_t opcode) {
  return (cell)((fixnum)return_address - 4 +
                arm64_branch_displacement(opcode));
}

static_assert(decode_arm64_call_target(0x1004, 0x94000000) == 0x1000,
              "ARM64 branch targets are relative to the instruction");
static_assert(decode_arm64_call_target(0x1004, 0x97ffffff) == 0x0ffc,
              "ARM64 branch immediates must be sign-extended");

inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)decode_arm64_call_target(return_address,
                                         call_site_opcode(return_address));
}

inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  cell call_site = return_address - 4;
  *(unsigned int*)call_site =
      (*(unsigned int*)call_site & 0xfc000000) |
      ((target - return_address + 4) >> 2 & 0x03ffffff);
  // Without this the core can keep executing the stale branch from its
  // I-cache, so a stale branch can re-enter a PIC after it has been freed.
  flush_icache(call_site, 4);
}

inline static bool tail_call_site_p(cell return_address) {
  return !(call_site_opcode(return_address) >> 31);
}

static const unsigned JIT_FRAME_SIZE = 16;

// Must match the stack frame built by the signal-handler sub-primitive in
// basis/bootstrap/assembler/arm.64.factor
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 288;

static const unsigned FRAME_RETURN_ADDRESS = 8;

}
