#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <cstdint>
#include <csignal>
#include <sys/mman.h>
namespace factor {
using cell = uintptr_t;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_ZERO_DIVIDE=2, FP_TRAP_OVERFLOW=4, FP_TRAP_UNDERFLOW=8, FP_TRAP_INEXACT=16 };
}
#include "os-openbsd-arm.32.hpp"
static volatile sig_atomic_t seen;
static void handler(int, siginfo_t*, void* uap) {
  auto sc = (struct sigcontext*)uap;
  if (!UAP_STACK_POINTER(sc) || !UAP_PROGRAM_COUNTER(sc)) _Exit(2);
  if (!sc->sc_fpused || !(factor::uap_fpu_status(sc)&1)) _Exit(3);
  factor::uap_clear_fpu_status(sc);
  if (factor::uap_fpu_status(sc)&0x9f) _Exit(4);
  seen=1;
}
int main() {
#define SHOW(f) printf(#f "=%zu\n", offsetof(struct sigcontext,f))
  SHOW(sc_usr_sp); SHOW(sc_pc); SHOW(sc_fpused); SHOW(sc_fpscr); SHOW(sc_fpreg);
  printf("ptr=%zu context=%zu\n",sizeof(void*),sizeof(struct sigcontext));
  auto code = (unsigned*)mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANON,-1,0);
  if (code==MAP_FAILED) return 5;
  code[0]=0xe3a0002a; code[1]=0xe12fff1e;
  factor::flush_icache((uintptr_t)code,8);
  if (((int(*)())code)()!=42) return 6;
  code[0]=0xe3a00007; factor::flush_icache((uintptr_t)code,8);
  if (((int(*)())code)()!=7) return 7;
  struct sigaction sa={}; sa.sa_sigaction=handler; sa.sa_flags=SA_SIGINFO;
  sigemptyset(&sa.sa_mask); if(sigaction(SIGUSR1,&sa,nullptr))return 8;
  unsigned fpscr; asm volatile("vmrs %0, fpscr":"=r"(fpscr)); fpscr|=1;
  asm volatile("vmsr fpscr, %0"::"r"(fpscr)); raise(SIGUSR1);
  asm volatile("vmrs %0, fpscr":"=r"(fpscr));
  if(!seen || fpscr&0x9f)return 9;
  printf("OpenBSD ARM32 native saved-context FP clear + mutable executable cache PASS\n");
}
