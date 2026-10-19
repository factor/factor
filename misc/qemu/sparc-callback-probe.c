#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <fenv.h>
#include <sys/mman.h>
#include "sparc-callback-data.h"
extern void sparc_restore_window(void);
extern intptr_t *run_context(intptr_t *,void *,void *,void *);
static uint32_t readword(unsigned char*p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void writeword(unsigned char*p,uint32_t n){p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char*p,uint32_t n){writeword(p,(readword(p)&~0x3fffff)|(n>>10));writeword(p+4,(readword(p+4)&~0x3ff)|(n&0x3ff));}
static void patch(unsigned char*end,uintptr_t n){if(sizeof(void*)==8){set32(end-24,(uint64_t)n>>32);set32(end-12,n);}else set32(end-8,n);}
extern void cb_integer_entry(void), cb_float_entry(void);
extern void trampoline(void),cb_quotation_entry(void);
extern uintptr_t factor_sparc_window_cookie;
int factor_child_called;
uintptr_t factor_child_quot;
extern intptr_t *run_quot_template(intptr_t *,void *,void *,uintptr_t);
static void *expected_vm;
static unsigned lazy_called,cache_called,cache_tail;
static unsigned begin_called,end_called;
static uintptr_t expected_quot;
static uintptr_t test_begin(void *vm,uintptr_t quot){
 (void)vm; if(quot==expected_quot)begin_called++;return quot;
}
static uintptr_t test_lazy(uintptr_t quot,void *vm){
 if(quot==expected_quot && vm==expected_vm)lazy_called++;return quot;
}
static uintptr_t test_cache(uintptr_t address,void *vm){
 if(vm==expected_vm && address && !(address&3) && (!cache_tail || address==0x11223344))cache_called++;
 return (uintptr_t)cb_quotation_entry;
}
static void test_end(void *vm){(void)vm;end_called++;}
int main(void){
 unsigned char*code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(code==MAP_FAILED)return 1;
 _Alignas(16) intptr_t callstack[512]={0}, ctx0[5]={0},ctx1[5]={0};
 intptr_t ds[4]={0};void*vm[2]={ctx0,ctx1};
 ctx1[1]=(intptr_t)(callstack+400);ctx1[2]=(intptr_t)ds-sizeof(intptr_t);ctx1[3]=ctx1[2];
 memcpy(code,cbcode,sizeof cbcode);
 patch(code+cb_vm,(uintptr_t)vm);patch(code+cb_fn,(uintptr_t)cb_integer_entry);
 __builtin___clear_cache((char*)code,(char*)code+sizeof cbcode);
 intptr_t(*integer)(intptr_t,intptr_t,intptr_t,intptr_t,intptr_t,intptr_t)=(void*)code;
 if(integer(1,2,3,4,5,6)!=21 || vm[0]!=ctx0)return 2;
 patch(code+cb_fn,(uintptr_t)cb_float_entry);
 __builtin___clear_cache((char*)code,(char*)code+sizeof cbcode);
 double(*floating)(double)=(void*)code;
 if(floating(3.25)!=6.5 || vm[0]!=ctx0)return 3;
 unsigned char*ctf=code+512;
 memcpy(ctf,ctfcode,sizeof ctfcode);
 unsigned native_index=0;
 for(unsigned i=0;i<sizeof ctfrel/sizeof ctfrel[0];i++){
  unsigned r=ctfrel[i],type=r>>28,off=(r&0xffffff)+ctf_prefix;
  uintptr_t target;
  if(type==12)target=(uintptr_t)trampoline;
  else if(type==0){
   if(native_index>=4)return 4;
   target=(native_index&1)?(uintptr_t)&factor_sparc_window_cookie:
          native_index?(uintptr_t)test_end:(uintptr_t)test_begin;
   native_index++;
  }
  else return 4;
  patch(ctf+off,target);
 }
 if(native_index!=4)return 4;
 _Alignas(16) uintptr_t quotation[5]={0};
 quotation[4]=(uintptr_t)cb_quotation_entry;expected_quot=(uintptr_t)quotation+4;
 patch(code+cb_fn,(uintptr_t)ctf);
 __builtin___clear_cache((char*)code,(char*)code+1024);
 ((void(*)(uintptr_t))(void*)code)(expected_quot);
 if(begin_called!=1 || end_called!=1 || factor_child_called!=1 || vm[0]!=ctx0)return 5;
 unsigned char*getter=code+2048,*setter=code+2304;
 memcpy(getter,fpuget,sizeof fpuget);memcpy(setter,fpuset,sizeof fpuset);
 __builtin___clear_cache((char*)getter,(char*)setter+sizeof fpuset);
 if(fesetround(FE_DOWNWARD))return 6;
 uintptr_t fsr=((uintptr_t(*)(void))(void*)getter)();
 if(fegetround()!=FE_TONEAREST)return 7;
 ((void(*)(uintptr_t))(void*)setter)(fsr);
 if(fegetround()!=FE_DOWNWARD)return 8;
 if(fesetround(FE_TONEAREST))return 9;
 expected_vm=vm;
 for(unsigned i=0;i<4;i++){
  const struct comb_probe *probe=&combs[i];unsigned char*comb=code+2560+256*i;
  if(probe->length>256)return 10;
  memcpy(comb,probe->code,probe->length);
  unsigned native_count=0;
  for(unsigned j=0;j<probe->count;j++){
   unsigned r=probe->rel[j],type=r>>28,off=(r&0xffffff)+ctf_prefix;
   uintptr_t target;
   if(type==12)target=(uintptr_t)trampoline;
   else if(type==0){
    if(native_count>=2)return 11;
    target=native_count++?(uintptr_t)&factor_sparc_window_cookie:
           i==1?(uintptr_t)test_lazy:(uintptr_t)test_cache;
   }
   else return 11;
   patch(comb+off,target);
  }
  if(native_count!=(i?2:0))return 11;
  __builtin___clear_cache((char*)comb,(char*)comb+probe->length);
  intptr_t stack[2]={0,expected_quot};factor_child_quot=0;cache_tail=i==3;
  intptr_t *result=run_quot_template(stack,comb,vm,expected_quot);
  if(factor_child_quot!=expected_quot || result!=(i?stack+1:stack))return 12+i;
 }
 if(lazy_called!=1 || cache_called!=2)return 16;
 puts("Factor-generated SPARC callback and native entry preserved integer/FP arguments, results, FSR, and tail combinator targets");
}
