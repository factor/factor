/* Run in an s390x Linux guest with the .bin files exported by
 * s390x_bootstrap_export.factor. Compile with gcc -O2. The checked
 * arithmetic cases exercise non-overflow paths, so their native helper
 * relocations remain unused. A scratch context supplies save storage. */
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>
static int raw_probe(const char *name,int64_t x,int64_t y,int64_t expect){char path[128];snprintf(path,sizeof(path),"s390x-%s.bin",name);FILE*f=fopen(path,"rb");if(!f){perror(path);return 1;}unsigned char*code=mmap(0,4096,7,0x22,-1,0);size_t n=fread(code,1,4094,f);code[n]=7;code[n+1]=0xfe;fclose(f);int64_t stack[]={x,y};register int64_t*ds asm("6")=stack+1;register void*target asm("1")=code;intptr_t ctxdata[32]={0};register intptr_t*ctx asm("8")=ctxdata;asm volatile("basr %%r14,%%r1" : "+r"(ds),"+r"(target),"+r"(ctx) : : "r0","r2","r3","r4","r5","r14","cc","memory");munmap(code,4096);if(ds!=stack||stack[0]!=expect){printf("FAIL %s %lld %lld result %lld\n",name,(long long)x,(long long)y,(long long)stack[0]);return 1;}return 0;}
static int probe(const char *name,int64_t x,int64_t y,int64_t expect) { return raw_probe(name,x*16,y*16,expect*16); }
static void store_be32(unsigned char *p,uint32_t n) { p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n; }
static int mega_probe(void) {
  FILE *f=fopen("s390x-MEGA.bin","rb"); if(!f) return 1;
  unsigned char *code=mmap(0,4096,7,0x22,-1,0);size_t size=fread(code,1,4094,f);fclose(f);code[size]=7;code[size+1]=0xfe;
  _Alignas(16) uintptr_t cache[128];for(int i=0;i<128;i++)cache[i]=(uintptr_t)-1;
  uintptr_t tagged=(uintptr_t)cache|2;
  f=fopen("s390x-MEGA-relocations.bin","rb");if(!f)return 1;
  unsigned char bytes[4];while(fread(bytes,1,4,f)==4) {
    uint32_t rel=(uint32_t)bytes[0]<<24|(uint32_t)bytes[1]<<16|(uint32_t)bytes[2]<<8|bytes[3];
    if((rel>>28)==6) { unsigned char *site=code+(rel&0xffffff)-12;store_be32(site+2,tagged>>32);store_be32(site+8,tagged); }
  } fclose(f);
  register void *target asm("1")=code;register uintptr_t object asm("2")=11;register uintptr_t marker asm("5")=0x123456789;
  asm volatile("basr %%r14,%%r1" : "+r"(target),"+r"(object),"+r"(marker) : : "r0","r3","r4","r14","cc","memory");
  munmap(code,4096);if(marker!=0x123456789){puts("FAIL MEGA miss clobbers tail call marker");return 1;}return 0;
}
static int pic_miss_probe(void) {
  FILE *f=fopen("s390x-PIC-MISS.bin","rb");if(!f)return 1;
  unsigned char *code=mmap(0,4096,7,0x22,-1,0);size_t size=fread(code,1,4094,f);fclose(f);
  /* The relative branch exits this stub into a synthetic return instruction. */
  store_be32(code+size-4,3);code[size]=7;code[size+1]=0xfe;
  register void *target asm("1")=code;register uintptr_t marker asm("5")=0x1234;
  asm volatile("basr %%r14,%%r1" : "+r"(target),"+r"(marker) : : "r14","cc","memory");
  munmap(code,4096);if(marker==0x1234||!marker){puts("FAIL PIC miss return marker");return 1;}return 0;
}
int main(void){int failures=0,count=0;
#define P(n,x,y,z) do{failures+=probe(n,x,y,z);count++;}while(0)
P("fixnum-shift-fast",7,2,28);P("fixnum-shift-fast",-7,2,-28);P("fixnum-shift-fast",7,-2,1);P("fixnum-shift-fast",-7,-2,-2);P("fixnum-shift-fast",7,0,7);
P("fixnum+fast",7,-3,4);P("fixnum-fast",7,-3,10);P("fixnum+",7,-3,4);P("fixnum-",7,-3,10);
P("fixnum*fast",7,-3,-21);P("fixnum*",7,-3,-21);P("fixnum*",-7,3,-21);P("fixnum*",-7,-3,21);P("fixnum*",7,3,21);P("fixnum*",0,-3,0);
P("fixnum_i-fast",7,3,2);P("fixnum_i-fast",-7,3,-2);P("fixnum_i-fast",7,-3,-2);P("fixnum-mod",7,3,1);P("fixnum-mod",-7,3,-1);
P("fixnum-bitand",7,3,3);P("fixnum-bitor",7,8,15);P("fixnum-bitxor",7,3,4);
#define R(n,x,y,z) do{failures+=raw_probe(n,x,y,z);count++;}while(0)
R("both-fixnums?",0,16,16);R("both-fixnums?",1,16,1);R("both-fixnums?",1,1,1);
/* A zero placeholder for the unresolved canonical true literal is truthy. */
R("eq?",1,1,0);R("eq?",1,16,1);R("fixnum<",32,48,0);R("fixnum<",48,32,1);
failures+=mega_probe();count++;failures+=pic_miss_probe();count++;
printf("actual Factor bootstrap arithmetic bytes: %d passed, %d failed\n",count-failures,failures);return failures!=0;}
