/* Native SIGFPE probe linked to the Zig VM MIPS context helpers. */
#define _GNU_SOURCE
#undef NDEBUG
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <ucontext.h>
#include "../../../../src/mips-context.c"
static sigjmp_buf escape;
static volatile sig_atomic_t trapped;
static volatile uint32_t saved_context, handler_fcsr;
static uint32_t read_fcsr(void) {
    uint32_t x; __asm__ volatile("cfc1 %0,$31\n\tnop" : "=r"(x)); return x;
}
static void write_fcsr(uint32_t x) {
    __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop" :: "r"(x) : "memory");
}
static double divide(double a,double b) {
    double x; __asm__ volatile("div.d %0,%1,%2" : "=f"(x) : "f"(a),"f"(b)); return x;
}
static void handler(int sig, siginfo_t *info, void *context) {
    (void)info; assert(sig==SIGFPE);
    saved_context=((ucontext_t*)context)->uc_mcontext.fpc_csr; handler_fcsr=read_fcsr();
    assert((factor_mips_signal_fcsr(context)&0x8400)==0x8400);
    factor_mips_signal_clear_fcsr(context);
    assert((read_fcsr()&0x3f07c)==0);
    assert((((ucontext_t*)context)->uc_mcontext.fpc_csr&0x3f07c)==0);
    assert(factor_mips_signal_context_probe()==0);
    trapped=1;
    write_fcsr(read_fcsr() & ~0x3ff80u);
    siglongjmp(escape,1);
}
int main(void) {
    uint32_t original=read_fcsr(), base=original & ~0x3ffffu;
    struct sigaction action={0}; action.sa_sigaction=handler; action.sa_flags=SA_SIGINFO;
    sigemptyset(&action.sa_mask); assert(sigaction(SIGFPE,&action,0)==0);
    write_fcsr(base); assert((read_fcsr()&0xf80)==0);
    volatile double result=divide(1,0); (void)result;
    assert((read_fcsr()&0x20)!=0); assert((read_fcsr()&0x8000)!=0);
    write_fcsr(base); assert((read_fcsr()&0x3f07c)==0);
    for(unsigned mode=0;mode<4;mode++) { write_fcsr(base|mode); assert((read_fcsr()&3)==mode); }
    write_fcsr(base|0x400); assert((read_fcsr()&0x400)!=0);
    if(!sigsetjmp(escape,1)) { result=divide(1,0); assert(!"missing SIGFPE"); }
    assert(trapped); fprintf(stderr,"saved_context=%08x\n",saved_context); fprintf(stderr,"handler_fcsr=%08x\n",handler_fcsr); assert((handler_fcsr&0x8400)==0x8400);
    write_fcsr(base); assert(divide(4,2)==2); write_fcsr(original&~0x3f000u);
    printf("MIPS FCSR sticky flags, rounding, enable and SIGFPE hardware/context PASS csr=%08x\n",saved_context);
    return 0;
}
