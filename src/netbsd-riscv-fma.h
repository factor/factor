/* NetBSD RV64 libm currently omits fma/fmaf. Use the hardware operation,
 * including the current rounding mode and IEEE exception flags. */
#ifndef FACTOR_NETBSD_RISCV_FMA_H
#define FACTOR_NETBSD_RISCV_FMA_H
#if defined(__NetBSD__) && defined(__riscv) && __riscv_xlen == 64
#include <string.h>
static double factor_netbsd_fma(double x, double y, double z) {
    double result;
    __asm__ volatile ("fmadd.d %0, %1, %2, %3, dyn"
                      : "=f" (result) : "f" (x), "f" (y), "f" (z));
    return result;
}
static float factor_netbsd_fmaf(float x, float y, float z) {
    float result;
    __asm__ volatile ("fmadd.s %0, %1, %2, %3, dyn"
                      : "=f" (result) : "f" (x), "f" (y), "f" (z));
    return result;
}
static void *factor_netbsd_math_symbol(const char *name) {
    if (strcmp(name, "fma") == 0) return (void *)&factor_netbsd_fma;
    if (strcmp(name, "fmaf") == 0) return (void *)&factor_netbsd_fmaf;
    return NULL;
}
#endif
#endif
