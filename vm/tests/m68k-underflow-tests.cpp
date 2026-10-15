#include "../m68k-float.hpp"
#include <cstdio>
#if defined(__linux__)
extern "C" unsigned short _fpCCR[];
#endif
static double from_bits(uint64_t bits) { double value; memcpy(&value,&bits,8);return value; }
__attribute__((noinline,noipa)) static uint64_t operation(uint64_t a,uint64_t b,bool divide) {
  double x=from_bits(a),y=from_bits(b);
  double result=factor::m68k_float::correct_underflow(divide ? x/y : x*y,x,y,divide);
  uint64_t bits; memcpy(&bits,&result,8);return bits;
}
int main() {
  uint32_t control=0x80,zero=0,status;
  asm volatile("fmove.l %0,%%fpcr;fmove.l %1,%%fpsr"::"d"(control),"d"(zero):"memory");
#if defined(__linux__)
  // Foreign software floating-point state must not influence Factor.
  _fpCCR[1]=0xffff;
  _fpCCR[3]=3;
#endif
  const uint64_t cases[][4]={
    {0x0016cb6ca2bf1d8aULL,0x3fd3c8248bacd929ULL,0x00070bacf7f9cd8bULL,0},
    {0x8016cb6ca2bf1d8aULL,0x3fd3c8248bacd929ULL,0x80070bacf7f9cd8bULL,0},
    {1,0x3fe0000000000000ULL,0,0},
    {3,0x3fe0000000000000ULL,2,0},
    {1,0x4000000000000000ULL,0,1},
    {3,0x4000000000000000ULL,2,1},
    {0x0010000000000000ULL,0x4000000000000000ULL,0x0008000000000000ULL,1},
    {0x3ff0000000000000ULL,0x7ff0000000000000ULL,0,1},
    {0xbff0000000000000ULL,0x7ff0000000000000ULL,0x8000000000000000ULL,1},
    {0x3ff0000000000000ULL,0x4000000000000000ULL,0x4000000000000000ULL,0}
  };
  for(unsigned i=0;i<sizeof(cases)/sizeof(cases[0]);++i) {
    uint64_t actual=operation(cases[i][0],cases[i][1],cases[i][3]);
    if(actual!=cases[i][2]) {printf("case%u: %016llx != %016llx\n",i,(unsigned long long)actual,(unsigned long long)cases[i][2]);return 1;}
  }
  asm volatile("fmove.l %%fpsr,%0":"=d"(status)::"memory");
  if((status&0x28)!=0x28) {printf("lost exception flags %08x\n",status);return 1;}
  control=0xb0; // Round upward, retaining hardware directed rounding.
  asm volatile("fmove.l %0,%%fpcr"::"d"(control):"memory");
  if(operation(1,0x3fe0000000000000ULL,false)!=1) return 1;
  puts("m68k stateless underflow: ties, signs, infinities, flags, directed mode PASS");
  return 0;
}
