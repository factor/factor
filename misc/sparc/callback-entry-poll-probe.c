/* Execute Factor-emitted callback poll/prolog with real GNU native arguments. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
static uintptr_t results[8];
static unsigned char safepoint;
static uint32_t read_be(const unsigned char* p) { return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3]; }
static void write_be(unsigned char* p,uint32_t n) { p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n; }
static void set32(unsigned char* p,uint32_t n) { write_be(p,(read_be(p)&~0x3fffff)|(n>>10));write_be(p+4,(read_be(p+4)&~0x3ff)|(n&0x3ff)); }
int main(int argc,char** argv) {
 if(argc!=3)return 1;
 unsigned char* code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 FILE* f=fopen(argv[1],"rb");if(!f||code==MAP_FAILED)return 2;size_t size=fread(code,1,4096,f);fclose(f);
 f=fopen(argv[2],"rb");if(!f)return 3;unsigned char record[4];unsigned count=0;
 while(fread(record,1,4,f)==4) {
  uint32_t r=read_be(record);unsigned type=r>>28;uintptr_t target;
  if(type==15)target=(uintptr_t)&safepoint;else if(type==0)target=(uintptr_t)results;else return 4;
  if((r>>24&15)!=15)return 5;
  unsigned char* end=code+(r&0xffffff);
  if(sizeof(uintptr_t)==8) {set32(end-24,(uint64_t)target>>32);set32(end-12,target);}else set32(end-8,target);
  ++count;
 }
 fclose(f);if(count!=2)return 6;__builtin___clear_cache((char*)code,(char*)code+size);
 typedef uintptr_t (*entry_t)(uintptr_t,uintptr_t,uintptr_t,uintptr_t,uintptr_t,uintptr_t,double,double);
 uintptr_t returned=((entry_t)code)(101,102,103,104,105,106,1.25,-2.5);
 for(unsigned i=0;i<6;++i)if(results[i]!=101+i){fprintf(stderr,"argument%u=%lu\n",i,(unsigned long)results[i]);return 7;}
 if(returned!=106)return 8;
 if(sizeof(uintptr_t)==8) {double fp[2];memcpy(fp,results+6,16);if(fp[0]!=1.25||fp[1]!=-2.5)return 9;}
 printf("SPARC%zu emitted entry poll preserves six GP inputs%s\n",sizeof(uintptr_t)*8,sizeof(uintptr_t)==8?" and mixed FP inputs":"");return 0;
}
