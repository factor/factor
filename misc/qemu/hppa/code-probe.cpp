#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <assert.h>
#include "../../../vm/hppa.hpp"
using namespace factor;
static unsigned native(unsigned v) { return v+1; }
int main() {
  static const uint32_t gnu_pair[]={0x22c26246u,0x36d60cf0u};
  assert(hppa_load_address(gnu_pair)==0x12345678u);
  uint32_t pair[]={0x22c00000u,0x36d60000u};
  hppa_store_address(pair,0x12345678u);
  assert(pair[0]==gnu_pair[0] && pair[1]==gnu_pair[1]);
  for(uint32_t v=0;v!=0x200000u;++v) assert(hppa_decode_21(hppa_encode_21(v))==v);
  for(int v=-8192;v<8192;++v) assert(hppa_decode_14(hppa_encode_14(v))==v);
  uint32_t* code=(uint32_t*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code!=MAP_FAILED);
  // LDIL/LDO -> r28 (integer return), BV r0(r2), NOP.
  code[0]=0x23800000u; code[1]=0x379c0000u; code[2]=0xe840c000u; code[3]=0x08000240u;
  volatile uintptr_t descriptor[2]={(uintptr_t)code,hppa_function_field((uintptr_t)&native,1)};
  auto raw=(unsigned(*)())code;
  auto tagged=(unsigned(*)())((uintptr_t)descriptor|2);
  uintptr_t fn=(uintptr_t)&native;
  assert(hppa_function_field(fn,0) && ((fn & 3) == 0 || (fn & 3) == 2));
  unsigned values[]={0,1,42,0x12345678u,0x7fffffffu,0x80000000u,0xffffffffu};
  for(unsigned v:values) {
    hppa_store_address(code,v);
    assert(hppa_load_address(code)==v);
    __builtin___clear_cache((char*)code,(char*)(code+4));
    assert(raw()==v && tagged()==v);
  }
  assert(((unsigned(*)(unsigned))fn)(41)==42);
  // HPPA32 native double arguments use fr5/fr7 and return in fr4.
  auto floating=(double(*)(double,double))code;
  code[1]=0xe840c000u; code[2]=0x08000240u;
  unsigned fpops[]={0x30a70e04u,0x30a72e04u,0x30a74e04u,0x30a76e04u};
  double expected[]={3.75,1.25,3.125,2.0};
  for(unsigned i=0;i<4;i++) {
    code[0]=fpops[i];
    __builtin___clear_cache((char*)code,(char*)(code+3));
    assert(floating(2.5,1.25)==expected[i]);
  }
  printf("gnu-encoding=pass immediate21=2097152 immediate14=16384 generated-code=pass raw-call=pass plabel-call=pass patch-flush=pass generated-double=pass native-code=%lx native-dp=%lx\n",(unsigned long)hppa_function_field(fn,0),(unsigned long)hppa_function_field(fn,1));
  return munmap(code,4096)!=0;
}
