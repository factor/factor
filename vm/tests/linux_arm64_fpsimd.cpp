#include <cstdint>
#include <cstdlib>
#include <iostream>
#if defined(__linux__) && defined(__aarch64__)
#include <signal.h>
#include <sys/ucontext.h>
#include <asm/sigcontext.h>
using cell = uintptr_t;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_ZERO_DIVIDE=8,
       FP_TRAP_OVERFLOW=2, FP_TRAP_UNDERFLOW=4, FP_TRAP_INEXACT=16 };
#include "../os-linux-arm.64.hpp"
static volatile sig_atomic_t observed;
static void handler(int, siginfo_t*, void* context) {
    observed = factor::uap_fpu_status(context);
    factor::uap_clear_fpu_status(context);
}
int main() {
    struct sigaction action = {};
    action.sa_sigaction = handler;
    action.sa_flags = SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    if (sigaction(SIGUSR1, &action, nullptr)) return 1;
    uint64_t saved, status, control;
    __asm__ volatile("mrs %0, fpcr" : "=r"(saved));
    control = saved | (1 << 9);
    __asm__ volatile("msr fpcr, %0\nmrs %0, fpcr" : "+r"(control));
    std::cout << "FP-EFFECTIVE zero-divide-trap=" << bool(control & (1 << 9)) << '\n';
    control = saved & ~(31 << 8);
    __asm__ volatile("msr fpcr, %0\nmsr fpsr, xzr" :: "r"(control));
    volatile double one = 1, zero = 0;
    volatile double result = one / zero;
    (void)result;
    if (raise(SIGUSR1)) return 1;
    __asm__ volatile("mrs %0, fpsr\nmsr fpcr, %1" : "=&r"(status) : "r"(saved));
    if (factor::fpu_status(observed) != FP_TRAP_ZERO_DIVIDE || status != 0) return 1;
    std::cout << "C-CONTROL cpp-fpsimd-context executed=1\n";
    return 0;
}
#else
int main() { std::cout << "C-SKIP cpp-fpsimd-context reason=requires-linux-aarch64\n"; return 77; }
#endif
