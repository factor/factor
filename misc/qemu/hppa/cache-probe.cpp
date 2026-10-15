#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include "../../../vm/hppa-cache.hpp"
int main() {
  void* mapping=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANON,-1,0);
  if(mapping==MAP_FAILED) { perror("mmap"); return 1; }
  unsigned cases=0;
  for(unsigned offset=0;offset<64;offset+=4) {
    uint32_t* code=(uint32_t*)((char*)mapping+offset);
    code[1]=0xe840c000; code[2]=0x08000240;
    unsigned (*volatile fn)()=(unsigned (*)())code;
    for(unsigned value=0;value<1000;value++) {
      code[0]=0x341c0000|(value<<1);
      factor::hppa_flush_icache((uintptr_t)code,12);
      if(fn()!=value) return 2;
      cases++;
    }
  }
  factor::hppa_flush_icache((uintptr_t)mapping,0);
  printf("PA explicit FDC/SYNC/FIC: %u generated/replaced code cases passed\n",cases);
  return munmap(mapping,4096)!=0;
}
