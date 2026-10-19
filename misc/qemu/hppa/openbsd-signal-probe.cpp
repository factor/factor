#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
namespace factor {
typedef uintptr_t cell;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_ZERO_DIVIDE=2,
       FP_TRAP_OVERFLOW=4, FP_TRAP_UNDERFLOW=8, FP_TRAP_INEXACT=16 };
}
#include "../../../vm/os-openbsd-hppa.hpp"
extern "C" unsigned hppa_fault();
extern "C" char hppa_resume[];
static volatile sig_atomic_t redirected;
static uintptr_t native_sp, factor_sp, gp;
static void handler(int sig, siginfo_t* info, void* raw) {
  struct sigcontext* c=(struct sigcontext*)raw;
  if(sig!=SIGSEGV || info->si_addr!=0) _Exit(2);
  native_sp=c->sc_regs[30]; factor_sp=UAP_STACK_POINTER(raw);
  gp=UAP_GLOBAL_POINTER(raw);
  uintptr_t pc=(uintptr_t)hppa_resume|(UAP_PROGRAM_COUNTER(raw)&3);
  UAP_PROGRAM_COUNTER(raw)=pc; UAP_NEXT_PROGRAM_COUNTER(raw)=pc+4;
  redirected++;
}
int main() {
  struct sigaction sa={}; sa.sa_sigaction=handler; sa.sa_flags=SA_SIGINFO;
  sigemptyset(&sa.sa_mask); if(sigaction(SIGSEGV,&sa,0)) return 1;
  unsigned result=hppa_fault(); struct sigcontext c={};
  c.sc_fpregs[0]=0xf8000042UL;
  unsigned traps=factor::fpu_status(factor::uap_fpu_status(&c));
  factor::uap_clear_fpu_status(&c);
  factor::flush_icache((uintptr_t)hppa_resume,8);
  printf("OpenBSD production context: ptr=%lu redirect=%d result=%u native-sp=%lx factor-r18=%lx gp=%lx traps=%u cleared=%lx\n",
    (unsigned long)sizeof(void*),redirected,result,(unsigned long)native_sp,
    (unsigned long)factor_sp,(unsigned long)gp,traps,c.sc_fpregs[0]);
  return !(sizeof(void*)==4 && redirected==1 && result==42 && native_sp && traps==31 && c.sc_fpregs[0]==0x42);
}
