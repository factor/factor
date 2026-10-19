#ifndef FACTOR_MIPS_SOFT_FLOAT_HPP
#define FACTOR_MIPS_SOFT_FLOAT_HPP

/* NetBSD N64 uses a soft C calling convention even on hardware-FP systems.
 * Keep arguments/results in their normal C ABI; only these operations use COP1.
 * The soft compiler cannot allocate FPRs, so fixed f0/f2/f4 are private here.
 */
#if defined(__NetBSD__) && defined(__mips__) && defined(__mips64) && defined(__mips_soft_float) && __SIZEOF_POINTER__ == 8
#define FACTOR_NETBSD_N64_HARDWARE_OPERATIONS 1
#define FACTOR_MIPS_BINARY(name, instruction) \
static inline double factor_mips_##name(double x, double y) { \
  double result; \
  __asm__ volatile(".set push\n\t.set hardfloat\n\t" \
                   "ldc1 $f0,0(%1)\n\tldc1 $f2,0(%2)\n\t" \
                   instruction " $f4,$f0,$f2\n\tsdc1 $f4,0(%0)\n\t.set pop" \
                   : : "r"(&result), "r"(&x), "r"(&y) : "memory"); \
  return result; \
}
FACTOR_MIPS_BINARY(add, "add.d")
FACTOR_MIPS_BINARY(subtract, "sub.d")
FACTOR_MIPS_BINARY(multiply, "mul.d")
FACTOR_MIPS_BINARY(divide, "div.d")
#undef FACTOR_MIPS_BINARY
#define FACTOR_MIPS_COMPARE(name, instruction) \
static inline int factor_mips_##name(double x, double y) { \
  unsigned int status; \
  __asm__ volatile(".set push\n\t.set hardfloat\n\t" \
                   "ldc1 $f0,0(%1)\n\tldc1 $f2,0(%2)\n\t" \
                   instruction " $f0,$f2\n\tnop\n\tcfc1 %0,$31\n\tnop\n\t.set pop" \
                   : "=r"(status) : "r"(&x), "r"(&y) : "memory"); \
  return (status >> 23) & 1; \
}
FACTOR_MIPS_COMPARE(equal, "c.eq.d")
FACTOR_MIPS_COMPARE(less, "c.lt.d")
FACTOR_MIPS_COMPARE(lesseq, "c.le.d")
#undef FACTOR_MIPS_COMPARE
static inline void factor_mips_raise_invalid(void) {
  volatile double result = factor_mips_divide(0.0, 0.0);
  (void)result;
}
#endif
#endif
