/* Execute the full generated indirect hook, including native linked gates. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
extern void trampoline(void),trampoline2(void);
extern unsigned invoke_indirect(void*,void*,uintptr_t*);
static uintptr_t context[8];
static unsigned frames;
static void check_frame(void) {
 uintptr_t *p=(uintptr_t*)context[0];
 if(p && p[0]==0x13579bdf && p[1]) frames++;
}
struct pair { unsigned low,high; };
static unsigned wide(unsigned a,unsigned b,unsigned c,uint64_t value) {
 check_frame();return a==1&&b==2&&c==3&&value==UINT64_C(0x89abcdef01234567)?4321:0;
}
static unsigned record(unsigned a,unsigned b,unsigned c,struct pair value) {
 check_frame();return a==1&&b==2&&c==3&&value.low==0x01234567&&value.high==0x89abcdef?4321:0;
}
static unsigned six(unsigned a,unsigned b,unsigned c,unsigned d,unsigned e,unsigned f) {
 check_frame();return a+10*b+100*c+1000*d+10000*e+100000*f;
}
static unsigned char *readfile(const char *p,size_t *n) {
 FILE *f=fopen(p,"rb");if(!f)exit(2);fseek(f,0,SEEK_END);*n=ftell(f);rewind(f);
 unsigned char *b=malloc(*n);if(fread(b,1,*n,f)!=*n)exit(2);fclose(f);return b;
}
int main(int argc,char **argv) {
 if(argc!=4)return 2;
 size_t n,rn;unsigned char *b=readfile(argv[1],&n),*r=readfile(argv[2],&rn);
 void *code=mmap(0,n,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(code==MAP_FAILED)return 2;memcpy(code,b,n);
 for(size_t i=0;i<rn;i+=4){uint32_t e;memcpy(&e,r+i,4);unsigned t=e>>28,c=(e>>24)&15,o=e&0xffffff;if(c||o<4||o>n)return 2;
 uintptr_t value=t==12?(uintptr_t)trampoline:t==13?(uintptr_t)trampoline2:0;if(!value)return 2;memcpy((unsigned char*)code+o-4,&value,4);}
 __builtin___clear_cache(code,(char*)code+n);
 unsigned stacked=strcmp(argv[3],"record")==0;
 unsigned result=invoke_indirect(code,stacked?(void*)record:(void*)wide,context);
 printf("result=%u frames=%u\n",result,frames);
 unsigned ok=result==4321u&&frames==1;
 puts(ok?"SH4-ARGUMENT-BOUNDARY-NATIVE-PASS":"SH4-ARGUMENT-BOUNDARY-NATIVE-FAIL");return !ok;
}
