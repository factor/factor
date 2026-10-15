#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>
extern uintptr_t run_tail(void *, uintptr_t *);
extern void tail_target(void);
static unsigned char poll;
static void set32(uint32_t *p,uint32_t v) {
 p[0]=(p[0]&~0x3fffff)|(v>>10);p[1]=(p[1]&~0x3ff)|(v&0x3ff);
}
static void set64(uint32_t *p,uint64_t v) {set32(p,v>>32);set32(p+3,v);}
int main(int argc,char **argv) {
 if(argc!=2)return 2;
 FILE *f=fopen(argv[1],"rb");if(!f)return 2;
 unsigned char *p=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED)return 2;
 size_t n=fread(p,1,4096,f);fclose(f);unsigned jump=0;
 for(unsigned i=0;i+4<=n;i+=4)if(*(uint32_t*)(p+i)==0x81c06000)jump=i;
 if(!jump)return 3;
#if __SIZEOF_POINTER__ == 8
 for(unsigned i=0;i<jump;i+=4)if((*(uint32_t*)(p+i)&0xffc00000)==0x1b000000 && i+24<n && *(uint32_t*)(p+i+24)==0xda5ba8a7)set64((uint32_t*)(p+i),(uintptr_t)&poll);
 set64((uint32_t*)(p+jump-24),(uintptr_t)&tail_target);
#else
 for(unsigned i=0;i<jump;i+=4)if(*(uint32_t*)(p+i)==0xc0086000)set32((uint32_t*)(p+i-8),(uintptr_t)&poll);
 set32((uint32_t*)(p+jump-8),(uintptr_t)&tail_target);
#endif
 __builtin___clear_cache((char*)p,(char*)p+n);
 uintptr_t marker=0,parent=run_tail(p,&marker),expected=(uintptr_t)p+jump+8;
 printf("parent=%lu marker=%lx expected=%lx marker_ok=%d parent_ok=%d\n",(unsigned long)parent,(unsigned long)marker,(unsigned long)expected,marker==expected,parent==123);
 return marker==expected&&parent==123?0:1;
}
