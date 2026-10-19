// Native OpenBSD N64 control: compile with clang++ -O2 -fPIC -Ivm.
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
namespace factor {
typedef uintptr_t cell;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_ZERO_DIVIDE=2,
       FP_TRAP_OVERFLOW=4, FP_TRAP_UNDERFLOW=8, FP_TRAP_INEXACT=16 };
}
#include "../os-openbsd-mips64.hpp"
static char alternate[65536];
static volatile sig_atomic_t caught, valid;
static unsigned captured;
extern "C" __attribute__((noreturn,noinline)) void redirected_entry(void) {
  // Calling libc from a PIC entry exercises the context's T9/GP handoff.
  printf("OpenBSD MIPS64 adapter FPE/PIC=%s csr=%08x caught=%d\n",
         valid && caught ? "PASS" : "FAIL", captured, (int)caught);
  fflush(stdout);
  _exit(valid && caught ? 0 : 1);
}
static void handler(int number, siginfo_t* info, void* raw) {
  char local;
  struct sigcontext* context = (struct sigcontext*)raw;
  captured = factor::uap_fpu_status(raw);
  valid = number==SIGFPE && info && info->si_signo==SIGFPE &&
          context->sc_fpused && UAP_PROGRAM_COUNTER(raw) &&
          UAP_STACK_POINTER(raw) &&
          (uintptr_t)&local >= (uintptr_t)alternate &&
          (uintptr_t)&local < (uintptr_t)(alternate+sizeof alternate) &&
          (factor::fpu_status(captured) & factor::FP_TRAP_ZERO_DIVIDE);
  const unsigned original = captured;
  factor::uap_clear_fpu_status(raw);
  const unsigned cleared = factor::uap_fpu_status(raw);
  valid = valid && !(cleared & ((0x1fu<<2)|(0x3fu<<12))) &&
          ((cleared & 0xf83)==(original & 0xf83));
  UAP_PROGRAM_COUNTER(raw) = (factor::cell)&redirected_entry;
  UAP_NATIVE_ENTRY(raw, (factor::cell)&redirected_entry);
  caught=1;
}
int main(void) {
  struct sigcontext synthetic;
  memset(&synthetic,0,sizeof synthetic);
  synthetic.sc_fpregs[32]=0x7c;
  if(factor::uap_fpu_status(&synthetic)) return 2;
  synthetic.sc_fpused=1;
  if(factor::fpu_status(factor::uap_fpu_status(&synthetic))!=31) return 3;
  stack_t stack; struct sigaction action;
  memset(&stack,0,sizeof stack); memset(&action,0,sizeof action);
  stack.ss_sp=alternate; stack.ss_size=sizeof alternate;
  if(sigaltstack(&stack,0)) return 4;
  action.sa_sigaction=handler; action.sa_flags=SA_SIGINFO|SA_ONSTACK;
  sigemptyset(&action.sa_mask);
  if(sigaction(SIGFPE,&action,0)) return 5;
  unsigned csr=0x400; double one=1,zero=0;
  __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop\n\t"
                   "ldc1 $f0,0(%1)\n\tldc1 $f2,0(%2)\n\tdiv.d $f4,$f0,$f2"
                   : : "r"(csr),"r"(&one),"r"(&zero) : "$f0","$f2","$f4","memory");
  puts("FAIL: enabled hardware divide did not trap"); return 6;
}
