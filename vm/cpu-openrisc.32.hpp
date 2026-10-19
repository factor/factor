#include "openrisc.hpp"

namespace factor {
#define FACTOR_CPU_STRING "openrisc.32"
VM_C_API uint64_t openrisc_single_to_double(uint32_t bits);
VM_C_API uint32_t openrisc_double_to_single(uint32_t high, uint32_t low);
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
static const unsigned OPENRISC_CALL_BYTES = 16;
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 512;
static const unsigned FRAME_RETURN_ADDRESS = 4;
inline static void check_call_site(cell return_address) {
  const uint32_t* p = (const uint32_t*)(return_address - OPENRISC_CALL_BYTES);
  bool r11 = (p[0] & 0xffff0000) == 0x19600000 &&
             (p[1] & 0xffff0000) == 0xa96b0000 &&
             (p[2] == 0x48005800 || p[2] == 0x44005800);
  bool r15 = (p[0] & 0xffff0000) == 0x19e00000 &&
             (p[1] & 0xffff0000) == 0xa9ef0000 &&
             (p[2] == 0x48007800 || p[2] == 0x44007800);
  FACTOR_ASSERT(r11 || r15);
  FACTOR_ASSERT(p[3] == 0x15000000);
  (void)p;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)cell(openrisc_load_li32((const uint32_t*)(return_address - OPENRISC_CALL_BYTES)));
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  openrisc_store_li32((uint32_t*)(return_address - OPENRISC_CALL_BYTES), target);
  flush_icache(return_address - OPENRISC_CALL_BYTES, 8);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  uint32_t jump = *(uint32_t*)(return_address - 8);
  return jump == 0x44005800 || jump == 0x44007800;
}
}
