#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-callstack-data.h"
extern void sparc_restore_window(void), restore_encoded_test_windows(void);
#ifdef SPARC_EXTERNAL_COOKIE
extern uintptr_t factor_sparc_window_cookie;
#define COOKIE_CASES 1
#else
uintptr_t factor_sparc_window_cookie;
#define COOKIE_CASES 2
#endif
unsigned cookie_frame_count;
#ifdef SPARC_EXPECT_PREPARE
extern void factor_sparc_prepare_callstack(void*), __real_factor_sparc_prepare_callstack(void*);
static void *expected_vm;
static intptr_t *expected_ds;
static unsigned prepare_calls;
void __wrap_factor_sparc_prepare_callstack(void *vm) {
 if(vm!=expected_vm || ((intptr_t**)vm)[0][2]!=(intptr_t)expected_ds) {
  fprintf(stderr,"set-callstack preparation lost VM or rooted data stack\n");
  __builtin_trap();
 }
 prepare_calls++;
 __real_factor_sparc_prepare_callstack(vm);
}
#endif
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern void trampoline(void),return_from_callstack(void),callstack_middle_return(void);

int main(void){
 for(unsigned cookie_case=0;cookie_case<COOKIE_CASES;cookie_case++){
 factor_sparc_window_cookie=cookie_case?(uintptr_t)(sizeof(void*)==8?UINT64_C(0x8d36fedc11223341):UINT32_C(0x93451231)):0;
 cookie_frame_count=0;
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 memcpy(code,callstackcode,sizeof callstackcode);
 unsigned native=0,here=0,native_count=0;
 for(unsigned i=0;i<sizeof callstackrel/sizeof callstackrel[0];i++)
  if(callstackrel[i]>>28==0)native_count++;
#ifdef SPARC_EXPECT_PREPARE
 if(native_count!=4)return 6;
#else
 if(native_count!=3)return 6;
#endif
 for(unsigned i=0;i<sizeof callstackrel/sizeof callstackrel[0];i++){
  unsigned r=callstackrel[i],type=r>>28,off=(r&0xffffff)+callstack_prefix;
  uintptr_t value;
  if(type==0){
   unsigned ordinal=native++;
#ifdef SPARC_EXPECT_PREPARE
   if(ordinal==0){value=(uintptr_t)factor_sparc_prepare_callstack;patch(code+off,value);continue;}
   ordinal--;
#endif
   switch(ordinal){
    case 0:value=(uintptr_t)memcpy;break;
    case 1:value=(uintptr_t)&factor_sparc_window_cookie;break;
    case 2:value=cookie_case?(uintptr_t)restore_encoded_test_windows:(uintptr_t)sparc_restore_window;break;
    default:return 2;
   }
  }
  else if(type==12)value=(uintptr_t)trampoline;
  else if(type==4)value=(uintptr_t)code+off+callstack_literals[here++];
  else return 2;
  patch(code+off,value);
 }
 __builtin___clear_cache((char*)code,(char*)code+sizeof callstackcode);
 enum { FRAME=sizeof(void*)==8?176:96,BIAS=sizeof(void*)==8?2047:0 };
 _Alignas(16) intptr_t ctx0[8]={0},object[2+2*FRAME/sizeof(intptr_t)]={0};
 intptr_t stack[2]={(intptr_t)object+10,0};
 void*vm[2]={ctx0,ctx0};object[1]=(2*FRAME)<<4;
 object[2+14]=FRAME;object[2+15]=(intptr_t)callstack_middle_return-8;
 object[2+FRAME/sizeof(intptr_t)+14]=FRAME;
 object[2+FRAME/sizeof(intptr_t)+15]=(intptr_t)return_from_callstack-8;
 #ifdef SPARC_EXPECT_PREPARE
 expected_vm=vm;expected_ds=stack;prepare_calls=0;
#endif
 intptr_t*ds=run_context(stack,code,vm,0);
#ifdef SPARC_EXPECT_PREPARE
 if(prepare_calls!=1)return 7;
#endif
 if(ds!=(intptr_t*)((char*)stack-sizeof(intptr_t)) || vm[0]!=ctx0)return 3;
 if(cookie_case && cookie_frame_count!=2)return 4;
 if(munmap(code,4096)!=0)return 5;
 printf("Factor-generated SPARC set-callstack relocated two frames; cookie case %u returned\n",cookie_case);
 }

}
