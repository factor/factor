/* Compile with native GNU -mabi=64 -msoft-float -O2; do not enable fast math. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../../../vm/mips-soft-float.hpp"
#ifndef FACTOR_NETBSD_N64_HARDWARE_OPERATIONS
#error This control requires the NetBSD N64 soft C ABI
#endif
static unsigned csr(void) {
  unsigned r;
  __asm__ volatile(".set push\n.set hardfloat\ncfc1 %0,$31\nnop\n.set pop" : "=r"(r));
  return r;
}
static void setcsr(unsigned r) {
  __asm__ volatile(".set push\n.set hardfloat\nctc1 %0,$31\nnop\nnop\nnop\n.set pop" : : "r"(r) : "memory");
}
static uint64_t bits(double x) { uint64_t r; memcpy(&r,&x,8); return r; }
__attribute__((noinline)) static double software_divide(double x,double y) {
  volatile double a=x,b=y; return a/b;
}
#define CHECK(x) do { if (!(x)) { printf("FAIL line %d csr=%x\n",__LINE__,csr()); return 1; } } while(0)
int main(void) {
  unsigned saved=csr(); setcsr(0);
  CHECK(bits(software_divide(1,0)) == UINT64_C(0x7ff0000000000000));
  CHECK((csr() & 0x7c)==0); /* Preserved native soft-C negative. */
  CHECK(factor_mips_add(2,3)==5 && factor_mips_subtract(7,2)==5);
  CHECK(factor_mips_multiply(2,3)==6 && factor_mips_divide(12,3)==4);
  CHECK(factor_mips_equal(3,3) && !factor_mips_equal(3,4));
  CHECK(factor_mips_less(3,4) && factor_mips_lesseq(3,3));
  setcsr(0); CHECK(bits(factor_mips_divide(1,0))==UINT64_C(0x7ff0000000000000));
  CHECK(csr() & 0x20);
  double nan = factor_mips_divide(0,0);
  setcsr(0); CHECK(!factor_mips_less(nan,1)); CHECK(csr() & 0x40);
  setcsr(0); factor_mips_raise_invalid(); CHECK(csr() & 0x40);
  /* Exactly half an ulp above one: nearest rounds down, upward rounds up. */
  setcsr(0); CHECK(bits(factor_mips_add(1,0x1p-53))==UINT64_C(0x3ff0000000000000));
  CHECK(csr() & 4);
  setcsr(2); CHECK(bits(factor_mips_add(1,0x1p-53))==UINT64_C(0x3ff0000000000001));
  setcsr(3); CHECK(bits(factor_mips_add(1,0x1p-53))==UINT64_C(0x3ff0000000000000));
  setcsr(saved); puts("soft-ABI hardware arithmetic/status/rounding PASS"); return 0;
}
