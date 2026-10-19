#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <sys/mman.h>
#include <ucontext.h>
#include <unistd.h>
#ifdef ZIG_ICACHE
extern void factor_mips_flush(uintptr_t,size_t);
#endif
static uint32_t *code;
static volatile sig_atomic_t seen;
static void handler(int sig, siginfo_t *info, void *raw) {
    ucontext_t *ctx = raw;
    if (sig != SIGSEGV || info->si_addr != 0 ||
        ctx->uc_mcontext.pc != (uintptr_t)code ||
        ctx->uc_mcontext.gregs[29] == 0) _exit(10);
    ctx->uc_mcontext.gregs[2] = 42;
    /* Explicit destination handles both normal and branch-delay exceptions. */
    ctx->uc_mcontext.pc = (uintptr_t)(code + 2);
    ++seen;
}
int main(void) {
    struct sigaction sa = {0};
    sa.sa_sigaction = handler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    assert(sigaction(SIGSEGV, &sa, 0) == 0);
    code = mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    assert(code != MAP_FAILED);
    for (int delay = 0; delay != 2; ++delay) {
        assert(mprotect(code,4096,PROT_READ|PROT_WRITE) == 0);
        code[0] = delay ? 0x10000001 : 0x8c020000; /* beq zero,zero,+4 / lw v0,0(zero) */
        code[1] = delay ? 0x8c020000 : 0;
        code[2] = 0x03e00008; /* jr ra */
        code[3] = 0;
#ifdef ZIG_ICACHE
        factor_mips_flush((uintptr_t)code,16);
#else
        __builtin___clear_cache((char*)code,(char*)(code+4));
#endif
        assert(mprotect(code,4096,PROT_READ|PROT_EXEC) == 0);
        assert(((int (*)(void))code)() == 42);
    }
    assert(seen == 2);
    puts("resumable generated SIGSEGV and branch-delay PC=PASS");
}
