namespace factor {
extern "C" int32_t hppa_divide_i32(int32_t lhs, int32_t rhs);
extern "C" int32_t hppa_remainder_i32(int32_t lhs, int32_t rhs);
#define FACTOR_CPU_STRING "hppa.32"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned FRAME_RETURN_ADDRESS = 4;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 1024;
inline static void check_call_site(cell return_address) {
  const uint32_t* p = (const uint32_t*)(return_address - 16);
  FACTOR_ASSERT((p[0] & 0xffe00000u) == 0x22c00000u);
  FACTOR_ASSERT((p[1] & 0xffffc000u) == 0x36d60000u);
  FACTOR_ASSERT((p[2] == 0xe6c02000u && p[3] == 0x37e23ffbu) ||
                (p[2] == 0xeac0c000u && p[3] == 0x08000240u));
  (void)p;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)cell(hppa_load_address((const uint32_t*)(return_address - 16)));
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  hppa_store_address((uint32_t*)(return_address - 16), target);
  flush_icache(return_address - 16, 8);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return *(const uint32_t*)(return_address - 8) == 0xeac0c000u;
}
}
