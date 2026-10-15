#include <stdint.h>
#include <stdio.h>
static double convert(int32_t value) {
  uint32_t buffer[2] __attribute__((aligned(8)));
  const double bias=4503601774854144.0;
  double result;
  __asm__ volatile("xoris 0,%1,0x8000\n\tstw 0,4(%2)\n\tlis 0,0x4330\n\tstw 0,0(%2)\n\tlfd 0,0(%2)\n\tlfd 1,0(%3)\n\tfsub %0,0,1"
    : "=f"(result) : "r"(value), "b"(buffer), "b"(&bias) : "r0","fr0","fr1","memory");
  return result;
}
static int32_t truncate(double value) {
  uint32_t buffer[2] __attribute__((aligned(8)));
  __asm__ volatile("fctiwz 0,%0\n\tstfd 0,0(%1)" : : "f"(value), "b"(buffer) : "fr0","memory");
  return buffer[1];
}
static int32_t minimum(int32_t a, int32_t b) {
  int32_t result;
  __asm__ volatile("cmpw %1,%2\n\tble 1f\n\tmr %0,%2\n\tb 2f\n1:\tmr %0,%1\n2:" : "=r"(result) : "r"(a),"r"(b) : "cr0");
  return result;
}
static int32_t maximum(int32_t a, int32_t b) {
  int32_t result;
  __asm__ volatile("cmpw %1,%2\n\tbge 1f\n\tmr %0,%2\n\tb 2f\n1:\tmr %0,%1\n2:" : "=r"(result) : "r"(a),"r"(b) : "cr0");
  return result;
}
int main(void) {
  const int32_t values[]={INT32_MIN,-100,-1,0,1,100,INT32_MAX};
  for(unsigned i=0;i<7;++i) {
    if(convert(values[i]) != (double)values[i]) return 1;
    if(truncate((double)values[i]) != values[i]) return 2;
    for(unsigned j=0;j<7;++j) {
      if(minimum(values[i],values[j]) != (values[i]<values[j]?values[i]:values[j])) return 3;
      if(maximum(values[i],values[j]) != (values[i]>values[j]?values[i]:values[j])) return 4;
    }
  }
  if(truncate(3.75)!=3 || truncate(-3.75)!=-3) return 5;
  puts("PASS classic PPC32 integer selection and float conversion boundaries");
  return 0;
}
