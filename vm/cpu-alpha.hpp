// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
namespace factor {
#define FACTOR_CPU_STRING "alpha.64"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
static const unsigned JIT_FRAME_SIZE = 32;
static const unsigned FRAME_RETURN_ADDRESS = 8;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 576;
// Literal loads use two aligned LDLs: embedded quads can be only 4-byte aligned.
inline void check_call_site(cell return_address) {
  uint32_t words[9];
  memcpy(words, (void*)(return_address - 36), sizeof(words));
  FACTOR_ASSERT(words[0] == 0xc3600002);
  FACTOR_ASSERT(words[3] == 0xa07b0004);
  FACTOR_ASSERT((words[8] & 0xfc1fbfff) == 0x681b0000);
  (void)words;
}
inline void* get_call_target(cell return_address) {
  check_call_site(return_address);
  cell target;
  memcpy(&target, (void*)(return_address - 32), sizeof(target));
  return (void*)target;
}
inline void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  memcpy((void*)(return_address - 32), &target, sizeof(target));
  // Publish the literal before a CPU fetches the patched call sequence.
  __sync_synchronize();
  flush_icache(return_address - 36, 36);
}
inline bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return (*(uint32_t*)(return_address - 4) >> 21 & 31) == 31;
}
}
