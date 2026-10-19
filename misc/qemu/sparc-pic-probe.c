#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-pic-data.h"
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern uintptr_t run_pic(uintptr_t,void *,unsigned,unsigned *);
extern void pic_hit(void);
int main(void){
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,piccode,sizeof piccode);
 patch(code+pic_offset,(uintptr_t)pic_hit);
 __builtin___clear_cache((char*)code,(char*)code+sizeof piccode);
 unsigned saved=0,cases=0; for(unsigned n=0;n<1024;n++)for(unsigned flags=0;flags<2;flags++){ uintptr_t input=(n&1)?0x12347:112; uintptr_t expected=(n&1)?0:1; if(run_pic(input,code,flags,&saved)!=expected)return 2; if(saved!=123){printf("parent_l7=%u expected=123 pointer_bits=%zu\n",saved,sizeof(void*)*8);return 3;} cases++; } printf("parent-window preserved, correct PIC result and adversarial flags: %u cases pointer_bits=%zu\n",cases,sizeof(void*)*8);
 puts("Factor-generated SPARC first-fixnum PIC hit ignored adversarial incoming condition flags");
}
