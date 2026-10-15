namespace factor {
#if defined(__SH_FPU_DOUBLE__)
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define FACTOR_CPU_STRING "sh4be.32"
#else
#define FACTOR_CPU_STRING "sh4.32"
#endif
#elif defined(__SH3__) && !defined(__SH4_NOFPU__) && !defined(__SH_FPU_ANY__)
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define FACTOR_CPU_STRING "sh3be.32"
#else
#define FACTOR_CPU_STRING "sh3.32"
#endif
#else
#error "Factor SuperH requires classic SH3 soft-float or SH4 double-precision ABI"
#endif
#define CALLSTACK_BOTTOM(ctx) (ctx->callstack_seg->end - 32)
static constexpr bool sh_little_endian = __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__;
static const unsigned JIT_FRAME_SIZE = 16;
static const unsigned FRAME_RETURN_ADDRESS = 4;
static const fixnum xt_tail_pic_offset = 6;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 512;
inline static void check_call_site(cell return_address) {
  FACTOR_ASSERT(sh_call_site_p((void*)return_address, sh_little_endian));
  (void)return_address;
}
inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(cell)sh_load_literal(sh_call_literal((void*)return_address, sh_little_endian), sh_little_endian);
}
inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  void* literal = sh_call_literal((void*)return_address, sh_little_endian);
  sh_store_literal(literal, target, sh_little_endian);
  flush_icache((cell)literal, sizeof(cell));
}
inline static bool tail_call_site_p(cell return_address) {
  check_call_site(return_address);
  return sh_load_instruction((void*)(return_address - 4), sh_little_endian) == 0x402b;
}
}
