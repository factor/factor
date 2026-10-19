#include <assert.h>
#include <stdio.h>
#include <stdint.h>
extern unsigned m88k_clz32(unsigned);
extern uint64_t m88k_clz64(uint64_t),m88k_clz64_undef(uint64_t);
int main(void) {
 unsigned i;
 assert(m88k_clz32(0)==32);
 assert(m88k_clz64(0)==64);
 for(i=0;i<64;++i) {
  uint64_t v=(uint64_t)1<<i;
  assert(m88k_clz64(v)==63-i);
  assert(m88k_clz64_undef(v)==63-i);
  assert(m88k_clz64(v|(v-1))==63-i);
  if(i<32)assert(m88k_clz32((unsigned)v)==31-i);
 }
 puts("m88k CLZ gate PASS: integer32 integer64 zero all64 bit positions");
 return 0;
}
