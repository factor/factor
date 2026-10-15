#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <assert.h>
#include "../../../vm/hppa.hpp"
extern "C" uint32_t* hppa_bootstrap_execute(void*,uint32_t*,void*,void*);
extern "C" int32_t hppa_divide_i32(int32_t,int32_t);
extern "C" int32_t hppa_remainder_i32(int32_t,int32_t);
static unsigned cases;
extern "C" void trampoline();
extern "C" void trampoline2();
extern "C" unsigned hppa_mock_factor_entry(unsigned,unsigned,unsigned,unsigned);
extern "C" double hppa_mock_factor_float(double,double);
static uint32_t mock_vm[16],mock_old_context[16],mock_context[16],mock_ds[64],mock_rs[64];
alignas(16) static uint32_t mock_frames[512];
static uint32_t mock_hits,mock_safepoint;
static uintptr_t callback_target;

static void* code_for(const char* dir,const char* name) {
 char path[4096];snprintf(path,sizeof(path),"%s/%s.bin",dir,name);
 FILE* f=fopen(path,"rb");assert(f);fseek(f,0,SEEK_END);long bytes=ftell(f);rewind(f);
 assert(bytes>0&&bytes<4096);
 unsigned char* code=(unsigned char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(code!=MAP_FAILED);
 assert(fread(code,1,bytes,f)==(size_t)bytes);fclose(f);
 snprintf(path,sizeof(path),"%s/%s.rel",dir,name);f=fopen(path,"rb");assert(f);
 unsigned char record[4];unsigned symbols=0;
 while(fread(record,1,4,f)==4) {
  uint32_t r=(uint32_t(record[0])<<24)|(uint32_t(record[1])<<16)|(uint32_t(record[2])<<8)|record[3];
  unsigned type=r>>28,klass=(r>>24)&15,offset=r&0xffffff;
  assert(klass==14&&offset>=8&&offset<=(unsigned)bytes);
  uintptr_t value=0;
  if(type==0) {
   // The first symbol in these arithmetic templates is the cold error path.
   if(symbols++!=0) {
    bool remainder=strcmp(name,"fixnum-mod")==0 ||
       (strcmp(name,"fixnum-mod-fast")==0 && symbols==3);
    value=(uintptr_t)(remainder?&hppa_remainder_i32:&hppa_divide_i32);
   }
  } else if(strcmp(name,"callback")==0) {
   switch(type) {
    case 9:value=(uintptr_t)mock_vm;break;
    case 15:value=(uintptr_t)&mock_safepoint;break;
    case 12:value=factor::hppa_function_field((uintptr_t)&trampoline,0);break;
    case 13:value=factor::hppa_function_field((uintptr_t)&trampoline2,0);break;
    case 14:value=0;break;
    case 8:value=(uintptr_t)&mock_hits;break;
    case 1:value=callback_target;break;
    default:abort();
   }
  } else {fprintf(stderr,"unhandled relocation name=%s type=%u\n",name,type);abort();}
  factor::hppa_store_address((uint32_t*)(code+offset-8),uint32_t(value));
 }
 fclose(f);__builtin___clear_cache((char*)code,(char*)code+bytes);return code;
}
static void binary(const char* dir,const char* name,unsigned kind) {
 void* code=code_for(dir,name);const int32_t values[]={-1001,-17,-3,-1,0,1,3,17,1001};
 for(int32_t a:values)for(int32_t b:values) {
  if((kind==6||kind==7||kind==8)&&b==0)continue;
  uint32_t ds[32]={},context[16]={};alignas(16) uint32_t frames[512]={};
  ds[0]=uint32_t(a)<<4;ds[1]=uint32_t(b)<<4;
  uint32_t* top=hppa_bootstrap_execute(code,ds+1,context,frames+512);
  uint32_t expected=0;
  switch(kind) {
   case 0:expected=(uint32_t(a)+uint32_t(b))<<4;break;
   case 1:expected=(uint32_t(a)-uint32_t(b))<<4;break;
   case 2:expected=(uint32_t(a)*uint32_t(b))<<4;break;
   case 3:expected=(uint32_t(a)&uint32_t(b))<<4;break;
   case 4:expected=(uint32_t(a)|uint32_t(b))<<4;break;
   case 5:expected=(uint32_t(a)^uint32_t(b))<<4;break;
   case 6:expected=uint32_t(a/b)<<4;break;
   case 7:expected=uint32_t(a%b)<<4;break;
   case 8:expected=uint32_t(a%b)<<4;break;
  }
  if(top!=(kind==8?ds+1:ds)||*top!=expected||(kind==8&&ds[0]!=(uint32_t(a/b)<<4))) {
   fprintf(stderr,"bootstrap %s a=%d b=%d topdelta=%td actual=%08x expected=%08x\n",name,a,b,top-ds,*top,expected);abort();
  }
  cases++;
 }
 munmap(code,4096);
}
static void shifts(const char* dir) {
 void* code=code_for(dir,"fixnum-shift-fast");
 const int32_t values[]={-134217728,-1001,-1,0,1,1001,134217727};
 for(int32_t a:values)for(int32_t count=-31;count<=31;count++) {
  uint32_t ds[32]={uint32_t(a)<<4,uint32_t(count)<<4},context[16]={};
  alignas(16) uint32_t frames[512]={};
  uint32_t* top=hppa_bootstrap_execute(code,ds+1,context,frames+512);
  uint32_t expected=count>=0?((uint32_t(a)<<4)<<count):
     uint32_t(int32_t(uint32_t(a)<<4)>>(-count))&~uint32_t(15);
  assert(top==ds && *top==expected);cases++;
 }
 munmap(code,4096);
}
static void fpu(const char* dir) {
 void* get=code_for(dir,"fpu-state"),*set=code_for(dir,"set-fpu-state");
 ((void(*)(unsigned))set)(0);
 assert(((unsigned(*)())get)()==0);assert(((unsigned(*)())get)()==0);
 munmap(get,4096);munmap(set,4096);cases+=2;
}
static void callbacks(const char* dir) {
 mock_vm[0]=(uintptr_t)mock_old_context;mock_vm[1]=(uintptr_t)mock_context;
 mock_context[1]=(uintptr_t)(mock_frames+512);mock_context[2]=(uintptr_t)(mock_ds+3);
 mock_context[3]=(uintptr_t)(mock_rs+7);
 callback_target=factor::hppa_function_field((uintptr_t)&hppa_mock_factor_entry,0);
 void* code=code_for(dir,"callback");
 unsigned result=((unsigned(*)(unsigned,unsigned,unsigned,unsigned))code)(11,22,33,44);
 assert(result==42 && mock_ds[3]==11 && mock_vm[0]==(uintptr_t)mock_old_context);
 assert(((unsigned(*)(unsigned,...))code)(11,22,33,44)==42);
 munmap(code,4096);cases+=2;
 callback_target=factor::hppa_function_field((uintptr_t)&hppa_mock_factor_float,0);
 code=code_for(dir,"callback");
 assert(((double(*)(double,double))code)(2.5,10.5)==13.0);
 assert(mock_vm[0]==(uintptr_t)mock_old_context);
 munmap(code,4096);cases++;
}
int main(int argc,char** argv) {
 assert(argc==2);
 binary(argv[1],"fixnum+fast",0);binary(argv[1],"fixnum-fast",1);binary(argv[1],"fixnum*fast",2);
 binary(argv[1],"fixnum-bitand",3);binary(argv[1],"fixnum-bitor",4);binary(argv[1],"fixnum-bitxor",5);
 binary(argv[1],"fixnum*",2);
 binary(argv[1],"fixnum-i-fast",6);binary(argv[1],"fixnum-mod",7);binary(argv[1],"fixnum-mod-fast",8);
 shifts(argv[1]);fpu(argv[1]);callbacks(argv[1]);
 printf("HPPA actual bootstrap emitted arithmetic cases=%u passed\n",cases);
}
