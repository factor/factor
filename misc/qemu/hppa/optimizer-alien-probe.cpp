#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <sys/mman.h>
#include "hppa.hpp"
extern "C" {
alignas(16) uintptr_t hppa_optimizer_vm[8];
alignas(16) uintptr_t hppa_optimizer_context[8];
alignas(16) uint32_t hppa_optimizer_frames[128];
uint32_t hppa_optimizer_enter(void*,uintptr_t,uint32_t,uint32_t);
}
alignas(16) static uint32_t nursery[256];
static uint32_t be(const unsigned char* p) {
  return uint32_t(p[0])<<24 | uint32_t(p[1])<<16 | uint32_t(p[2])<<8 | p[3];
}
static void* load(const char* path) {
  FILE* f=fopen(path,"rb"); assert(f);
  char* code=(char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code!=MAP_FAILED);
  size_t n=fread(code,1,4096,f); assert(n && n<4096); fclose(f);
  f=fopen((std::string(path)+".labels").c_str(),"rb"); assert(f);
  unsigned char pair[8];
  while(fread(pair,1,8,f)==8) {
    uint32_t offset=be(pair), target=be(pair+4); assert(offset+8<=n && target<n);
    factor::hppa_store_address((uint32_t*)(code+offset),(uintptr_t)(code+target));
  }
  fclose(f); __builtin___clear_cache(code,code+n); return code;
}
static void reset() {
  hppa_optimizer_vm[2]=(uintptr_t)nursery;
  hppa_optimizer_vm[4]=(uintptr_t)(nursery+256);
}
static void check(uint32_t result,uint32_t base,uint32_t disp,uint32_t address) {
  assert(result==(uintptr_t)nursery+6);
  assert(nursery[0]==24 && nursery[1]==base && nursery[2]==1);
  assert(nursery[3]==disp && nursery[4]==address);
  assert(hppa_optimizer_vm[2]==(uintptr_t)nursery+32);
}
int main(int argc,char** argv) {
  assert(argc==4); void* box=load(argv[1]); void* displaced=load(argv[2]); void* unbox=load(argv[3]);
  reset(); assert(hppa_optimizer_enter(box,0,0,0)==1);
  assert(hppa_optimizer_vm[2]==(uintptr_t)nursery);
  for(uint32_t pointer : {1u,42u,0x12345678u,0xffffffffu}) {
    reset(); check(hppa_optimizer_enter(box,pointer,0,0),1,pointer,pointer);
  }
  alignas(16) uint32_t bytes[16]={36,64};
  alignas(16) uint32_t alien[8]={24,(uintptr_t)bytes+9,1,10,(uintptr_t)bytes+26};
  uint32_t bases[]={1,(uintptr_t)bytes+9,(uintptr_t)alien+6};
  for(uint32_t base:bases) {
    reset(); assert(hppa_optimizer_enter(displaced,base,0,0)==base);
    assert(hppa_optimizer_vm[2]==(uintptr_t)nursery);
  }
  reset(); check(hppa_optimizer_enter(displaced,1,5,0),1,5,5);
  reset(); check(hppa_optimizer_enter(displaced,(uintptr_t)bytes+9,5,0),(uintptr_t)bytes+9,5,(uintptr_t)bytes+21);
  reset(); check(hppa_optimizer_enter(displaced,(uintptr_t)alien+6,uint32_t(-3),0),(uintptr_t)bytes+9,7,(uintptr_t)bytes+23);
  assert(hppa_optimizer_enter(unbox,1,0,0)==0);
  assert(hppa_optimizer_enter(unbox,(uintptr_t)bytes+9,0,0)==(uintptr_t)bytes+16);
  assert(hppa_optimizer_enter(unbox,(uintptr_t)alien+6,0,0)==(uintptr_t)bytes+26);
  for(void* p:{box,displaced,unbox}) assert(munmap(p,4096)==0);
  puts("Factor-emitted allocation/alien/label relocation: 14 native cases passed");
}
