// LoongArch Linux native signal ABI probe; compile with the target C++ compiler.
#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <fenv.h>
#include <unistd.h>
namespace factor { using cell = uintptr_t; enum {FP_TRAP_INVALID_OPERATION=1,FP_TRAP_OVERFLOW=2,FP_TRAP_UNDERFLOW=4,FP_TRAP_ZERO_DIVIDE=8,FP_TRAP_INEXACT=16}; }
#include "../os-linux-loongarch.64.hpp"
static unsigned expected_trap = 8;
static void handler(int, siginfo_t* info,void* u) {
 unsigned status=factor::uap_fpu_status(u);
 unsigned trap=factor::signal_fpu_status(status, info->si_code);
 printf("LoongArch SIGFPE FCSR=%08x trap=%u PC=%llx SP=%llx\n",status,trap,(unsigned long long)UAP_PROGRAM_COUNTER(u),(unsigned long long)UAP_STACK_POINTER(u));
 fflush(stdout); _exit((trap & expected_trap) == expected_trap ? 0 : 2);
}
int main(int argc, char**) {
 struct sigaction sa={}; sa.sa_sigaction=handler; sa.sa_flags=SA_SIGINFO; sigemptyset(&sa.sa_mask);
 if(sigaction(SIGFPE,&sa,0)) return 3;
 if (argc > 1) {
   expected_trap = 2;
   if(feenableexcept(FE_OVERFLOW)==-1) return 4;
   volatile double a=1.0e308,b=1.0e308,c=a*b; (void)c;
 } else {
   if(feenableexcept(FE_DIVBYZERO)==-1) return 4;
   volatile double a=1.0,b=0.0,c=a/b; (void)c;
 }
 return 5;
}
