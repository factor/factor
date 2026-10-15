#define _GNU_SOURCE 1
#include <stdint.h>
#include <ucontext.h>
#include <signal.h>
#ifndef __FreeBSD__
#include <asm/ptrace.h>
#endif
#include <assert.h>
#include <stdio.h>
#include <string.h>
uintptr_t *factor_powerpc_signal_registers(void *);
uintptr_t *factor_powerpc_signal_pc(void *);
uintptr_t *factor_powerpc_signal_lr(void *);
uintptr_t factor_powerpc_signal_stack_size(void);
uint32_t factor_powerpc_signal_fpscr(void *);
void factor_powerpc_signal_clear_fpscr(void *);
int main(void) {
 ucontext_t uc; memset(&uc,0,sizeof uc);
#if defined(__FreeBSD__)
 uintptr_t *regs=(uintptr_t *)uc.uc_mcontext.mc_gpr;
#elif !defined(__powerpc64__)
 mcontext_t mc; memset(&mc,0,sizeof mc); uc.uc_mcontext.uc_regs=&mc;
 uintptr_t *regs=(uintptr_t *)mc.gregs;
 double *fp=&mc.fpregs.fpscr;
#else
 uintptr_t *regs=(uintptr_t *)uc.uc_mcontext.gp_regs;
 double *fp=&uc.uc_mcontext.fp_regs[32];
#endif
 assert(factor_powerpc_signal_stack_size()==SIGSTKSZ);
 assert(factor_powerpc_signal_registers(&uc)==regs);
 regs[1]=0x12345678; *factor_powerpc_signal_pc(&uc)=0x34567890;
 assert(factor_powerpc_signal_registers(&uc)[1]==0x12345678);
 assert(*factor_powerpc_signal_pc(&uc)==0x34567890);
#if !defined(__powerpc64__) || defined(FACTOR_PPC_FRAME_TEST)
 *factor_powerpc_signal_lr(&uc)=0x456789a0;
 assert(*factor_powerpc_signal_lr(&uc)==0x456789a0);
#ifdef __FreeBSD__
 assert(factor_powerpc_signal_lr(&uc)==(uintptr_t *)&uc.uc_mcontext.mc_lr);
#else
 assert(factor_powerpc_signal_lr(&uc)==&regs[PT_LNK]);
#endif
#endif
#ifdef __FreeBSD__
 assert(factor_powerpc_signal_pc(&uc)==(uintptr_t *)&uc.uc_mcontext.mc_srr0);
 uc.uc_mcontext.mc_fpscr=UINT64_C(0x12345678abcdef01);
 assert(factor_powerpc_signal_fpscr(&uc)==0xabcdef01);
 factor_powerpc_signal_clear_fpscr(&uc);
 assert(uc.uc_mcontext.mc_fpscr==UINT64_C(0x123456780005e801));
 ucontext_t native; uintptr_t sp; __asm__ __volatile__("mr %0,1" : "=r"(sp));
 assert(getcontext(&native)==0);
 uintptr_t saved=factor_powerpc_signal_registers(&native)[1];
 assert(saved<=sp && sp-saved<4096 && *factor_powerpc_signal_pc(&native));
#else
 union {uint64_t bits;double value;} v;
 v.bits=UINT64_C(0x12345678abcdef01); *fp=v.value;
 assert(factor_powerpc_signal_fpscr(&uc)==0xabcdef01);
 factor_powerpc_signal_clear_fpscr(&uc);
 v.value=*fp; assert(v.bits==UINT64_C(0x123456780005e801));
 #endif
 puts("PowerPC signal register and endian FPSCR assertions passed");
}
