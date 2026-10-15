/* OpenBSD/m88k calling convention: arguments/result r2, r3; link r1. */
.text
.align 4
.globl m88k_code_start
.globl m88k_code_end
m88k_code_start:
    or %r2, %r0, 42
    jmp %r1
m88k_code_end:
.globl m88k_cache_sync
m88k_cache_sync:
    /* OpenBSD gcc/config/m88k/openbsdelf.h FINALIZE_TRAMPOLINE. */
    tb0 0, %r0, 451
    jmp %r1

.globl m88k_fp_start
.globl m88k_fp_end
m88k_fp_start:
    fadd.ddd %r2, %r2, %r2
    jmp %r1
m88k_fp_end:
.globl m88k_fault_start
.globl m88k_fault_insn
.globl m88k_fault_resume
.globl m88k_fault_end
m88k_fault_start:
    or %r2, %r0, 42
m88k_fault_insn:
    tb0 0, %r0, 502
m88k_fault_resume:
    jmp %r1
m88k_fault_end:

.globl m88k_branch_start
.globl m88k_branch_end
m88k_branch_start:
    br .+8
    bsr .-8
    bb0 2, %r1, .-8
m88k_branch_end:

.globl m88k_fsub_start
.globl m88k_fsub_end
m88k_fsub_start:
    fsub.ddd %r2, %r2, %r4
    jmp %r1
m88k_fsub_end:

.globl m88k_fmul_start
.globl m88k_fmul_end
m88k_fmul_start:
    fmul.ddd %r2, %r2, %r4
    jmp %r1
m88k_fmul_end:

.globl m88k_fdiv_start
.globl m88k_fdiv_end
m88k_fdiv_start:
    fdiv.ddd %r2, %r2, %r4
    jmp %r1
m88k_fdiv_end:

/* Relative control flow remains valid after copying the whole template. */
.globl m88k_call_start
.globl m88k_call_end
m88k_call_start:
    or %r10, %r0, %r1
    bsr m88k_call_add
    or %r1, %r0, %r10
    jmp %r1
m88k_call_add:
    addu %r2, %r2, 1
    jmp %r1
m88k_call_end:

.globl m88k_cond_start
.globl m88k_cond_end
m88k_cond_start:
    bb0 0, %r2, m88k_cond_even
    or %r2, %r0, 43
    br m88k_cond_return
m88k_cond_even:
    or %r2, %r0, 42
m88k_cond_return:
    jmp %r1
m88k_cond_end:

/* OpenBSD m88k atomic.h: xmem exchange; userland pipeline barrier trap 128. */
.globl m88k_atomic_exchange
m88k_atomic_exchange:
    xmem %r3, %r2, %r0
    tb1 0, %r0, 128
    or %r2, %r0, %r3
    jmp %r1
