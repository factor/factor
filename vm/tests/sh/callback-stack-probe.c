/* Execute bytes emitted by the production %callback-stack hook. */
#define _GNU_SOURCE 1
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
static const unsigned char emitted[] = {
#include "callback-stack.inc"
};
extern uintptr_t invoke_callback_stack(void *, const uintptr_t *);
__asm__(".text\n.align 2\n.global invoke_callback_stack\n"
        "invoke_callback_stack:\nmov.l r12,@-r15\nsts.l pr,@-r15\n"
        "mov r5,r12\njsr @r4\nnop\nlds.l @r15+,pr\n"
        "mov.l @r15+,r12\nrts\nnop\n");
int main(void) {
    uintptr_t saved[64] = {0};
    uintptr_t context[16] = {0};
    /* The host emitter's context layout is fixture data. The native VM's
     * 16-byte callstack_save offset is measured by layout-probe.cpp. */
    assert(sizeof emitted >= 8 && emitted[1] == 0x50);
    assert((emitted[0] & 0xf0) == 0xc0); /* MOV.L @(disp,R12),R0 */
    unsigned save_slot = emitted[0] & 15;
    context[save_slot] = (uintptr_t)saved;
    void *code = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    assert(code != MAP_FAILED);
    memcpy(code, emitted, sizeof emitted);
    __builtin___clear_cache(code, (char *)code + sizeof emitted);
    uintptr_t actual = invoke_callback_stack(code, context);
    assert(actual == (uintptr_t)saved + 112);
    printf("SH4-CALLBACK-STACK-NATIVE-PASS offset=%lu fixture-context-slot=%u\n",
           (unsigned long)(actual - (uintptr_t)saved), save_slot);
    return 0;
}
