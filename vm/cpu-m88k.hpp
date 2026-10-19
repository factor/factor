namespace factor {
#define FACTOR_CPU_STRING "m88k"
// Incoming return PCs describe the predecessor caller's spill area.
#define FACTOR_GC_ROOTS_AT_PREDECESSOR_SP 1
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
// Bytes after the PIC-address LI32 operand: target LI32 (8) plus JMP (4).
static const fixnum xt_tail_pic_offset = 12;
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 144;
static const unsigned FRAME_RETURN_ADDRESS = 4;

inline static void check_call_site(cell return_address) {
  const uint32_t* words = (const uint32_t*)(return_address - 12);
  FACTOR_ASSERT((words[0] & 0xffff0000) == 0x5ea00000); // or.u r21,r0,hi
  FACTOR_ASSERT((words[1] & 0xffff0000) == 0x5ab50000); // or r21,r21,lo
  FACTOR_ASSERT(words[2] == 0xf400c815 || words[2] == 0xf400c015);
  (void)words;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)cell(m88k_load_literal32((const uint32_t*)(return_address - 12)));
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  m88k_store_literal32((uint32_t*)(return_address - 12), uint32_t(target));
  flush_icache(return_address - 12, 8);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return *(const uint32_t*)(return_address - 4) == 0xf400c015;
}
}
