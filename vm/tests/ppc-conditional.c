#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <assert.h>
static uint32_t words[2][3];
static uint32_t predicates[64][3];
static void load(const char *path,uint32_t *out,int n) { FILE*f=fopen(path,"rb");assert(f);for(int i=0;i<n;i++){unsigned char b[4];assert(fread(b,1,4,f)==4);out[i]=(uint32_t)b[0]<<24|(uint32_t)b[1]<<16|(uint32_t)b[2]<<8|b[3];}assert(fgetc(f)==EOF);fclose(f);}
static int probe(const uint32_t *code,int rawcr,int backwards,int arg,int count){
 unsigned char*m=mmap(0,131072,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(m!=MAP_FAILED);
 unsigned entry=backwards?65536:0,target=backwards?0:65536;
 uint32_t*p=(uint32_t*)(m+entry);
 p[0]=0x7d600026; /* mfcr r11: preserve nonvolatile CR fields */
 p[1]=rawcr?0x7c6ff120:0x2c030000; /* mtcrf255,r3 / cmpwi r3,0 */ p[2]=0x7c8903a6; /* mtctr r4 */
 for(int i=0;i<3;i++)p[3+i]=code[i];
 int displacement=(int)target-(int)(entry+20);
 p[5]=0x48000000|((uint32_t)displacement&0x03fffffc);
 p[6]=0x38600011;p[7]=0x7d6ff120;p[8]=0x4e800020;
 uint32_t*t=(uint32_t*)(m+target);t[0]=0x38600049;t[1]=0x7d6ff120;t[2]=0x4e800020;
 for(uintptr_t address=(uintptr_t)m;address<(uintptr_t)m+131072;address+=32) __asm__ volatile("dcbst 0,%0"::"r"(address):"memory");
 __asm__ volatile("sync":::"memory");
 for(uintptr_t address=(uintptr_t)m;address<(uintptr_t)m+131072;address+=32) __asm__ volatile("icbi 0,%0"::"r"(address):"memory");
 __asm__ volatile("sync; isync":::"memory");
 uintptr_t address=(uintptr_t)(m+entry);
#if defined(_CALL_ELF) && _CALL_ELF==1
 volatile uintptr_t descriptor[3]={address,0,0};address=(uintptr_t)descriptor;
#endif
 int result=((int(*)(int,int))address)(arg,count);munmap(m,131072);return result;
}
int main(int argc,char**argv){
 assert(argc==4);load(argv[1],words[0],3);load(argv[2],words[1],3);load(argv[3],predicates[0],192);
 for(int backwards=0;backwards<2;backwards++){
  assert(probe(words[0],0,backwards,0,2)==73);assert(probe(words[0],0,backwards,1,2)==17);
  assert(probe(words[1],0,backwards,0,2)==73);assert(probe(words[1],0,backwards,0,1)==17);
  for(unsigned bo=0;bo<2;bo++)for(unsigned bi=0;bi<32;bi++){
   const uint32_t *code=predicates[bo*32+bi];
   assert((code[0]>>26)==16);assert(((code[0]>>21)&31)==(bo?12:4));assert(((code[0]>>16)&31)==bi);
   assert(probe(code,1,backwards,0,2)==(bo?17:73));
   assert(probe(code,1,backwards,(int)(UINT32_C(1)<<(31-bi)),2)==(bo?73:17));
  }
 }
 puts("Factor conditional veneer +/-64KiB all32 CR bits BO4/12 and CTR paths passed (264 controls)");
}
