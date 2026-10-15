/* Real emitted 64/96-byte frames, callsite metadata, native gate and roots. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "nested-frame-generated.h"
extern void trampoline(void);
extern void m88k_cache_sync(void *,size_t);
extern unsigned nested_call(void *,unsigned,unsigned,void *,void *);
static unsigned context_top,visited,caller_cells,callee_cells;
#ifdef M88K_PRODUCTION_VISITOR
extern unsigned production_visit(unsigned *,unsigned,const unsigned char *,unsigned,unsigned *);
#endif
static unsigned be32(const unsigned char *p) {
 return ((unsigned)p[0]<<24)|((unsigned)p[1]<<16)|((unsigned)p[2]<<8)|p[3];
}
static void visit(unsigned *base) {
 const unsigned char *info=nested_map+sizeof(nested_map)-12;
 unsigned roots=be32(info),derived=be32(info+4),count=be32(info+8),i;
 const unsigned char *bases=info-4*(count+count*derived);
 const unsigned char *bitmap=bases-(roots*count+7)/8;
 assert(roots==5 && derived==6 && count==1 && be32(bases+5*4)==4);
 base[5]-=base[4];
 for(i=0;i<roots;i++) if(bitmap[i/8]&(1u<<(i%8))) base[i]+=0x1000;
 base[5]+=base[4];
}
static void nested_observer(void) {
 unsigned *bridge=(unsigned *)(uintptr_t)context_top;
 unsigned *callee=(unsigned *)(uintptr_t)bridge[0];
 unsigned *caller=(unsigned *)(uintptr_t)callee[0];
 unsigned *bottom=(unsigned *)(uintptr_t)caller[0];
 unsigned saved[64],relocated[64],i,next,total=4+caller_cells+callee_cells;
 unsigned caller_index=4+callee_cells;
 assert(callee-bridge==4 && caller-callee==callee_cells && bottom-caller==caller_cells);
 assert(callee[4]==0xdeadbeef && caller[4]==0x10000 && caller[5]==0x1000c);
 /* Previous-SP interpretation reaches the caller's spill slots. */
 assert(total<=64); memcpy(saved,bridge,total*4);
 for(i=0;i<total;) {
  next=((unsigned *)(uintptr_t)bridge[i])-bridge;
  saved[i]=(next-i)*4; i=next;
 }
 assert(i==total && saved[0]==16 && saved[4]==callee_cells*4 && saved[caller_index]==caller_cells*4);
 memcpy(relocated,saved,total*4);
 /* The frame at offset16 owns caller PC; its predecessor owns the spills. */
#ifdef M88K_PRODUCTION_VISITOR
 assert(production_visit(relocated+4,relocated[4],nested_map,sizeof(nested_map),relocated+caller_index+4));
#else
 visit(relocated+4+relocated[4]/4);
#endif
 assert(relocated[caller_index+4]==0x11000 && relocated[caller_index+5]==0x1100c);
 assert(saved[caller_index+4]==0x10000 && saved[caller_index+5]==0x1000c);
#ifdef M88K_PRODUCTION_VISITOR
 assert(production_visit(callee,(caller-callee)*4,nested_map,sizeof(nested_map),caller+4));
#else
 visit(caller);
#endif
 assert(caller[4]==0x11000 && caller[5]==0x1100c && callee[4]==0xdeadbeef);
 ++visited;
}
static void *load(const unsigned char *data,size_t size,unsigned end,unsigned target) {
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 uint32_t *pair;
 assert(p!=MAP_FAILED); memcpy(p,data,size); pair=(uint32_t *)((char *)p+end);
 pair[-2]=(pair[-2]&0xffff0000u)|(target>>16);
 pair[-1]=(pair[-1]&0xffff0000u)|(target&0xffffu);
 m88k_cache_sync(p,size); assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0); return p;
}
int main(void) {
 unsigned a,b;
 const unsigned char *callers[]={nested_caller64,nested_caller128};
 const unsigned char *callees[]={nested_callee64,nested_callee96};
 const unsigned caller_sizes[]={64,128},callee_sizes[]={64,96};
 for(a=0;a<2;a++) for(b=0;b<2;b++) {
  void *callee=load(callees[b],sizeof(nested_callee),36,(unsigned)(uintptr_t)nested_observer);
  void *caller=load(callers[a],sizeof(nested_caller),32,(unsigned)(uintptr_t)callee);
  caller_cells=caller_sizes[a]/4; callee_cells=callee_sizes[b]/4;
  assert(nested_call(caller,0x10000,0x1000c,&context_top,(void *)trampoline)==0x11000);
 }
 assert(visited==4);
#ifdef M88K_PRODUCTION_VISITOR
 puts("m88k production visitor matrix PASS: unchanged collector class, emitted callers64/128 and callees64/96, live/moved-saved base and derived roots");
#else
 puts("m88k nested frame matrix PASS: emitted callers64/128 and callees64/96, predecessor-SP live/moved-saved roots, frame-top reaches wrong sentinel");
#endif
 return 0;
}
