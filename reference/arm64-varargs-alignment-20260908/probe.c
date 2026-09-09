#include <stdint.h>
typedef float v4 __attribute__((vector_size(16)));
struct prior { long long a,b,c; };
struct hva { v4 a,b; };
__attribute__((noinline)) uintptr_t align_named(struct prior prior, struct hva h, int tag, ...) {
    uintptr_t p = (uintptr_t)&h;
    __asm__("" : "+r"(p));
    return (p & 15) + prior.a + tag - 2;
}
struct result { uintptr_t alignment; v4 value; };
__attribute__((noinline)) struct result align_return(struct prior prior, int tag, ...) {
    register uintptr_t output __asm__("x8");
    __asm__("" : "=r"(output));
    struct result r = {(output & 15) + prior.a + tag - 2, {0,0,0,0}};
    return r;
}
