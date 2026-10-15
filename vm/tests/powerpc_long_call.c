#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
static uint32_t generated[7];
int main(int argc,char **argv) {
 if(argc!=2)return 2; FILE *f=fopen(argv[1],"rb"); if(!f)return 3;
 if(fread(generated,4,sizeof(generated)/4,f)!=sizeof(generated)/4)return 4; fclose(f);
 size_t reserve=128u<<20, far=64u<<20;
 char *m=mmap(0,reserve,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); if(m==MAP_FAILED)return 5;
 if(mprotect(m,4096,PROT_READ|PROT_WRITE|PROT_EXEC)||mprotect(m+far,4096,PROT_READ|PROT_WRITE|PROT_EXEC))return 6;
 uint32_t *p=(uint32_t*)m; unsigned n=0;
 p[n++]=0x7c0802a6;
#if __SIZEOF_POINTER__==8
 p[n++]=0xf8010010;
#if __BYTE_ORDER__==__ORDER_BIG_ENDIAN__
 p[n++]=0xf821ff71;
#else
 p[n++]=0xf821ff81;
#endif
 unsigned count=7; uint64_t target=(uintptr_t)(m+far);
 generated[0]=(generated[0]&0xffff0000)|(target>>48);
 generated[1]=(generated[1]&0xffff0000)|((target>>32)&65535);
 generated[3]=(generated[3]&0xffff0000)|((target>>16)&65535);
 generated[4]=(generated[4]&0xffff0000)|(target&65535);
#else
 p[n++]=0x90010004;p[n++]=0x9421ffb0;
 unsigned count=4; uint32_t target=(uintptr_t)(m+far);
 generated[0]=(generated[0]&0xffff0000)|(target>>16);
 generated[1]=(generated[1]&0xffff0000)|(target&65535);
#endif
 for(unsigned i=0;i<count;i++)p[n++]=generated[i];
#if __SIZEOF_POINTER__==8
 p[n++]=0xe8210000;p[n++]=0xe8010010;
#else
 p[n++]=0x80210000;p[n++]=0x80010004;
#endif
 p[n++]=0x7c0803a6;p[n++]=0x4e800020;
 uint32_t *callee=(uint32_t*)(m+far);callee[0]=0x38600049;callee[1]=0x4e800020;
 __builtin___clear_cache(m,m+4096);__builtin___clear_cache(m+far,m+far+4096);
#if __SIZEOF_POINTER__==8 && __BYTE_ORDER__==__ORDER_BIG_ENDIAN__
 uintptr_t descriptor[3]={(uintptr_t)m,0,0};
 __asm__ volatile("" : : "r"(descriptor) : "memory");
 int (*call)(void)=(void*)descriptor;
#else
 int (*call)(void)=(void*)m;
#endif
 int answer=call();printf("Actual emitted full-range PowerPC call: distance=%zu result=%d\n",far,answer);
 return answer==73?0:7;
}
