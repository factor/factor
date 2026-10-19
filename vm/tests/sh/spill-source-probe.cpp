#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
extern "C" uint64_t sh_spill_double(void*,const uint64_t*);
extern "C" uint32_t sh_spill_float(void*,const uint32_t*);
int main(int argc,char**argv){
 if(argc!=3)return 2;
 void*p=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)return 3;
 int f=open(argv[1],O_RDONLY);if(f<0)return 4;int n=read(f,p,4096);close(f);if(n<1)return 5;__builtin___clear_cache((char*)p,(char*)p+n);
 uint32_t saved;asm volatile("sts fpscr,%0":"=r"(saved));uint32_t control=0x80000;asm volatile("lds %0,fpscr"::"r"(control):"memory");
 const uint64_t bits[]={0,0x8000000000000000ULL,0x3ff8000000000000ULL,0xbff8000000000000ULL,0x7ff0000000000000ULL,0x7ff8000000000000ULL,0x7ff0000000001234ULL,0xfff8000000001234ULL};
 const uint32_t fb[]={0,0x80000000,0x3fc00000,0xbfc00000,0x7f800000,0x7fc00000,0x7f801234,0xffc01234};
 int fail=0,count=0;if(!strcmp(argv[2],"double")){for(auto x:bits){uint64_t y=sh_spill_double(p,&x);++count;if(x!=y){++fail;printf("bad %016llx %016llx\n",(unsigned long long)x,(unsigned long long)y);}}}else{for(auto x:fb){auto y=sh_spill_float(p,&x);++count;if(x!=y){++fail;printf("bad %08x %08x\n",x,y);}}}
 asm volatile("lds %0,fpscr"::"r"(saved):"memory");printf("%s controls=%d failures=%d\n",argv[2],count,fail);return fail?1:0;
}
