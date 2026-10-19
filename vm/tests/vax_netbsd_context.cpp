#define _NETBSD_SOURCE 1
#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "../assert.hpp"
#include "../layouts.hpp"
#include "../os-netbsd-vax.hpp"

#if !defined(__NetBSD__) || !defined(__vax__)
#error This test requires the actual NetBSD VAX context ABI.
#endif

static volatile sig_atomic_t context_valid;
static volatile sig_atomic_t observed_flags;
static volatile sig_atomic_t native_cause;
static uintptr_t resume_pc;

static void handler(int, siginfo_t* information, void* context) {
  context_valid = UAP_STACK_POINTER(context) != 0 && UAP_PROGRAM_COUNTER(context) != 0;
  observed_flags = factor::fpu_status(factor::uap_fpu_status(context));
  factor::uap_clear_fpu_status(context);
  if (resume_pc) {
    native_cause = information->si_code;
    UAP_PROGRAM_COUNTER(context) = resume_pc;
    ((ucontext_t*)context)->uc_mcontext.__gregs[_REG_R0] = 43;
  }
}

int main() {
  ucontext_t context = {};
  UAP_STACK_POINTER(&context) = 0x12345678;
  UAP_PROGRAM_COUNTER(&context) = 0x10203040;
  assert(context.uc_mcontext.__gregs[_REG_SP] == 0x12345678);
  assert(context.uc_mcontext.__gregs[_REG_PC] == 0x10203040);
  assert(sizeof(context.uc_mcontext.__gregs) == 17 * sizeof(uint32_t));
  assert(factor::vax_fpe_flags(FPE_FLTOVF) == factor::FP_TRAP_OVERFLOW);
  assert(factor::vax_fpe_flags(FPE_INTDIV) == 0);
  assert(factor::vax_fpe_flags(FPE_FLTINV) == factor::FP_TRAP_INVALID_OPERATION);
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGFPE, &action, nullptr) == 0);
  factor::software_fp_flags = factor::fp::divide_by_zero | factor::fp::inexact;
  assert(raise(SIGFPE) == 0);
  assert(context_valid);
  assert(observed_flags == (factor::FP_TRAP_ZERO_DIVIDE | factor::FP_TRAP_INEXACT));
  assert(factor::software_fp_flags == 0);
  // A real integer divide trap returns through the rewritten native context.
  const unsigned char procedure[] = {0, 0, 0xc7, 0, 1, 0x50, 0x04};
  size_t page = (size_t)sysconf(_SC_PAGESIZE);
  unsigned char* code = (unsigned char*)mmap(nullptr, page, PROT_READ | PROT_WRITE,
                                           MAP_PRIVATE | MAP_ANON, -1, 0);
  assert(code != MAP_FAILED);
  memcpy(code, procedure, sizeof(procedure));
  factor::flush_icache((uintptr_t)code, sizeof(procedure));
  assert(mprotect(code, page, PROT_READ | PROT_EXEC) == 0);
  resume_pc = (uintptr_t)(code + 6);
  assert(((int (*)(void))code)() == 43);
  assert(native_cause == FPE_INTDIV);
  resume_pc = 0;
  assert(munmap(code, page) == 0);
  puts("native NetBSD VAX writable SP/PC and FP signal state passed");
}
