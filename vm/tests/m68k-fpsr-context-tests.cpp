#include "../master.hpp"
using namespace factor;
int main() {
  const unsigned current[]={0xe000,0x1000,0x0800,0x0400,0x0300};
  const unsigned accrued[]={0x80,0x40,0x20,0x10,0x08};
  for(unsigned i=0;i<5;++i) {
    if(fpu_status(current[i])!=(1u<<i) || fpu_status(accrued[i])!=(1u<<i)) return 1;
  }
  if(fpu_status(0x8000)!=FP_TRAP_INVALID_OPERATION ||
     fpu_status(0x4000)!=FP_TRAP_INVALID_OPERATION ||
     fpu_status(0x2000)!=FP_TRAP_INVALID_OPERATION) return 2;
  if(fpu_status(0xffff0007)) return 5;
  ucontext_t context{};
#if defined(__NetBSD__)
  context.uc_mcontext.__fpregs.__fp_psr=0xa55affff;
#else
  context.uc_mcontext.fpregs.f_psr=0xa55affff;
#endif
  if(uap_fpu_status(&context)!=0xa55affff) return 3;
  uap_clear_fpu_status(&context);
  if(uap_fpu_status(&context)!=0xa55a0007) return 4;
  puts("m68k FPSR signal context: current/accrued flags cleared, condition/quotient preserved PASS");
  return 0;
}
