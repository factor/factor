#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-context-data.h"
extern void sparc_restore_window(void);
extern uintptr_t run_tail(void *);
extern void jit_tail_target(void);
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
int main(void){
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,ctxcode,sizeof ctxcode);
 patch(code+ctx_here,(uintptr_t)code+ctx_here+ctx_literal);
 patch(code+ctx_fn,(uintptr_t)sparc_restore_window);
 __builtin___clear_cache((char*)code,(char*)code+sizeof ctxcode);
 _Alignas(16) intptr_t frame[64]={0},ctx0[5]={0},ctx1[5]={0},alien[5]={0};
 intptr_t dest[4]={0},stack[2]={112,(intptr_t)alien+6};
 void*vm[2]={ctx0,ctx1};
 ctx1[0]=(intptr_t)frame;ctx1[1]=(intptr_t)(frame+64);ctx1[2]=(intptr_t)dest-sizeof(intptr_t);
 alien[4]=(intptr_t)ctx1;
 frame[15]=(intptr_t)code+ctx_here+ctx_literal;
 intptr_t*ds=run_context(stack,code,vm,frame);
 if(ds!=dest || dest[0]!=112 || vm[0]!=ctx1)return 2;
 unsigned char*tail=code+512;
 memcpy(tail,tailcode,sizeof tailcode);
 patch(tail+tail_fn,(uintptr_t)jit_tail_target);
 __builtin___clear_cache((char*)tail,(char*)tail+sizeof tailcode);
 if(run_tail(tail)!=(uintptr_t)tail+sizeof tailcode)return 3;
 puts("Factor-generated SPARC context continuation and tail call preserved their return windows");
}
