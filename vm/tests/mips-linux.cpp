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
#include "../os-linux-mips.hpp"
static uint32_t *code;
static volatile sig_atomic_t seen;
static void handler(int sig, siginfo_t *info, void *raw) {
    ucontext_t *ctx = (ucontext_t*)raw;
    if (sig != SIGSEGV || info->si_addr != 0 ||
        UAP_PROGRAM_COUNTER(ctx) != (uintptr_t)code ||
        UAP_STACK_POINTER(ctx) == 0) _exit(10);
    ctx->uc_mcontext.gregs[2] = 42;
    /* Explicit destination handles both normal and branch-delay exceptions. */
    UAP_PROGRAM_COUNTER(ctx) = (uintptr_t)(code + 2);
    ++seen;
}
int main(void) {
    assert(factor::fpu_status(1u << 6) == factor::FP_TRAP_INVALID_OPERATION);
    assert(factor::fpu_status(1u << 15) == factor::FP_TRAP_ZERO_DIVIDE);
    ucontext_t scratch = {};
    scratch.uc_mcontext.fpc_csr = 0xffffffffu;
    factor::uap_clear_fpu_status(&scratch);
    assert(factor::uap_fpu_status(&scratch) == (0xffffffffu & ~((0x1fu << 2) | (0x3fu << 12))));
    struct sigaction sa = {};
    sa.sa_sigaction = handler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    assert(sigaction(SIGSEGV, &sa, 0) == 0);
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
    puts("resumable generated SIGSEGV and branch-delay PC=PASS");
}
