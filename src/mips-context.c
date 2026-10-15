#include <stdint.h>
#include <ucontext.h>
static uintptr_t *cell_slot(void *slot) {
#if __SIZEOF_POINTER__ == 4 && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    return (uintptr_t *)slot + 1;
#else
    return (uintptr_t *)slot;
#endif
}
uintptr_t *factor_mips_signal_pc(void *context) { return cell_slot(&((ucontext_t *)context)->uc_mcontext.pc); }
uintptr_t *factor_mips_signal_sp(void *context) { return cell_slot(&((ucontext_t *)context)->uc_mcontext.gregs[29]); }
void factor_mips_signal_t9(void *context, uintptr_t target) { ((ucontext_t *)context)->uc_mcontext.gregs[25] = target; }
static const unsigned fcsr_exceptions = (0x1fu << 2) | (0x3fu << 12);
static unsigned live_fcsr(void) {
    unsigned value;
    __asm__ volatile("cfc1 %0,$31\n\tnop" : "=r"(value));
    return value;
}
static int live_fcsr_fault(unsigned value) {
    return ((value >> 7) & (value >> 12) & 0x1fu) || (value & (1u << 17));
}
unsigned factor_mips_signal_fcsr(void *context) {
    unsigned saved = ((ucontext_t *)context)->uc_mcontext.fpc_csr;
    /* QEMU Linux-user can leave the saved FCSR invalid on a real SIGFPE,
       while the live register still contains the fault's cause bits. */
    unsigned live = live_fcsr();
    return live_fcsr_fault(live) ? live : saved;
}
void factor_mips_signal_clear_fcsr(void *context) {
    unsigned *saved = &((ucontext_t *)context)->uc_mcontext.fpc_csr;
    unsigned live = live_fcsr();
    if (live_fcsr_fault(live)) {
        *saved = live;
        live &= ~fcsr_exceptions;
        __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop" : : "r"(live) : "memory");
    }
    *saved &= ~fcsr_exceptions;
}
__attribute__((noreturn)) void factor_mips_unwind(uintptr_t code, uintptr_t quotation, uintptr_t stack) {
    register uintptr_t target __asm__("$25") = code;
    register uintptr_t arg0 __asm__("$4") = quotation;
    register uintptr_t arg1 __asm__("$5") = stack;
    __asm__ volatile("jr %0\n\tnop" : : "r"(target), "r"(arg0), "r"(arg1) : "memory");
    __builtin_unreachable();
}
/* Exercise the libc layout and low-cell selection under the target ABI. */
int factor_mips_signal_context_probe(void) {
    ucontext_t context = {0};
    context.uc_mcontext.pc = UINT64_C(0x1234567887654320);
    context.uc_mcontext.gregs[29] = UINT64_C(0xabcdef0123456780);
    uintptr_t pc = (uintptr_t)context.uc_mcontext.pc;
    uintptr_t sp = (uintptr_t)context.uc_mcontext.gregs[29];
    if (*factor_mips_signal_pc(&context) != pc || *factor_mips_signal_sp(&context) != sp) return 1;
    *factor_mips_signal_pc(&context) = 0x76543210;
    if ((uintptr_t)context.uc_mcontext.pc != 0x76543210) return 2;
    factor_mips_signal_t9(&context, 0x12345678);
    if (context.uc_mcontext.gregs[25] != 0x12345678) return 3;
    context.uc_mcontext.fpc_csr = 0xffffffffu;
    factor_mips_signal_clear_fcsr(&context);
    if (factor_mips_signal_fcsr(&context) != (0xffffffffu & ~((0x1fu << 2) | (0x3fu << 12)))) return 4;
    return 0;
}
int factor_mips_fp_pair_probe(void) {
#if __SIZEOF_POINTER__ == 4
    uint32_t low, high;
    __asm__ volatile("mtc1 %2,$f0\n\tmtc1 %3,$f1\n\tmfc1 %0,$f0\n\tmfc1 %1,$f1"
                     : "=r"(low), "=r"(high)
                     : "r"(0x89abcdefu), "r"(0x12345678u)
                     : "$f0", "$f1");
    return low != 0x89abcdefu || high != 0x12345678u;
#else
    return 0;
#endif
}
