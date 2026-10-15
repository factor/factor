#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "bootstrap-generated.h"
extern int backend_cfg_call(void*,int*);
extern void boot_true(void),boot_false(void),m88k_cache_sync(void*,size_t);
static void patch_pair(uint32_t* pair,uintptr_t value) {
 pair[0]=(pair[0]&0xffff0000)|(value>>16);
 pair[1]=(pair[1]&0xffff0000)|(value&0xffff);
}
static void* install(unsigned char* bytes,size_t size,int conditional) {
 void* code=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 assert(code!=MAP_FAILED);memcpy(code,bytes,size);
 if(conditional) {
  assert(size==48);patch_pair((uint32_t*)((char*)code+24),(uintptr_t)boot_true);
  patch_pair((uint32_t*)((char*)code+36),(uintptr_t)boot_false);
 }
 m88k_cache_sync(code,size);assert(mprotect(code,4096,PROT_READ|PROT_EXEC)==0);return code;
}
int main(void) {
 int s[2];void* add=install(boot_add,sizeof boot_add,0);
 void* mul=install(boot_mul,sizeof boot_mul,0);
 void* swap=install(boot_swap,sizeof boot_swap,0);
 void* conditional=install(boot_if,sizeof boot_if,1);
 s[0]=5*16;s[1]=-3*16;assert(backend_cfg_call(add,s+1)==2*16);
 s[0]=5*16;s[1]=-3*16;assert(backend_cfg_call(mul,s+1)==-15*16);
 s[0]=5*16;s[1]=-3*16;assert(backend_cfg_call(swap,s+1)==5*16);assert(s[0]==-3*16);
 s[0]=0;s[1]=1;assert(backend_cfg_call(conditional,s+1)==222);
 s[0]=0;s[1]=17;assert(backend_cfg_call(conditional,s+1)==111);
 puts("m88k bootstrap template gate PASS: tagged add multiply swap and both IF paths");return 0;
}
