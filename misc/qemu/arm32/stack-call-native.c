#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#ifdef __OpenBSD__
#include <machine/sysarch.h>
#endif
static void flush_code(unsigned char *p,size_t n){
#ifdef __OpenBSD__
 struct arm_sync_icache_args args={(unsigned int)(uintptr_t)p,n};
 assert(sysarch(ARM_SYNC_ICACHE,&args)==0);
#else
 __builtin___clear_cache((char*)p,(char*)p+n);
#endif
}
extern void tramp2(void);
int sixarg(int a,int b,int c,int d,int e,int f){return a+b+c+d+e+f;}
static void *load(const char *bin,const char *rel){
 FILE*f=fopen(bin,"rb"); assert(f); unsigned char*p=mmap(0,4096,7,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(p!=MAP_FAILED);size_t n=fread(p,1,4096,f);fclose(f);
 f=fopen(rel,"rb");assert(f); uint32_t x;while(fread(&x,4,1,f)==1){ unsigned type=x>>28,off=x&0xffffff; assert(((x>>24)&15)==0);*(uint32_t*)(p+off-4)=type==0?(uintptr_t)sixarg:(assert(type==13),(uintptr_t)tramp2); }fclose(f);flush_code(p,n);return p;
}
int main(){int(*direct)(int,int,int,int)=load("/tmp/arm32-backend-direct.bin","/tmp/arm32-backend-direct.rel");int(*indirect)(void*)=load("/tmp/arm32-backend-indirect.bin","/tmp/arm32-backend-indirect.rel");assert(direct(1,2,3,4)==21);assert(direct(-1,-2,-3,-4)==1);assert(indirect(sixarg)==21);puts("ARM32 generated six-argument direct/indirect calls passed");}
