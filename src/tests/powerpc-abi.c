#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
void factor_powerpc_unwind(uintptr_t, uintptr_t, uintptr_t);
static void entry(uintptr_t quotation, uintptr_t stack) {
    assert(quotation == 0x12345678);
    assert(stack == 0x34567890);
    puts("PowerPC unwind branch and argument register assertions passed");
    exit(0);
}
int main(void) {
    uintptr_t code = (uintptr_t)&entry;
#if defined(__powerpc64__) && _CALL_ELF == 1
    code = *(uintptr_t *)code;
#endif
    factor_powerpc_unwind(code, 0x12345678, 0x34567890);
    abort();
}
