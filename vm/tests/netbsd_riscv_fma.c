/* Standalone native regression: cc -O2 -frounding-math this-file.c -lm. */
#include "../../src/netbsd-riscv-fma.h"
#include <assert.h>
#include <math.h>
#include <fenv.h>
int main(void) {
#if defined(__NetBSD__) && defined(__riscv) && __riscv_xlen == 64
    double (*d)(double, double, double) = (double (*)(double,double,double))factor_netbsd_math_symbol("fma");
    float (*s)(float, float, float) = (float (*)(float,float,float))factor_netbsd_math_symbol("fmaf");
    assert(d && s && !factor_netbsd_math_symbol("sin"));
    assert(d(0x1.0000000000001p0, 0x1.ffffffffffffep-1, -1) == -0x1p-104);
    assert(s(0x1.000002p0f, 0x1.fffffcp-1f, -1) == -0x1p-46f);
    assert(fesetround(FE_TONEAREST) == 0);
    assert(d(1, 1, 0x1p-53) == 1);
    assert(s(1, 1, 0x1p-24f) == 1);
    assert(fesetround(FE_UPWARD) == 0);
    assert(d(1, 1, 0x1p-53) == 0x1.0000000000001p0);
    assert(s(1, 1, 0x1p-24f) == 0x1.000002p0f);
    assert(fesetround(FE_DOWNWARD) == 0);
    assert(signbit(d(1, 1, -1)));
    assert(signbit(s(1, 1, -1)));
    assert(fesetround(FE_TONEAREST) == 0);
    feclearexcept(FE_ALL_EXCEPT);
    assert(isnan(d(INFINITY, 0, 1)));
    assert(fetestexcept(FE_INVALID));
    feclearexcept(FE_ALL_EXCEPT);
    assert(isnan(s(INFINITY, 0, 1)));
    assert(fetestexcept(FE_INVALID));
    assert(isinf(d(INFINITY, 1, 1)));
    assert(isinf(s(INFINITY, 1, 1)));
    assert(isnan(d(NAN, 1, 1)) && isnan(s(NAN, 1, 1)));
    assert(d(0x1p-1022, 0x1p-52, 0) == 0x1p-1074);
    assert(s(0x1p-126f, 0x1p-23f, 0) == 0x1p-149f);
#else
#error This regression requires native NetBSD RV64 with F/D extensions.
#endif
}
