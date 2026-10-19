/* Let the target libc describe the PowerPC signal context ABI. */
#define _GNU_SOURCE 1
#include <stdint.h>
#if !defined(__powerpc64__) || defined(FACTOR_PPC_FRAME_TEST)
#include "../vm/powerpc_frame.h"
#endif
#include <ucontext.h>
#include <signal.h>
#ifndef __FreeBSD__
#include <asm/ptrace.h>
#endif

uintptr_t *factor_powerpc_signal_registers(void *context) {
    ucontext_t *uc = context;
#if defined(__FreeBSD__)
    return (uintptr_t *)uc->uc_mcontext.mc_gpr;
#elif defined(__powerpc64__)
    return (uintptr_t *)uc->uc_mcontext.gp_regs;
#else
    return (uintptr_t *)uc->uc_mcontext.uc_regs->gregs;
#endif
}
uintptr_t *factor_powerpc_signal_pc(void *context) {
#ifdef __FreeBSD__
    return (uintptr_t *)&((ucontext_t *)context)->uc_mcontext.mc_srr0;
#else
    return &factor_powerpc_signal_registers(context)[32];
#endif
}
#if !defined(__powerpc64__) || defined(FACTOR_PPC_FRAME_TEST)
uintptr_t *factor_powerpc_signal_lr(void *context) {
#ifdef __FreeBSD__
    return (uintptr_t *)&((ucontext_t *)context)->uc_mcontext.mc_lr;
#else
    return &factor_powerpc_signal_registers(context)[PT_LNK];
#endif
}

#endif

#ifndef __FreeBSD__
static double *fpscr(void *context) {
    ucontext_t *uc = context;
#ifdef __powerpc64__
    return &uc->uc_mcontext.fp_regs[32];
#else
    return &uc->uc_mcontext.uc_regs->fpregs.fpscr;
#endif
}
#endif
uint32_t factor_powerpc_signal_fpscr(void *context) {
#ifdef __FreeBSD__
    return (uint32_t)((ucontext_t *)context)->uc_mcontext.mc_fpscr;
#else
    union { double floating; uint64_t bits; } value;
    value.floating = *fpscr(context);
    return (uint32_t)value.bits;
#endif
}
void factor_powerpc_signal_clear_fpscr(void *context) {
#ifdef __FreeBSD__
    ((ucontext_t *)context)->uc_mcontext.mc_fpscr &= UINT64_C(0xffffffff0007f8ff);
#else
    union { double floating; uint64_t bits; } value;
    value.floating = *fpscr(context);
    value.bits &= UINT64_C(0xffffffff0007f8ff);
    *fpscr(context) = value.floating;
#endif
}

uintptr_t factor_powerpc_signal_stack_size(void) {
    return SIGSTKSZ;
}

#if !defined(__powerpc64__) || defined(FACTOR_PPC_FRAME_TEST)
unsigned int factor_powerpc_frame_state(uintptr_t entry, uintptr_t end,
                                      uintptr_t pc, uintptr_t frame_size, uintptr_t prologue) {
    return (unsigned int)ppc_frame_state_from_prologue(entry, end, pc, frame_size, prologue);
}

#endif
