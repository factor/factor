#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#ifdef M88K_HAS_INT64
extern uint64_t m88k_cxx17_int64(uint64_t);
#endif
extern unsigned m88k_cxx17_integer(unsigned, unsigned);
extern double m88k_cxx17_fp(double, double);
int main(void) {
    volatile unsigned a=5, b=7;
    volatile double x=1.25, y=2.5;
    assert(m88k_cxx17_integer(a,b)==42);
    assert(m88k_cxx17_fp(x,y)==5.0);
    #ifdef M88K_HAS_INT64
    assert(m88k_cxx17_int64(UINT64_C(0x100000000))==UINT64_C(0x223456789));
    puts("m88k C++17 int64 codegen/ABI gate PASS");
#endif
    puts("m88k C++17 language/codegen gate PASS: integer fp");
    puts("Modern C++ runtime and Factor VM are separate gates.");
    return 0;
}
