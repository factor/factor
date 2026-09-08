#include <stdint.h>
#include <stdio.h>
int ffi_test_small_floats_available(void);
#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
#define DECLARE(T,N) \
T N##_from_bits(uint16_t); uint16_t N##_bits(T); \
T N##_overflow(T,T,T,T,T,T,T,T,T,T); \
T N##_callback(T (*)(T),T); double N##_varargs_spill(double,...); \
static T N##_cb(T x) { return x; }
DECLARE(_Float16,half)
DECLARE(__bf16,bfloat)
#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "%s failed\n", #expr); return 1; } } while (0)
int main(void) {
    CHECK(ffi_test_small_floats_available() == 1);
    for (unsigned i=0; i<65536; ++i) {
        CHECK(half_bits(half_from_bits(i)) == i);
        CHECK(bfloat_bits(bfloat_from_bits(i)) == i);
    }
    CHECK(half_overflow(1,2,3,4,5,6,7,8,9,10) == 55);
    CHECK(bfloat_overflow(1,2,3,4,5,6,7,8,9,10) == 55);
    CHECK(half_callback(half_cb, 1.5) == 1.5);
    CHECK(bfloat_callback(bfloat_cb, 1.5) == 1.5);
#define ARGS(T) 1.0,(T)1,1,(T)2,2,(T)3,3,(T)4,4,(T)5,5,(T)6,6,(T)7,7,(T)8,8,(T)9,9,(T)10,10
    CHECK(half_varargs_spill(ARGS(_Float16)) == 441);
    CHECK(bfloat_varargs_spill(ARGS(__bf16)) == 441);
    puts("C-CONTROL small executed=131078");
    return 0;
}
#else
int main(void) { puts("C-SKIP small reason=unsupported-toolchain-or-cpu"); return 77; }
#endif
