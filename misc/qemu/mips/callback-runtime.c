/* Real C callers for the compiler-loaded Factor callback lifecycle probe. */
#include <stdint.h>

long mips_invoke_int(long (*callback)(long), long n) {
    volatile uintptr_t sentinel = 0x12345678;
    long value = callback(n);
    return sentinel == 0x12345678 ? value : -1;
}

double mips_invoke_fp(double (*callback)(double, int), double x, int n) {
    volatile uintptr_t sentinel = 0x12345678;
    double value = callback(x, n);
    return sentinel == 0x12345678 ? value : -1.0;
}

double mips_mix(long i, double x, long j, double y) {
    return i + x + j + y;
}
