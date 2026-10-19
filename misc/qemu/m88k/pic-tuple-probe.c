#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "pic-tuple-generated.h"
extern void m88k_cache_sync(void*,unsigned);
extern unsigned pic_tuple_call(unsigned,void*);
int main(void) {
 unsigned* obj=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);
 assert(obj!=MAP_FAILED);obj[0]=0;obj[1]=0x12345672;
 void* p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);
 assert(p!=MAP_FAILED);memcpy(p,code,sizeof(code));m88k_cache_sync(p,sizeof(code));
 assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0);
 assert(pic_tuple_call((unsigned)obj+7,p)==obj[1]);
 assert(pic_tuple_call((unsigned)obj+4,p)==4);
 assert(pic_tuple_call(16,p)==0);assert(pic_tuple_call(1,p)==1);
 puts("m88k guarded PIC tuple/tag probe PASS");return 0;
}
