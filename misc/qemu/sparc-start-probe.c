#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-start-data.h"
extern void sparc_restore_window(void);
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern void trampoline(void),start_child_entry(void);
static intptr_t *created_ctx;
static void *test_new_context(void *vm){(void)vm;return created_ctx;}
int main(void){
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,startcode,sizeof startcode);
 unsigned native=0,here=0;
 for(unsigned i=0;i<sizeof startrel/sizeof startrel[0];i++){
  unsigned r=startrel[i],type=r>>28,off=(r&0xffffff)+start_prefix;
  uintptr_t value;
  if(type==0)value=native++?(uintptr_t)sparc_restore_window:(uintptr_t)test_new_context;
  else if(type==12)value=(uintptr_t)trampoline;
  else if(type==4)value=(uintptr_t)code+off+start_literals[here++];
  else return 2;
  patch(code+off,value);
 }
 __builtin___clear_cache((char*)code,(char*)code+sizeof startcode);
 _Alignas(16) intptr_t frame[64]={0},ctx0[5]={0},ctx1[5]={0},quot[5]={0};
 intptr_t dest[4]={0},stack[2]={112,(intptr_t)quot+4};
 void*vm[2]={ctx0,ctx0};created_ctx=ctx1;quot[4]=(intptr_t)start_child_entry;
 ctx1[0]=(intptr_t)frame;ctx1[1]=(intptr_t)frame;ctx1[2]=(intptr_t)dest-sizeof(intptr_t);
 intptr_t*ds=run_context(stack,code,vm,frame);
 if(ds!=stack || stack[0]!=336 || dest[0]!=112 || vm[0]!=ctx0)return 3;
 puts("Factor-generated SPARC start-context ran a new quotation and resumed its parent");
}
