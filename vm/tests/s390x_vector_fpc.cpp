#define _GNU_SOURCE 1
#include <cfenv>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <ucontext.h>
#include <sys/wait.h>
#include <unistd.h>
#include <cstdint>
#include <cassert>
#define FACTOR_ASSERT assert
#include "../s390x.hpp"
#ifdef S390X_ZIG_DECODER
extern "C" unsigned s390x_zig_fpc_status(unsigned);
#endif
static int expected_code, expected_vic;
static void handler(int, siginfo_t* info, void* raw) {
  auto* ctx = static_cast<ucontext_t*>(raw);
  unsigned fpc = ctx->uc_mcontext.fpregs.fpc;
  bool okay = info->si_code == expected_code &&
      ((fpc >> 8) & 15) == unsigned(expected_vic) &&
      factor::s390x_fpc_exceptions(fpc) == (0x00800000u >> (expected_vic - 1));
#ifdef S390X_ZIG_DECODER
  const unsigned statuses[] = {1, 8, 2, 4, 16};
  okay = okay && s390x_zig_fpc_status(fpc) == statuses[expected_vic - 1];
#endif
  char output[128];
  int size = snprintf(output, sizeof(output), "VECTOR-FPC-CONTEXT: si_code=%d fpc=%08x vic=%u expected=%d/%d %s\n", info->si_code, fpc, (fpc >> 8) & 15, expected_code, expected_vic, okay ? "PASS" : "FAIL");
  write(1, output, size);
  _exit(okay ? 0 : 2);
}
int main() {
  const int masks[] = {FE_INVALID, FE_DIVBYZERO, FE_OVERFLOW, FE_UNDERFLOW, FE_INEXACT};
  const int codes[] = {FPE_FLTINV, FPE_FLTDIV, FPE_FLTOVF, FPE_FLTUND, FPE_FLTRES};
  const double numerators[] = {0, 1, 1e308, 1e-308, 1};
  const double denominators[] = {0, 0, 1e-308, 1e308, 3};
  unsigned failures = 0;
  for (unsigned i = 0; i < 5; ++i) {
    pid_t pid = fork();
    if (pid == 0) {
      expected_code = codes[i]; expected_vic = i + 1;
      struct sigaction action = {};
      action.sa_sigaction = handler; action.sa_flags = SA_SIGINFO;
      sigemptyset(&action.sa_mask);
      if (sigaction(SIGFPE, &action, nullptr)) _exit(3);
      feclearexcept(FE_ALL_EXCEPT); feenableexcept(masks[i]);
      double result;
      asm volatile("ldr %%f2,%1\n ldr %%f4,%2\n wfddb %%v0,%%v2,%%v4\n ldr %0,%%f0" : "=f"(result) : "f"(numerators[i]), "f"(denominators[i]) : "f0", "f2", "f4", "cc");
      (void)result; _exit(4);
    }
    int status = 0;
    if (pid < 0 || waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status)) {
      ++failures;
      std::printf("VECTOR-CONTEXT-FAILED: VIC=%u wait-status=%d\n", i + 1, status);
    }
  }
  if (failures) return 1;
  std::puts("VECTOR-FPC-ALL-CONTEXTS-PASS");
}
