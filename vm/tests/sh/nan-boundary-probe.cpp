#include <cstdint>
#include <cstdio>
#include <cstring>
#include <initializer_list>
#include "../../float_bits.hpp"
using namespace factor;
static uint32_t fpscr() { uint32_t n; asm volatile("sts fpscr,%0":"=r"(n)); return n; }
static void fpscr(uint32_t n) { asm volatile("lds %0,fpscr"::"r"(n):"memory"); }
static double add(double x, double y) { asm volatile("fadd %1,%0":"+f"(x):"f"(y)); return x; }
static float add(float x, float y) { asm volatile("fadd %1,%0":"+f"(x):"f"(y)); return x; }
template<class T> static T native(T n);
template<class T> static T canonical(T n);
template<> uint64_t native(uint64_t n) {
#ifdef SH_LEGACY_NAN_BOUNDARY
  return n;
#else
  return inverse_native_double_bits(n);
#endif
}
template<> uint64_t canonical(uint64_t n) {
#ifdef SH_LEGACY_NAN_BOUNDARY
  return n;
#else
  return inverse_canonical_double_bits(n);
#endif
}
template<> uint32_t native(uint32_t n) {
#ifdef SH_LEGACY_NAN_BOUNDARY
  return n;
#else
  return inverse_native_float_bits(n);
#endif
}
template<> uint32_t canonical(uint32_t n) {
#ifdef SH_LEGACY_NAN_BOUNDARY
  return n;
#else
  return inverse_canonical_float_bits(n);
#endif
}
int main() {
 uint32_t original=fpscr(); unsigned checks=0,failed=0;
 for(unsigned sign=0;sign<2;sign++) for(unsigned quiet=0;quiet<2;quiet++)
 for(unsigned payload=0;payload<3;payload++) for(unsigned mode=0;mode<2;mode++) {
  if(!quiet&&!payload)continue;
  uint64_t b=(uint64_t(sign)<<63)|UINT64_C(0x7ff0000000000000)|(quiet?UINT64_C(0x8000000000000):0)|payload;
  fpscr(0x80000|mode);double r=add(bits_double(native(b)),0.0);uint32_t flags=fpscr()&0x7c;
  uint64_t out=canonical(double_bits(r));bool ok=flags==(quiet?0u:0x40u)&&(out&UINT64_C(0x7ff8000000000000))==UINT64_C(0x7ff8000000000000);
  checks++;failed+=!ok;
  uint32_t f=(sign<<31)|0x7f800000u|(quiet?0x400000u:0u)|payload;
  fpscr(mode);float q=add(bits_float(native(f)),0.0f);flags=fpscr()&0x7c;uint32_t z=canonical(float_bits(q));ok=flags==(quiet?0u:0x40u)&&(z&0x7fc00000u)==0x7fc00000u;
  checks++;failed+=!ok;
 }
 for(uint64_t b:{UINT64_C(0),UINT64_C(0x8000000000000000),UINT64_C(0x3ff0000000000000),UINT64_C(0x7ff0000000000000),UINT64_C(0xfff0000000000000)}){checks++;failed+=native(b)!=b||canonical(b)!=b;}
 fpscr(original);std::printf("checks=%u failed=%u restored=%d\n",checks,failed,fpscr()==original);return failed?1:0;
}
