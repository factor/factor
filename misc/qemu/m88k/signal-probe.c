/* Independent native emitted-transfer and linked live/saved root audit. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "signal-generated.h"
extern unsigned signal_call(void *, unsigned);
extern void m88k_cache_sync(void *, size_t);
static unsigned be32(const unsigned char *p) {
 return ((unsigned)p[0]<<24)|((unsigned)p[1]<<16)|((unsigned)p[2]<<8)|p[3];
}
static void visit(unsigned *frame) {
 unsigned i, roots, derived, count, base;
 const unsigned char *end=signal_map+sizeof(signal_map);
 const unsigned char *info=end-12, *bases;
 const unsigned char *bitmap;
 roots=be32(info); derived=be32(info+4); count=be32(info+8);
 assert(roots==9 && derived==10 && count==1);
 bases=info-4*(count+count*derived);
 bitmap=bases-(roots*count+7)/8;
 base=be32(bases+9*4); assert(base==8);
 frame[9]-=frame[base];
 for(i=0;i<roots;i++) if(bitmap[i/8]&(1u<<(i%8))) frame[i]+=0x1000;
 frame[9]+=frame[base];
}
int main(void) {
 unsigned stack[128], saved[128], *original=stack+64;
 unsigned *synthetic=original-4, *save=synthetic-36, *bridge=save-4;
 unsigned i; void *code;
 memset(stack,0,sizeof(stack));
 bridge[0]=(unsigned)save; bridge[1]=0x1111;
 save[0]=(unsigned)synthetic; save[1]=0x2222;
 synthetic[0]=(unsigned)original; synthetic[1]=0x3333;
 original[0]=(unsigned)(stack+96); original[1]=0x4444;
 original[4]=0x10000; original[5]=0x1000c;
 assert((char *)original-(char *)bridge==176);
 visit(synthetic); assert(original[4]==0x11000 && original[5]==0x1100c);
 memcpy(saved,stack,sizeof(stack));
 /* Saved-callstack format uses relative predecessor links. */
 for(i=20;i<96;) { unsigned next=(unsigned *)stack[i]-stack; saved[i]=(next-i)*4; i=next; }
 for(i=20;i<96;i+=saved[i]/4) if(saved[i+1]==0x3333) visit(saved+i);
 assert(saved[68]==0x12000 && saved[69]==0x1200c);
 code=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 assert(code!=MAP_FAILED); memcpy(code,signal_resume,sizeof(signal_resume));
 ((uint32_t *)code)[0]|=((unsigned)code+16)>>16;
 ((uint32_t *)code)[1]|=((unsigned)code+16)&0xffff;
 m88k_cache_sync(code,sizeof(signal_resume));
 assert(mprotect(code,4096,PROT_READ|PROT_EXEC)==0);
 for(i=0;i<100;i++) assert(signal_call(code,0x12340000+i)==0x12340000+i);
 puts("m88k signal frame audit PASS: 176-byte linked frames, live/saved derived roots, emitted JMP.n target capture and R21 restore");
 return 0;
}
