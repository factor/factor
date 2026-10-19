#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include "../../float_bits.hpp"
using namespace factor;
extern "C" double sh_call_emitted_double(void*,double,double);
extern "C" float sh_call_emitted_float(void*,float);
extern "C" int sh_call_emitted_compare(void*,double,double);
extern "C" double sh_call_emitted_memory_double(void*,void*,double);
extern "C" float sh_call_emitted_memory_float(void*,void*,float);
extern "C" double sh_call_emitted_widen(void*,float);
extern "C" float sh_call_emitted_narrow(void*,double);
static uint32_t fpscr(){uint32_t n;asm volatile("sts fpscr,%0":"=r"(n));return n;}
static void fpscr(uint32_t n){asm volatile("lds %0,fpscr"::"r"(n):"memory");}
static void* load(const char* root,const char* name){
 char path[4096];std::snprintf(path,sizeof path,"%s/%s.bin",root,name);
 void* p=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED)std::exit(2);int fd=open(path,O_RDONLY);if(fd<0)std::exit(3);
 ssize_t len=read(fd,p,4096);close(fd);if(len<1)std::exit(4);
 std::snprintf(path,sizeof path,"%s/%s-labels.bin",root,name);fd=open(path,O_RDONLY);if(fd<0)std::exit(5);
 uint32_t offset,target;while(read(fd,&offset,4)==4){if(read(fd,&target,4)!=4||offset<4||offset>unsigned(len)||target>unsigned(len))std::exit(6);uint32_t value=uint32_t(uintptr_t(p))+target;std::memcpy(static_cast<char*>(p)+offset-4,&value,4);}close(fd);
 __builtin___clear_cache(static_cast<char*>(p),static_cast<char*>(p)+len);return p;
}
int main(int argc,char**argv){
 if(argc!=2)return 2;void* nd=load(argv[1],"native-double");void* cd=load(argv[1],"canonical-double");void* nf=load(argv[1],"native-float");void* cf=load(argv[1],"canonical-float");void* add=load(argv[1],"add-double");
 void* ops[]={add,load(argv[1],"sub-double"),load(argv[1],"mul-double"),load(argv[1],"div-double"),load(argv[1],"sqrt-double")};
 void* trunc=load(argv[1],"truncate-double");
 void* td[4]={load(argv[1],"scalar-out-double"),load(argv[1],"scalar-in-double"),load(argv[1],"record-out-double"),load(argv[1],"record-in-double")};
 void* tf[4]={load(argv[1],"scalar-out-float"),load(argv[1],"scalar-in-float"),load(argv[1],"record-out-float"),load(argv[1],"record-in-float")};
 void* md[4]={load(argv[1],"typed-load-double"),load(argv[1],"raw-load-double"),load(argv[1],"typed-store-double"),load(argv[1],"raw-store-double")};
 void* mf[4]={load(argv[1],"typed-load-float"),load(argv[1],"raw-load-float"),load(argv[1],"typed-store-float"),load(argv[1],"raw-store-float")};
 void* sd[2]={load(argv[1],"scalar-stack-double"),load(argv[1],"record-stack-double")};
 void* widen=load(argv[1],"widen-float");void* narrow=load(argv[1],"narrow-double");
 void* less[2]={load(argv[1],"quiet-less"),load(argv[1],"ordered-less")};
 uint32_t original=fpscr();unsigned checks=0,failed=0;
 for(unsigned sign=0;sign<2;sign++)for(unsigned quiet=0;quiet<2;quiet++)for(unsigned payload=0;payload<3;payload++){
  if(!quiet&&!payload)continue;
  uint64_t d=(uint64_t(sign)<<63)|UINT64_C(0x7ff0000000000000)|(quiet?UINT64_C(0x8000000000000):0)|payload;
  uint32_t f=(sign<<31)|0x7f800000u|(quiet?0x400000u:0u)|payload;
  for(unsigned kind=0;kind<4;kind++){
   uint64_t memory=d;fpscr(0x80000);uint64_t out=double_bits(sh_call_emitted_memory_double(md[kind],&memory,bits_double(d)));uint64_t expected=kind==0?inverse_canonical_double_bits(d):kind==2?inverse_native_double_bits(d):d;bool ok=(kind<2?out:memory)==expected&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("memory double=%u got=%016llx expect=%016llx flags=%x\n",kind,(unsigned long long)(kind<2?out:memory),(unsigned long long)expected,fpscr());
   uint32_t memory32=f;fpscr(0x80000);uint32_t out32=float_bits(sh_call_emitted_memory_float(mf[kind],&memory32,bits_float(f)));uint32_t e32=kind==0?inverse_canonical_float_bits(f):kind==2?inverse_native_float_bits(f):f;ok=(kind<2?out32:memory32)==e32&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("memory float=%u got=%08x expect=%08x flags=%x\n",kind,kind<2?out32:memory32,e32,fpscr());
  }
  for(unsigned raw=0;raw<2;raw++){fpscr(0x80000);uint64_t out=double_bits(sh_call_emitted_double(sd[raw],bits_double(d),0.0));checks++;failed+=!(out==(raw?d:inverse_native_double_bits(d))&&!(fpscr()&0x7c));}
  for(unsigned transport=0;transport<4;transport++){
   fpscr(0x80000);uint64_t out=double_bits(sh_call_emitted_double(td[transport],bits_double(d),0.0));uint64_t expected=transport==0?inverse_native_double_bits(d):transport==1?inverse_canonical_double_bits(d):d;bool ok=out==expected&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("transport double=%u got=%016llx expect=%016llx flags=%x\n",transport,(unsigned long long)out,(unsigned long long)expected,fpscr());
   fpscr(0x80000);uint32_t out32=float_bits(sh_call_emitted_float(tf[transport],bits_float(f)));uint32_t e32=transport==0?inverse_native_float_bits(f):transport==1?inverse_canonical_float_bits(f):f;ok=out32==e32&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("transport float=%u got=%08x expect=%08x flags=%x\n",transport,out32,e32,fpscr());
  }
  fpscr(0x80000);uint64_t wide=double_bits(sh_call_emitted_widen(widen,bits_float(f)));checks++;bool wideok=wide==widen_float_bits(f)&&!(fpscr()&0x7c);failed+=!wideok;if(!wideok)std::printf("widen %08x got=%016llx expect=%016llx flags=%x\n",f,(unsigned long long)wide,(unsigned long long)widen_float_bits(f),fpscr());
  fpscr(0x80000);uint32_t small=float_bits(sh_call_emitted_narrow(narrow,bits_double(d)));checks++;bool smallok=small==narrow_float_bits(d)&&!(fpscr()&0x7c);failed+=!smallok;if(!smallok)std::printf("narrow %016llx got=%08x expect=%08x flags=%x\n",(unsigned long long)d,small,narrow_float_bits(d),fpscr());
  for(unsigned ordered=0;ordered<2;ordered++)for(unsigned side=0;side<2;side++){
   fpscr(0x80000);int result=sh_call_emitted_compare(less[ordered],side?1.0:bits_double(d),side?bits_double(d):1.0);
   bool ok=result==0&&(fpscr()&0x7c)==((ordered||!quiet)?0x40u:0u);checks++;failed+=!ok;
   if(!ok)std::printf("compare ordered=%u side=%u input=%016llx result=%d flags=%08x\n",ordered,side,(unsigned long long)d,result,fpscr());
  }
  for(unsigned direction=0;direction<2;direction++){
   fpscr(0x80000);uint64_t out=double_bits(sh_call_emitted_double(direction?cd:nd,bits_double(d),0.0));bool ok=out==(direction?inverse_canonical_double_bits(d):inverse_native_double_bits(d))&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("double direction=%u input=%016llx output=%016llx flags=%08x\n",direction,(unsigned long long)d,(unsigned long long)out,fpscr());
   uint32_t f=(sign<<31)|0x7f800000u|(quiet?0x400000u:0u)|payload;fpscr(0x80000);uint32_t z=float_bits(sh_call_emitted_float(direction?cf:nf,bits_float(f)));ok=z==(direction?inverse_canonical_float_bits(f):inverse_native_float_bits(f))&&!(fpscr()&0x7c);checks++;failed+=!ok;if(!ok)std::printf("float direction=%u input=%08x output=%08x\n",direction,f,z);
  }
  for(unsigned op=0;op<5;op++){fpscr(0x80000);uint64_t out=double_bits(sh_call_emitted_double(ops[op],bits_double(d),1.0));bool ok=(fpscr()&0x7c)==(quiet?0u:0x40u)&&(out&UINT64_C(0x7ff8000000000000))==UINT64_C(0x7ff8000000000000);checks++;failed+=!ok;if(!ok)std::printf("op=%u input=%016llx flags=%x out=%016llx\n",op,(unsigned long long)d,fpscr(),(unsigned long long)out);}
  fpscr(0x80000);sh_call_emitted_compare(trunc,bits_double(d),0.0);checks++;failed+=!((fpscr()&0x7c)==0x40u);
 }
 fpscr(0x80000);double finite=sh_call_emitted_double(add,1.0,2.0);bool ok=double_bits(finite)==UINT64_C(0x4008000000000000)&&!(fpscr()&0x7c);checks++;failed+=!ok;
 for(unsigned ordered=0;ordered<2;ordered++){fpscr(0x80000);int z=sh_call_emitted_compare(less[ordered],1.0,2.0);checks++;failed+=!(z==1&&!(fpscr()&0x7c));}
 fpscr(original);std::printf("checks=%u failed=%u restored=%d\n",checks,failed,fpscr()==original);return failed?1:0;
}
