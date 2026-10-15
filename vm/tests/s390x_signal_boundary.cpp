// Native System z signal redirection must provide Linux's caller save area.
#include <cassert>
#include <csetjmp>
#include <csignal>
#include <cstdio>
#include <cstdint>
#include <initializer_list>
#include <ucontext.h>

static sigjmp_buf original_stack;
alignas(16) static unsigned char signal_stack[65536];
static uintptr_t* frame;
static uintptr_t reserve;
static bool preserved;

__attribute__((noinline,noreturn)) static void native_error_handler() {
    // Force GCC to save all the ABI-preserved GPRs in the caller's area.
    asm volatile("" ::: "r6", "r7", "r8", "r9", "r10", "r11", "r13");
    preserved = true;
    for (unsigned i=0; i<16; ++i)
        preserved &= frame[i] == UINT64_C(0xfac7000000000000)+i;
    siglongjmp(original_stack,1);
}

static void redirect(int, siginfo_t*, void* raw) {
    auto* context=static_cast<ucontext_t*>(raw);
    context->uc_mcontext.gregs[15]=reinterpret_cast<uintptr_t>(frame)-reserve;
    context->uc_mcontext.psw.addr=reinterpret_cast<uintptr_t>(native_error_handler);
}

int main() {
    struct sigaction action{};
    action.sa_sigaction=redirect;
    action.sa_flags=SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    assert(sigaction(SIGUSR1,&action,nullptr)==0);
    frame=reinterpret_cast<uintptr_t*>(signal_stack+sizeof(signal_stack)-256);
    for (uintptr_t gap: {uintptr_t(0),uintptr_t(160)}) {
        reserve=gap;
        for (unsigned i=0;i<16;++i) frame[i]=UINT64_C(0xfac7000000000000)+i;
        if (sigsetjmp(original_stack,1)==0) raise(SIGUSR1);
        assert(preserved==(gap==160));
    }
    puts("System z native signal handler save area preserves Factor frames PASS");
}
