#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <fenv.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include "hppa.hpp"
#include "float_bits.hpp"
static uint32_t be(const unsigned char* p) { return uint32_t(p[0])<<24|uint32_t(p[1])<<16|uint32_t(p[2])<<8|p[3]; }
static void* load(const std::string& path) {
  FILE* f=fopen(path.c_str(),"rb"); assert(f);
  char* code=(char*)mmap(0,4096,7,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(code!=MAP_FAILED);
  size_t n=fread(code,1,4096,f); assert(n&&n<4096); fclose(f);
  f=fopen((path+".labels").c_str(),"rb"); assert(f); unsigned char pair[8];
  while(fread(pair,1,8,f)==8) {uint32_t offset=be(pair),target=be(pair+4);assert(offset+8<=n&&target<n);factor::hppa_store_address((uint32_t*)(code+offset),(uintptr_t)(code+target));}
  fclose(f); __builtin___clear_cache(code,code+n); return code;
}
int main(int argc,char** argv) {
 assert(argc==2); std::string dir=argv[1];
 using binary=unsigned(*)(const uint64_t*,const uint64_t*,uint64_t*);
 binary ops[6]; const char* names[]={"add","sub","mul","div","quiet","ordered"};
 for(unsigned i=0;i<6;i++)ops[i]=(binary)load(dir+"/"+names[i]+".bin");
 unsigned count=0; const uint64_t payloads[]={1,0x4000000000000ULL,0x8000000000000ULL,0x8123456789abcULL,0xfffffffffffffULL};
 for(int mode:{FE_TONEAREST,FE_TOWARDZERO,FE_UPWARD,FE_DOWNWARD}) {
 fesetround(mode);
 for(unsigned sign=0;sign<2;++sign)for(uint64_t p:payloads)for(unsigned side=0;side<2;++side)for(unsigned op=0;op<6;++op){
  uint64_t nan=0x7ff0000000000000ULL|p|((uint64_t)sign<<63),one=0x3ff0000000000000ULL,out=0;
  uint64_t left=side?one:nan,right=side?nan:one;
  feclearexcept(FE_ALL_EXCEPT); feraiseexcept(FE_DIVBYZERO); unsigned result=ops[op](&left,&right,&out); int flags=fetestexcept(FE_ALL_EXCEPT);
  int expected=FE_DIVBYZERO|((op==5||!(p&0x8000000000000ULL))?FE_INVALID:0);
  assert(fegetround()==mode);
  if(flags!=expected || (op<4&&(!(out&0x8000000000000ULL)||(out&0x7ff0000000000000ULL)!=0x7ff0000000000000ULL)) || (op>=4&&result!=0)){
   fprintf(stderr,"op%u side%u bits%016llx flags%x expected%x out%016llx result%u\n",op,side,(unsigned long long)nan,flags,expected,(unsigned long long)out,result);return 1;
  }++count;
 }
 }
 fesetround(FE_TONEAREST);
 auto widen=(void(*)(const uint32_t*,uint64_t*))load(dir+"/widen.bin");
 auto narrow=(void(*)(const uint64_t*,uint32_t*))load(dir+"/narrow.bin");
 const uint32_t singles[]={0,0x80000000,1,0x3f800000,0x7f800000,0x7f800001,0x7fa00000,0x7fc00000,0x7fc12345,0xff800123,0xffc00123};
 for(uint32_t bits:singles){uint64_t wide; uint32_t back; feclearexcept(FE_ALL_EXCEPT);widen(&bits,&wide);narrow(&wide,&back);assert(wide==factor::widen_float_bits(bits)&&back==bits&&fetestexcept(FE_ALL_EXCEPT)==0);count+=2;}
 const uint64_t doubles[]={0x7ff0000000000001ULL,0xfff0000000000001ULL,0x7ff8000000000001ULL,0x7ff8123456789abcULL};
 for(uint64_t bits:doubles){uint32_t out;feclearexcept(FE_ALL_EXCEPT);narrow(&bits,&out);assert(out==factor::narrow_float_bits(bits)&&fetestexcept(FE_ALL_EXCEPT)==0);++count;}
 uint64_t a=0x4000000000000000ULL,b=0x3ff0000000000000ULL,out;
 const uint64_t expected[]={0x4008000000000000ULL,0x3ff0000000000000ULL,0x4000000000000000ULL,0x4000000000000000ULL};
 for(unsigned op=0;op<4;++op){feclearexcept(FE_ALL_EXCEPT);ops[op](&a,&b,&out);assert(out==expected[op]&&fetestexcept(FE_ALL_EXCEPT)==0);++count;}
 auto foreign_load=(void(*)(const uint64_t*,uint64_t*))load(dir+"/foreign-load.bin");
 auto foreign_store=(void(*)(const uint64_t*,uint64_t*))load(dir+"/foreign-store.bin");
 auto home=(void(*)(const uint64_t*,uint64_t*))load(dir+"/home.bin");
 auto callback=(void(*)(const uint64_t*,uint64_t*))load(dir+"/callback-input.bin");
 for(unsigned sign=0;sign<2;++sign)for(uint64_t p:payloads){
  uint64_t canonical=0x7ff0000000000000ULL|p|((uint64_t)sign<<63),native=factor::hppa_native_double_bits(canonical),got;
  feclearexcept(FE_ALL_EXCEPT);
  foreign_store(&canonical,&got);assert(got==native);
  home(&canonical,&got);assert(got==native);
  foreign_load(&native,&got);assert(got==factor::hppa_canonical_double_bits(native));
  callback(&native,&got);assert(got==factor::hppa_canonical_double_bits(native));
  assert(fetestexcept(FE_ALL_EXCEPT)==0); count+=4;
 }
 // Opaque native arithmetic constructs its quiet NaN before flags are cleared.
 volatile double zero=0.0; double generated=zero/zero;
 uint64_t native=factor::double_bits(generated),canonical;
 foreign_load(&native,&canonical);
 feclearexcept(FE_ALL_EXCEPT);unsigned result=ops[4](&canonical,&b,&out);
 assert(result==0&&fetestexcept(FE_ALL_EXCEPT)==0);++count;
 for(unsigned scenario=0;scenario<3;++scenario){
  pid_t child=fork();assert(child>=0);
  if(!child){uint64_t nan=scenario==1?0x7ff0000000000001ULL:0x7ff8000000000000ULL;
   feclearexcept(FE_ALL_EXCEPT);assert(feenableexcept(FE_INVALID)>=0);
   ops[scenario==2?5:4](&nan,&b,&out);_exit(0);}
  int status;assert(waitpid(child,&status,0)==child);
  if(scenario==0)assert(WIFEXITED(status)&&WEXITSTATUS(status)==0);
  else assert(WIFSIGNALED(status)&&WTERMSIG(status)==SIGFPE);
  ++count;
 }
 printf("Factor-emitted NaN execution/bit precision: %u native controls passed\n",count);
}
