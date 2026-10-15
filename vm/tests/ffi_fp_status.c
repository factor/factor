#include <fenv.h>
#include <stdio.h>
#include "../mips-soft-float.hpp"
double ffi_fp_divide(double a, double b);
#ifndef ABI_CONTROL
double ffi_fp_divide(double a, double b) {
#if defined(FACTOR_NETBSD_N64_HARDWARE_OPERATIONS)
    return factor_mips_divide(a, b);
#else
    volatile double x=a, y=b;
    return x/y;
#endif
}
#else
int main(void) {
    feclearexcept(FE_ALL_EXCEPT);
    volatile double result = ffi_fp_divide(1, 0);
    (void)result;
    int status = fetestexcept(FE_DIVBYZERO);
    feclearexcept(FE_ALL_EXCEPT);
    printf("fp-zero-divide-status=%d\n", status != 0);
    return !status || ffi_fp_divide(4, 2) != 2;
}
#endif
