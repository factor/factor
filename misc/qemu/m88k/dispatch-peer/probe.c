/* Actual frozen bootstrap templates; no Factor heap or cold-start state changes. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>
#include "dispatch-peer-generated.h"
struct peer_context { unsigned top,bottom,ds,rs,save; };
struct peer_vm { struct peer_context *ctx; unsigned entry_r4; };
extern unsigned dispatch_peer_enter(void *,struct peer_context *,struct peer_vm *);
extern void dispatch_peer_primitive_entry(void),dispatch_peer_word_entry(void),dispatch_peer_tail_entry(void);
extern void m88k_cache_sync(void *,size_t);
static unsigned observed[5], calls;
void dispatch_peer_primitive(struct peer_vm *vm) {
 unsigned *ds=(unsigned *)(uintptr_t)vm->ctx->ds, i;
 ++calls;
 for(i=0;i<5;i++) observed[i]=ds[-(int)i];
 vm->ctx->ds -= 16;
 *(unsigned *)(uintptr_t)vm->ctx->ds=0x51515150;
}
static void pair(void *p,unsigned end,unsigned value) {
 uint32_t *words=(uint32_t *)((char *)p+end);
 assert((words[-2]&0xffff0000u)==0x5c800000u || (words[-2]&0xffff0000u)==0x5ea00000u || (words[-2]&0xffff0000u)==0x5ec00000u);
 words[-2]=(words[-2]&0xffff0000u)|(value>>16);
 words[-1]=(words[-1]&0xffff0000u)|(value&0xffffu);
}
static void *install(const unsigned char *data,unsigned size,const unsigned rel[][2],unsigned count,unsigned kind) {
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 unsigned i,literal=0;
 static const unsigned values[4]={0x100c,0x2002,0,0x3002};
 assert(p!=MAP_FAILED); memcpy(p,data,size);
 for(i=0;i<count;i++) {
  unsigned value;
  switch(rel[i][0]) {
  case 6: assert(literal<4); value=values[literal++]; break;
  case 0: value=(unsigned)(uintptr_t)dispatch_peer_primitive_entry; break;
  case 2: value=(unsigned)(uintptr_t)dispatch_peer_word_entry; break;
  case 3: value=(unsigned)(uintptr_t)dispatch_peer_tail_entry; break;
  case 4: value=(unsigned)(uintptr_t)p+rel[i][1]+12; break;
  default: assert(0); value=0;
  }
  pair(p,rel[i][1],value);
 }
 assert(kind!=0 || literal==4);
 m88k_cache_sync(p,size); assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0);
 return p;
}
int main(void) {
 unsigned ds[16]={1},rs[4]={0}, result,i;
 struct peer_context ctx={0,0,(unsigned)(uintptr_t)ds,(unsigned)(uintptr_t)rs,0};
 struct peer_vm vm={&ctx,0};
 struct rlimit core={0,0};
 void *quad,*word,*tail;
 setrlimit(RLIMIT_CORE,&core); alarm(10);
 quad=install(peer_quad,sizeof(peer_quad),peer_quad_reloc,sizeof(peer_quad_reloc)/sizeof(peer_quad_reloc[0]),0);
 word=install(peer_word,sizeof(peer_word),peer_word_reloc,sizeof(peer_word_reloc)/sizeof(peer_word_reloc[0]),1);
 tail=install(peer_tail,sizeof(peer_tail),peer_tail_reloc,sizeof(peer_tail_reloc)/sizeof(peer_tail_reloc[0]),2);
 result=dispatch_peer_enter(quad,&ctx,&vm);
 printf("quad result=%08x R4=%08x values=",result,vm.entry_r4);
 for(i=0;i<5;i++) printf("%s%08x",i?",":"",observed[i]); puts("");
 assert(calls==1 && result==0x51515150 && vm.entry_r4==0x3002);
 assert(observed[0]==0x3002 && observed[1]==0 && observed[2]==0x2002 && observed[3]==0x100c && observed[4]==1);
 result=dispatch_peer_enter(word,&ctx,&vm);
 printf("word R4=%08x\n",result); assert(result==0x11112222);
 result=dispatch_peer_enter(tail,&ctx,&vm);
 printf("tail R22=%08x expected=%08x\n",result,(unsigned)(uintptr_t)tail+sizeof(peer_tail));
 assert(result==(unsigned)(uintptr_t)tail+sizeof(peer_tail));
 puts("m88k dispatch peer template contracts PASS; quotation peepholes and real PIC miss remain outside this control");
 return 0;
}
