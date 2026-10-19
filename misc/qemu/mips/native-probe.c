#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <string.h>
typedef int (*code_fn)(int,int);
__attribute__((noinline)) double mix(int a,double b,int c,double d) { return a+b+c+d; }
static int callback(int a,int b) { return a+b; }
__attribute__((noinline)) int invoke(code_fn f) { return f(20,22); }
int main(void) {
 /* addu v0,a0,a1; jr ra; nop. Host/guest-native byte order. */
 const uint32_t insns[]={0x00851021,0x03e00008,0};
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED)return 10;
 memcpy(p,insns,sizeof insns);
 if(mprotect(p,4096,PROT_READ|PROT_EXEC))return 11;
 __builtin___clear_cache(p,(char*)p+sizeof insns);
 int result=invoke((code_fn)p);
 printf("ptr=%zu long=%zu generated=%d callback=%d fp=%.1f\n",sizeof(void*),sizeof(long),result,invoke(callback),mix(1,2.5,3,4.5));
 return result!=42 || invoke(callback)!=42 || mix(1,2.5,3,4.5)!=11;
}
