#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <cstdint>
#include <cstdio>
#include <csignal>
#include <cfloat>
#include <cfenv>
#include <unistd.h>
#include <sys/wait.h>

namespace factor {
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_OVERFLOW = 2,
  FP_TRAP_UNDERFLOW = 4, FP_TRAP_ZERO_DIVIDE = 8, FP_TRAP_INEXACT = 16
};
}
#include "../os-linux-hppa.hpp"

static int expected;
static void trap(int signal, siginfo_t* info, void* raw) {
  auto* context = static_cast<ucontext_t*>(raw);
  unsigned status = factor::uap_fpu_status(context);
  unsigned flags = factor::signal_fpu_status(status, info->si_code);
  char buffer[256];
  int length = snprintf(buffer, sizeof(buffer),
      "sig=%d code=%d FR0=%016llx flags=%u expectedbit=%u\n",
      signal, info->si_code, context->uc_mcontext.sc_fr[0], flags, expected);
  write(1, buffer, length);
  _exit(flags == (factor::fpu_status(status) | expected) ? 0 : 1);
}

int main() {
  const int masks[] = { FE_INVALID, FE_DIVBYZERO, FE_OVERFLOW,
                        FE_UNDERFLOW, FE_INEXACT };
  const int bits[] = { 1, 8, 2, 4, 16 };
  int failures = 0;
  for (int mode = 0; mode < 5; mode++) {
    pid_t child = fork();
    if (child < 0) return 2;
    if (!child) {
      expected = bits[mode];
      struct sigaction action = {};
      action.sa_sigaction = trap;
      action.sa_flags = SA_SIGINFO;
      sigaction(SIGFPE, &action, nullptr);
      feclearexcept(FE_ALL_EXCEPT);
      if (feenableexcept(masks[mode]) < 0) _exit(3);
      volatile double zero = 0, one = 1, three = 3;
      volatile double high = DBL_MAX, low = DBL_MIN, result;
      switch (mode) {
        case 0: result = zero / zero; break;
        case 1: result = one / zero; break;
        case 2: result = high * high; break;
        case 3: result = low * low; break;
        case 4: result = one / three; break;
      }
      (void) result;
      _exit(2); // An enabled exception must deliver SIGFPE.
    }
    int status;
    waitpid(child, &status, 0);
    if (!WIFEXITED(status) || WEXITSTATUS(status)) failures++;
  }
  printf("actual-native-trap-cases=5 failures=%d\n", failures);
  return failures ? 1 : 0;
}
