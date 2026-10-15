#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-delete-data.h"
extern void sparc_restore_window(void);
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern void trampoline(void);
static unsigned deleted;
static void *test_new_context(void *vm){(void)vm;deleted++;return 0;}
int main(void){
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,deletecode,sizeof deletecode);
 unsigned native=0,here=0;
 for(unsigned i=0;i<sizeof deleterel/sizeof deleterel[0];i++){
  unsigned r=deleterel[i],type=r>>28,off=(r&0xffffff)+delete_prefix;
  uintptr_t value;
  if(type==0)value=native++?(uintptr_t)sparc_restore_window:(uintptr_t)test_new_context;
  else if(type==12)value=(uintptr_t)trampoline;
  else if(type==4)value=(uintptr_t)code+off+delete_literals[here++];
  else return 2;
  patch(code+off,value);
 }
 __builtin___clear_cache((char*)code,(char*)code+sizeof deletecode);
 _Alignas(16) intptr_t frame[64]={0},ctx0[5]={0},ctx1[5]={0},alien[5]={0};
 intptr_t dest[4]={0},stack[2]={112,(intptr_t)alien+6};
 void*vm[2]={ctx0,ctx1};
 ctx1[0]=(intptr_t)frame;ctx1[1]=(intptr_t)(frame+64);ctx1[2]=(intptr_t)dest-sizeof(intptr_t);
 alien[4]=(intptr_t)ctx1;
 unsigned here_record=0;
 for(unsigned i=0;i<sizeof deleterel/sizeof deleterel[0];i++)if(deleterel[i]>>28==4)here_record=deleterel[i]&0xffffff;
 frame[15]=(intptr_t)code+delete_prefix+here_record+delete_literals[0];
 intptr_t*ds=run_context(stack,code,vm,frame);
 if(ds!=dest || dest[0]!=112 || vm[0]!=ctx1 || deleted!=1)return 3;
 puts("Factor-generated SPARC context deletion transferred its parameter to a surviving context");
}
