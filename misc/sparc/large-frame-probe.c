/* Actual Factor-generated prologues, GNU argument ABI and all parent l/i regs. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>
extern int sparc_compiler_enter(void (*fn)(void),void*,void*,void*);
static uintptr_t results[8];
static unsigned char safepoint;
static uint32_t read32(const unsigned char* p) {return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
static void write32(unsigned char* p,uint32_t n) {p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void set32(unsigned char* p,uint32_t n) {write32(p,(read32(p)&~0x3fffff)|(n>>10));write32(p+4,(read32(p+4)&~0x3ff)|(n&0x3ff));}
int main(int argc,char** argv) {
 if(argc!=2)return 1;
 const unsigned frames[]={4096,4112,8192,12288,65536};
 unsigned cases=0;
 for(unsigned fidx=0;fidx<5;++fidx) {
  char path[4096];snprintf(path,sizeof path,"%s/%zu-%u.bin",argv[1],sizeof(uintptr_t)*8,frames[fidx]);
  unsigned char* code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  FILE* f=fopen(path,"rb");if(!f||code==MAP_FAILED)return 2;
  size_t size=fread(code,1,4096,f);fclose(f);
  snprintf(path,sizeof path,"%s/%zu-%u.reloc",argv[1],sizeof(uintptr_t)*8,frames[fidx]);
  f=fopen(path,"rb");if(!f)return 3;unsigned char record[4];unsigned count=0;
  while(fread(record,1,4,f)==4) {
   uint32_t r=read32(record);unsigned type=r>>28;uintptr_t target;
   if(type==15)target=(uintptr_t)&safepoint;else if(type==0)target=(uintptr_t)results;else return 4;
   if((r>>24&15)!=15)return 5;
   unsigned char* end=code+(r&0xffffff);
   if(sizeof(uintptr_t)==8){set32(end-24,(uint64_t)target>>32);set32(end-12,target);}else set32(end-8,target);
   ++count;
  }
  fclose(f);if(count!=2)return 6;__builtin___clear_cache((char*)code,(char*)code+size);
  typedef uintptr_t (*entry_t)(uintptr_t,uintptr_t,uintptr_t,uintptr_t,uintptr_t,uintptr_t,double,double);
  for(unsigned i=0;i<1003;++i) {
   uintptr_t returned=((entry_t)code)(i+101,i+102,i+103,i+104,i+105,i+106,1.25,-2.5);
   for(unsigned j=0;j<6;++j)if(results[j]!=i+101+j){fprintf(stderr,"frame%u argument%u=%lu\n",frames[fidx],j,(unsigned long)results[j]);return 7;}
   if(returned!=i+106)return 8;
   if(sizeof(uintptr_t)==8){double fp[2];memcpy(fp,results+6,16);if(fp[0]!=1.25||fp[1]!=-2.5)return 9;}
   uintptr_t data[16]={0},retain[16]={0},vm[16]={0};
   if(sparc_compiler_enter((void(*)(void))code,data,retain,vm)){fprintf(stderr,"frame%u overwrote parent register window\n",frames[fidx]);return 13;}
   ++cases;
  }
  munmap(code,4096);
 }
 printf("SPARC%zu large-frame prologues: %u cases, six GP inputs%s and 14 parent window registers PASS\n",sizeof(uintptr_t)*8,cases,sizeof(uintptr_t)==8?", mixed FP":"");return 0;
}
