namespace factor {
#define FACTOR_CPU_STRING "s390x"
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
inline static void check_call_site(cell return_address) {
  const unsigned char* p = (const unsigned char*)(return_address - 6);
  FACTOR_ASSERT(p[0] == 0xc0 && (p[1] == 0xe5 || p[1] == 0xf4));
  (void)p;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(return_address - 6 +
      s390x_branch_displacement((const unsigned char*)(return_address - 6)));
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  cell site = return_address - 6;
  s390x_store_branch((unsigned char*)site, int64_t(target) - int64_t(site));
  flush_icache(site, 6);
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return ((const unsigned char*)return_address)[-5] == 0xf4;
}
static const unsigned JIT_FRAME_SIZE = 16;
// Signal trampoline saves GPRs, FPRs, FPC and a native 160-byte save area.
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 448;
static const unsigned FRAME_RETURN_ADDRESS = 8;
}
