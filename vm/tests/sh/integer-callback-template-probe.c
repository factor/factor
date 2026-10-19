/* Execute the complete production callback snapshot on the SH native ABI.
 * This exercises frame/GP transport; it does not simulate Factor GC. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
static uint32_t vm[16], original[32], spare[32], safepoint;
static uint32_t ds[64], rs[64];
static unsigned char factor_stack[16384] __attribute__((aligned(16)));
static unsigned snapshot_ok;
static uint64_t target(void) {
  register uint32_t *ctx __asm__("r12");
  __asm__ volatile("" : "=r"(ctx));
  uint32_t *frame=(uint32_t *)(uintptr_t)ctx[4];
  snapshot_ok=ctx==spare && vm[0]==(uint32_t)(uintptr_t)spare &&
    frame[0]==0x76543210 &&
    frame[1]==11 && frame[2]==22 && frame[3]==33 && frame[4]==44 &&
    frame[28]==55 && frame[29]==66;
  return UINT64_C(0x89abcdef01234567);
}
extern uint64_t call_snapshot(void *code);
static unsigned char *read_file(const char *path,size_t *length) {
 FILE *f=fopen(path,"rb");if(!f)exit(2);fseek(f,0,SEEK_END);*length=ftell(f);rewind(f);
 unsigned char *p=malloc(*length);if(fread(p,1,*length,f)!=*length)exit(2);fclose(f);return p;
}
int main(int argc,char **argv) {
 if(argc!=3)return 2;size_t n,rn;unsigned char *bytes=read_file(argv[1],&n),*rel=read_file(argv[2],&rn);
 unsigned char *code=mmap(0,n,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(code==MAP_FAILED)return 2;memcpy(code,bytes,n);
 vm[0]=(uint32_t)(uintptr_t)original;vm[1]=(uint32_t)(uintptr_t)spare;
 spare[1]=(uint32_t)(uintptr_t)(factor_stack+8192);spare[2]=(uint32_t)(uintptr_t)ds;spare[3]=(uint32_t)(uintptr_t)rs;
 for(size_t i=0;i<rn;i+=4){uint32_t e;memcpy(&e,rel+i,4);unsigned type=e>>28,cls=(e>>24)&15,off=e&0xffffff;if(cls||off<4||off>n)return 2;
 uint32_t value=type==9?(uint32_t)(uintptr_t)vm:type==15?(uint32_t)(uintptr_t)&safepoint:type==1?(uint32_t)(uintptr_t)target:0;if(!value)return 2;memcpy(code+off-4,&value,4);}
 __builtin___clear_cache((char*)code,(char*)code+n);
 uint64_t result=call_snapshot(code);
 printf("snapshot=%u result=%08x%08x context-restored=%u\n",snapshot_ok,(unsigned)(result>>32),(unsigned)result,vm[0]==(uint32_t)(uintptr_t)original);
 int status=!snapshot_ok||result!=UINT64_C(0x89abcdef01234567)||vm[0]!=(uint32_t)(uintptr_t)original;
 puts(status?"SH-INTEGER-CALLBACK-TEMPLATE-FAIL":"SH-INTEGER-CALLBACK-TEMPLATE-PASS");return status;
}
