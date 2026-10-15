#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
int main(void) {
  const unsigned char code[] = {
    0,0, 0xd0,0xac,4,0x52, 0xd0,0xac,8,0x53,
    0xc3,0x53,0x20,0x54, 0xef,0x53,0x54,0x52,0x53,
    0xd0,0x53,0x50, 0x04
  };
  void *p = mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,
                 MAP_PRIVATE|MAP_ANON,-1,0);
  assert(p != MAP_FAILED);
  memcpy(p,code,sizeof(code));
  __builtin___clear_cache(p,(char *)p+sizeof(code));
  uint32_t (*shr)(uint32_t,uint32_t) = p;
  const uint32_t values[] = {0,1,0x80000000U,0xffffffffU,0x12345678U};
  for (unsigned i=0;i<sizeof(values)/sizeof(values[0]);i++)
    for (unsigned n=0;n<32;n++) assert(shr(values[i],n)==(values[i]>>n));
  assert(munmap(p,4096)==0);
  puts("VAX generated logical shift: 160 native executions passed");
  return 0;
}
