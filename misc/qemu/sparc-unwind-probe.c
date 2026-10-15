#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-unwind-data.h"
extern void sparc_restore_window(void);
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern void trampoline(void),unwind_child_entry(void);
static void *current_vm;
int main(void){
 _Alignas(16) intptr_t ctx0[8]={0},quot[5]={0};
 intptr_t stack[2]={0,0};
 void*vm[16]={ctx0,ctx0};current_vm=vm;quot[4]=(intptr_t)unwind_child_entry;stack[0]=(intptr_t)quot+4;ctx0[2]=(intptr_t)stack;
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,unwindcode,sizeof unwindcode);
 unsigned here=0;
 for(unsigned i=0;i<sizeof unwindrel/sizeof unwindrel[0];i++){
  unsigned r=unwindrel[i],type=r>>28,off=(r&0xffffff)+unwind_prefix;
  uintptr_t value;
  if(type==0)value=(uintptr_t)sparc_restore_window;
  else if(type==9)value=(uintptr_t)current_vm;
  else if(type==4)value=(uintptr_t)code+off+unwind_literals[here++];
  else return 2;
  patch(code+off,value);
 }
 __builtin___clear_cache((char*)code,(char*)code+sizeof unwindcode);
 intptr_t*ds=run_context(stack,code,vm,0);
 if(ds!=stack || stack[0]!=336 || vm[0]!=ctx0)return 3;
 puts("Factor-generated SPARC unwind discarded its saved frame and returned through the error quotation");
}
