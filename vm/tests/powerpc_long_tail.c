#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
int main(int argc,char **argv) {
 if(argc!=2)return 2;uint32_t code[12];FILE *f=fopen(argv[1],"rb");
 if(!f||fread(code,4,12,f)!=12)return 3;fclose(f);
 size_t far=64u<<20;char *m=mmap(0,128u<<20,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(m==MAP_FAILED||mprotect(m,4096,7)||mprotect(m+far,4096,7))return 4;
 uintptr_t target=(uintptr_t)(m+far);uint32_t *load=code+5;
#if __SIZEOF_POINTER__==8
 unsigned count=12;
 load[0]=(load[0]&0xffff0000)|(target>>48);
 load[1]=(load[1]&0xffff0000)|((target>>32)&65535);
 load[3]=(load[3]&0xffff0000)|((target>>16)&65535);
 load[4]=(load[4]&0xffff0000)|(target&65535);
#else
 unsigned count=9;
 load[0]=(load[0]&0xffff0000)|(target>>16);
 load[1]=(load[1]&0xffff0000)|(target&65535);
#endif
 for(unsigned i=0;i<count;i++)((uint32_t*)m)[i]=code[i];
 uint32_t *leaf=(uint32_t*)(m+far);leaf[0]=0x7cc33378;leaf[1]=0x4e800020;
 __builtin___clear_cache(m,m+4096);__builtin___clear_cache(m+far,m+far+4096);
#if __SIZEOF_POINTER__==8 && __BYTE_ORDER__==__ORDER_BIG_ENDIAN__
 uintptr_t descriptor[3]={(uintptr_t)m,0,0};
 __asm__ volatile("" : : "r"(descriptor) : "memory");
 uintptr_t (*call)(void)=(void*)descriptor;
#else
 uintptr_t (*call)(void)=(void*)m;
#endif
 uintptr_t answer=call(),expected=(uintptr_t)(m+4*count);
 printf("Actual emitted tail: distance=%zu r6=%#lx expected=%#lx\n",far,(unsigned long)answer,(unsigned long)expected);
 return answer==expected?0:5;
}
