#include <cstdint>
#include <cstdio>
#include <cstring>
#include "../os-freebsd-ppc.hpp"

int main() {
  ucontext_t native;
  uintptr_t sp;
  __asm__ __volatile__("mr %0,1" : "=r"(sp));
  if (getcontext(&native) != 0)
    return 1;
  uintptr_t saved_sp = UAP_STACK_POINTER(&native);
  if (saved_sp > sp || sp - saved_sp > 4096 || !UAP_PROGRAM_COUNTER(&native))
    return 2;

  ucontext_t context;
  std::memset(&context, 0, sizeof(context));
  UAP_STACK_POINTER(&context) = 0x1000;
  UAP_PROGRAM_COUNTER(&context) = 0x2000;
  UAP_GLOBAL_ENTRY_REGISTER(&context) = 0x3000;
  UAP_TOC_REGISTER(&context) = 0x4000;
  context.uc_mcontext.mc_fpscr = UINT64_C(0x12345678ffffffff);
  if (context.uc_mcontext.mc_gpr[1] != 0x1000 ||
      context.uc_mcontext.mc_srr0 != 0x2000 ||
      context.uc_mcontext.mc_gpr[12] != 0x3000 ||
      context.uc_mcontext.mc_gpr[2] != 0x4000 ||
      factor::uap_fpu_status(&context) != UINT32_MAX)
    return 3;
  factor::uap_clear_fpu_status(&context);
  if (context.uc_mcontext.mc_fpscr != UINT64_C(0x123456780007f8ff))
    return 4;
  std::puts("PASS native FreeBSD PowerPC getcontext and register/FPSCR accessors");
}
