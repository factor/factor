#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
extern void trampoline2(void);
static uintptr_t context[16],vm[16];
static intptr_t move_delta;
static void patch_trampoline(unsigned char *bytes,size_t length){
 uint32_t *words=(void*)bytes; uint64_t address=(uintptr_t)trampoline2;
 for(size_t i=0;i<length/4;i++)if((words[i]&0xffc00000)==0x1f000000){
  if(sizeof(long)==8){
   words[i-3]=(words[i-3]&~0x3fffff)|((address>>42)&0x3fffff);
   words[i-2]=(words[i-2]&~0x3ff)|((address>>32)&0x3ff);
  }
  words[i]=(words[i]&~0x3fffff)|((address>>10)&0x3fffff);
  words[i+1]=(words[i+1]&~0x3ff)|(address&0x3ff);return;
 }
 fprintf(stderr,"no generated trampoline relocation found\n");abort();
}
static inline __attribute__((always_inline)) void check_window(void){
#if __arch64__
 __asm__ volatile("flushw" ::: "memory");
#else
 __asm__ volatile("ta 3" ::: "memory");
#endif
 uintptr_t *frame=(void*)context[0];
 uintptr_t parent=frame[14]+(sizeof(long)==8?2047:0);
 uintptr_t site=frame[15]+8;
 if(!parent || *(uint32_t*)site>>30!=3){fprintf(stderr,"invalid flushed native frame\n");abort();}
 frame[15]+=move_delta;
 __asm__ volatile("mov 7,%%g2\nmov 8,%%g3\nmov 9,%%g4" ::: "g2","g3","g4");
}
static long native_add(long a,long b){check_window();return a+b;}
struct result {int first,second,third;};
static struct result native_sret(long a,long b){
 check_window();struct result result={a,b,a+b};return result;
}
struct fp_result { float first,second; };
static struct fp_result native_aggregate(struct fp_result input){
 check_window();struct fp_result result={input.first+1.0f,input.second-1.0f};return result;
}
int main(int argc,char **argv){
 vm[0]=(uintptr_t)context;
 unsigned char *p=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 FILE *f=fopen(argv[1],"rb");if(p==MAP_FAILED||!f)return 2;
 size_t n=fread(p,1,4096,f);fclose(f);patch_trampoline(p,n);
 unsigned char *moved=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(moved==MAP_FAILED)return 4;
 memcpy(moved,p,n);move_delta=(intptr_t)moved-(intptr_t)p;
 __builtin___clear_cache((char*)p,(char*)p+n);
 __builtin___clear_cache((char*)moved,(char*)moved+n);
 long (*fn)(void*,long,long,void*,void*)=(void*)p;
 int sret=strstr(argv[1],"sret")!=0;
 int aggregate=strstr(argv[1],"aggregate")!=0;
 for(long a=-20;a<=20;a++)for(long b=-20;b<=20;b++){
  if(aggregate){
   union {struct fp_result fields; long bits;} input,output;
   input.fields=(struct fp_result){a,b};
   long (*aggregate_fn)(void*,long,void*)=(void*)p;
   output.bits=aggregate_fn(native_aggregate,input.bits,vm);
   if(output.fields.first!=a+1 || output.fields.second!=b-1)return 7;
  }else if(sret){
   struct result result={0,0,0};
   if(fn(native_sret,a,b,vm,&result)!=(long)&result || result.first!=a || result.second!=b || result.third!=a+b)return 5;
  }else if(fn(native_add,a,b,vm,0)!=a+b)return 3;
  uintptr_t global2,global3,global4;
  __asm__ volatile("mov %%g2,%0\nmov %%g3,%1\nmov %%g4,%2" : "=r"(global2),"=r"(global3),"=r"(global4));
  if(global2!=42 || global3!=43 || global4!=(uintptr_t)vm)return 6;
 }
 printf("Factor emitted SPARC%zu native %s window/globals/context/moved-return: 1681 cases PASS\n",sizeof(long)*8,aggregate?"aggregate":sret?"SRET":"FFI");
 return 0;
}
