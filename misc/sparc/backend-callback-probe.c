#include <sys/mman.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern void sparc_callback_sret_entry(void);
struct result {int first,second,third;};
static void patch(unsigned char *end,uintptr_t address){
 uint32_t *words=(void*)(end-8);
 words[0]=(words[0]&~0x3fffff)|(address>>10);
 words[1]=(words[1]&~0x3ff)|(address&0x3ff);
}
int main(int argc,char **argv){
 unsigned char *code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 FILE *f=fopen(argv[1],"rb");if(code==MAP_FAILED||!f)return 2;
 size_t length=fread(code,1,4096,f);fclose(f);
 _Alignas(16) uintptr_t callstack[512]={0},active[5]={0},spare[5]={0};
 uintptr_t data[16]={0},retain[16]={0},vm[2]={(uintptr_t)active,(uintptr_t)spare};
 spare[1]=(uintptr_t)(callstack+400);spare[2]=(uintptr_t)data;spare[3]=(uintptr_t)retain;
 f=fopen(argv[2],"rb");if(!f)return 3;unsigned char bytes[4];unsigned count=0;
 while(fread(bytes,1,4,f)==4){
  uint32_t entry=(uint32_t)bytes[0]<<24|(uint32_t)bytes[1]<<16|(uint32_t)bytes[2]<<8|bytes[3];
  unsigned type=entry>>28,cls=entry>>24&15,offset=entry&0xffffff;
  if(cls!=15 || offset<8 || offset>length)return 4;
  uintptr_t value;
  if(count==0 && type==9)value=(uintptr_t)vm;
  else if(count==1 && type==1)value=(uintptr_t)sparc_callback_sret_entry;
  else if(count==2 && type==7)value=4;
  else return 5;
  patch(code+offset,value);count++;
 }
 fclose(f);if(count!=3)return 6;
 __builtin___clear_cache((char*)code,(char*)code+length);
 struct result (*callback)(int,int)=(void*)code;
 for(int a=-20;a<=20;a++)for(int b=-20;b<=20;b++){
  struct result value=callback(a,b);
  if(value.first!=a || value.second!=b || value.third!=a+b || vm[0]!=(uintptr_t)active)return 7;
 }
 puts("Factor-generated SPARC32 callback stub / GCC UNIMP12 / hidden stack64 / +12 return: 1681 cases PASS");return 0;
}
