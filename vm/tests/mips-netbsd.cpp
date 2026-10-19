#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <sys/mman.h>
#include <ucontext.h>
#include <unistd.h>
namespace factor {
using cell = uintptr_t;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_OVERFLOW=2,
  FP_TRAP_UNDERFLOW=4, FP_TRAP_ZERO_DIVIDE=8, FP_TRAP_INEXACT=16 };
}
#include "../os-netbsd-mips.hpp"
static uint32_t *code;
static volatile sig_atomic_t seen;
static volatile sig_atomic_t fp_seen;
static volatile unsigned int saved_fcsr, saved_trap;
static volatile sig_atomic_t redirect_native;
static volatile int native_value = 42;
__attribute__((noinline)) static int native_target() { return native_value; }
static void handler(int sig, siginfo_t *info, void *raw) {
    ucontext_t *ctx = (ucontext_t*)raw;
    if (sig == SIGFPE) {
        saved_fcsr = factor::uap_fpu_status(ctx);
        saved_trap = info->si_trap;
        if (UAP_PROGRAM_COUNTER(ctx) != (uintptr_t)code ||
            factor::signal_fpu_status(factor::uap_fpu_status(ctx), info->si_trap) != factor::FP_TRAP_ZERO_DIVIDE)
            _exit(11);
        factor::uap_clear_fpu_status(ctx);
        ctx->uc_mcontext.__fpregs.__fp_r.__fp_dregs[0] = 42.0;
        UAP_PROGRAM_COUNTER(ctx) = (uintptr_t)(code + 1);
        ++fp_seen;
        return;
    }
    if (sig != SIGSEGV || info->si_addr != 0 ||
        UAP_PROGRAM_COUNTER(ctx) != (uintptr_t)code ||
        UAP_STACK_POINTER(ctx) == 0) _exit(10);
    if (redirect_native) {
        UAP_PROGRAM_COUNTER(ctx) = (uintptr_t)native_target;
        UAP_NATIVE_ENTRY(ctx, (uintptr_t)native_target);
        ++seen;
        return;
    }
    if (ctx->uc_mcontext.__gregs[_REG_T9] != (intptr_t)code) _exit(12);
    ctx->uc_mcontext.__gregs[_REG_V0] = 42;
    /* Explicit destination handles both normal and branch-delay exceptions. */
    UAP_PROGRAM_COUNTER(ctx) = (uintptr_t)(code + 2);
    ++seen;
}
int main(void) {
    static_assert(sizeof(void*) == 4 && sizeof(__greg_t) == 4, "true O32 context required");
    assert(factor::fpu_status(1u << 6) == factor::FP_TRAP_INVALID_OPERATION);
    assert(factor::fpu_status(1u << 15) == factor::FP_TRAP_ZERO_DIVIDE);
    assert(factor::signal_fpu_status(0, (1u << 14) | (1u << 12)) ==
        (factor::FP_TRAP_OVERFLOW | factor::FP_TRAP_INEXACT));
    ucontext_t scratch = {};
    UAP_NATIVE_ENTRY(&scratch, 42);
    assert(scratch.uc_mcontext.__gregs[_REG_T9] == 42);
    scratch.uc_mcontext.__fpregs.__fp_csr = 0xffffffffu;
    factor::uap_clear_fpu_status(&scratch);
    assert(factor::uap_fpu_status(&scratch) == (0xffffffffu & ~((0x1fu << 2) | (0x3fu << 12))));
    struct sigaction sa = {};
    sa.sa_sigaction = handler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    assert(sigaction(SIGSEGV, &sa, 0) == 0);
    assert(sigaction(SIGFPE, &sa, 0) == 0);
    code = (uint32_t*)mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    assert(code != MAP_FAILED);
    for (int delay = 0; delay != 2; ++delay) {
        assert(mprotect(code,4096,PROT_READ|PROT_WRITE) == 0);
        code[0] = delay ? 0x10000001 : 0x8c020000; /* beq zero,zero,+4 / lw v0,0(zero) */
        code[1] = delay ? 0x8c020000 : 0;
        code[2] = 0x03e00008; /* jr ra */
        code[3] = 0;
        factor::flush_icache((uintptr_t)code, 16);
        assert(mprotect(code,4096,PROT_READ|PROT_EXEC) == 0);
        assert(((int (*)(void))code)() == 42);
    }
    assert(seen == 2);
    redirect_native = 1;
    assert(mprotect(code,4096,PROT_READ|PROT_WRITE) == 0);
    code[0] = 0x8c020000; // lw v0,0(zero)
    code[1] = 0;
    factor::flush_icache((uintptr_t)code, 16);
    assert(mprotect(code,4096,PROT_READ|PROT_EXEC) == 0);
    assert(((int (*)(void))code)() == 42);
    assert(seen == 3);
    redirect_native = 0;
    assert(mprotect(code,4096,PROT_READ|PROT_WRITE) == 0);
    code[0] = 0x462e6003; // div.d f0,f12,f14
    code[1] = 0x03e00008; // jr ra
    code[2] = 0;
    factor::flush_icache((uintptr_t)code, 12);
    assert(mprotect(code,4096,PROT_READ|PROT_EXEC) == 0);
    unsigned int previous;
    __asm__ volatile("cfc1 %0,$31\n\tnop" : "=r"(previous));
    unsigned int divide_trap = 0x400;
    __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop" : : "r"(divide_trap) : "memory");
    assert(((double (*)(double,double))code)(1.0,0.0) == 42.0);
    __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop" : : "r"(previous) : "memory");
    assert(fp_seen == 1);
    printf("SIGFPE ucontext_fcsr=%x si_trap=%x\n", saved_fcsr, saved_trap);
    puts("O32 generated SIGSEGV, branch-delay PC, redirected PIC T9, SIGFPE/FCSR resume=PASS");
}
