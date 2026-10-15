#include <stdint.h>
#include <assert.h>
#include <stdio.h>
struct gate_context { uintptr_t *frame; uintptr_t *factor_sp; };
static struct gate_context context;
static volatile int value = 32;
#ifdef ALTERNATE
#define EXTRA_PARAMETERS ,int e,int f,int g,int h,int i,int j,int k,int l
#define EXTRA_TYPES ,int,int,int,int,int,int,int,int
#define EXTRA_SUM (e+f+g+h+i+j+k+l-68)
#else
#define EXTRA_PARAMETERS
#define EXTRA_TYPES
#define EXTRA_SUM 0
#endif
/* Address escapes: GCC must emit an ABI/PIC callable function. */
__attribute__((noinline)) static int native_target(int a, int b, int c, int d EXTRA_PARAMETERS) {
    assert(context.frame != 0);
    assert(context.frame[0] != 0 && context.frame[1] != 0);
    assert(context.frame[0] == (uintptr_t)context.factor_sp);
#ifdef ALTERNATE
    assert((char *)context.frame == (char *)context.factor_sp + 128);
#else
    assert((char *)context.frame + 16 == (char *)context.factor_sp);
    /* The same root-map header offset applies to Factor and native calls. */
    assert(*(uintptr_t *)((char *)context.frame + 16 + 64) == 0x12345678);
#endif
    return value + a + b + c + d + EXTRA_SUM;
}
extern int call_gate(int (*)(int,int,int,int EXTRA_TYPES), struct gate_context *);
int main(void) {
    assert(call_gate(native_target, &context) == 42);
    puts("linked-frame native PIC gate=42");
}
