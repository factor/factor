#include <stdint.h>

/* The Factor unwind word consumes r3=quotation and r4=restored stack. Its
 * VM address is embedded in the generated word; entering it abandons C. */
__attribute__((noreturn)) void factor_powerpc_unwind(uintptr_t code, uintptr_t quotation, uintptr_t stack) {
    register uintptr_t argument3 __asm__("r3") = quotation;
    register uintptr_t argument4 __asm__("r4") = stack;
    __asm__ volatile("mtctr %0\n\tbctr" : : "r"(code), "r"(argument3), "r"(argument4) : "ctr", "memory");
    __builtin_unreachable();
}
