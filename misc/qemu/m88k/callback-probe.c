/* Actual emitted callbacks; independent model of moving-code GC return fixup. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <unistd.h>
#include <signal.h>
#include "callback-generated.h"
#ifndef MAP_STACK
#define MAP_STACK 0
#endif
extern void m88k_cache_sync(void *, size_t);
extern void trampoline(void);
extern void trampoline2(void);
struct context { unsigned top,bottom,ds,rs,save; };
struct fake_vm { struct context *ctx,*spare; };
extern unsigned production_visit(unsigned *,unsigned,const unsigned char *,unsigned,unsigned *);
extern unsigned production_walk(unsigned *,unsigned,const unsigned char *,unsigned,unsigned,
 unsigned,unsigned,unsigned,unsigned,unsigned *);
static struct context outer, inner[3];
static struct fake_vm vm;
enum { STACK_WORDS=16384 };
static unsigned *stack[3];
static unsigned ds[32],rs[32],poll;
static void *old_body,*new_body,*old_stub;
static unsigned bad_chain,moved,ended,depth,gc_count;
static unsigned addr(void *p) { return (unsigned)(uintptr_t)p; }
static void pair(void *code,unsigned end,unsigned target) {
 uint32_t *p=(uint32_t *)((char *)code+end);
 p[-2]=(p[-2]&0xffff0000u)|(target>>16);
 p[-1]=(p[-1]&0xffff0000u)|(target&0xffffu);
}
static void seal(void *p,size_t size) {
 m88k_cache_sync(p,size); assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0);
}
static unsigned model_begin_callback(struct fake_vm *parent,unsigned quot) {
 unsigned top,count=0; unsigned *frame, saved[24],relocated[24]; struct context *ctx=parent->ctx;
 assert(parent==&vm && depth<2 && ctx==inner+depth && quot==0);
 for(top=ctx->top;top<ctx->bottom;top=frame[0]) {
  frame=(unsigned *)(uintptr_t)top;
  if(frame[0]<=top || frame[0]>ctx->bottom || ++count>2) { bad_chain=1; break; }
 }
 if(top!=ctx->bottom || count!=2) bad_chain=1;
 if(bad_chain) { ++depth; return 0; }
 assert(ctx->bottom-ctx->top==96);
 assert(production_walk((unsigned *)(uintptr_t)ctx->top,96,callback_map,sizeof(callback_map),0,
  addr(moved ? new_body : old_body),sizeof(callback_body),addr(old_stub),sizeof(callback_stub),0));
 memcpy(saved,(void *)(uintptr_t)ctx->top,sizeof(saved)); saved[0]=16; saved[4]=80;
 memcpy(relocated,saved,sizeof(saved));
 for(top=ctx->top;top<ctx->bottom;top=frame[0]) {
  frame=(unsigned *)(uintptr_t)top;
  if(frame[0]==ctx->bottom) {
   /* Only the final frame may return into the pinned callback heap. */
   assert(frame[1]>=addr(old_stub) && frame[1]<addr(old_stub)+sizeof(callback_stub));
  } else if(!moved) {
   assert(frame[1]>=addr(old_body) && frame[1]<addr(old_body)+sizeof(callback_body));
   frame[1]+=addr(new_body)-addr(old_body);
  } else {
   assert(frame[1]>=addr(new_body) && frame[1]<addr(new_body)+sizeof(callback_body));
  }
 }
 if(!moved) relocated[1]+=addr(new_body)-addr(old_body);
 assert(relocated[5]==saved[5]);
 assert(production_walk(relocated,96,callback_map,sizeof(callback_map),1,
  addr(new_body),sizeof(callback_body),addr(old_stub),sizeof(callback_stub),0));
 if(!moved) {
  unsigned i;
  /* Production callback_heap::update changes its word operand; stub stays pinned. */
  assert(mprotect(old_stub,4096,PROT_READ|PROT_WRITE)==0);
  for(i=0;i<sizeof(callback_stub_fixups)/sizeof(callback_stub_fixups[0]);i++)
   if(callback_stub_fixups[i][0]==1) pair(old_stub,callback_stub_fixups[i][1],addr(new_body));
  seal(old_stub,sizeof(callback_stub));
  assert(mprotect(old_body,4096,PROT_NONE)==0); moved=1;
 }
 ++depth; parent->spare=inner+depth;
 return 0;
}
static unsigned map_return_offset(void) {
 const unsigned char *end=callback_map+sizeof(callback_map);
 return ((unsigned)end[-16]<<24)|((unsigned)end[-15]<<16)|((unsigned)end[-14]<<8)|end[-13];
}
static void visit_roots(struct context *ctx) {
 unsigned *bridge=(unsigned *)(uintptr_t)ctx->top;
 unsigned *body=(unsigned *)(uintptr_t)bridge[0];
 unsigned saved[24],relocated[24];
 assert(body-bridge==4 && body[0]==ctx->bottom && ctx->bottom-ctx->top==96);
 assert(bridge[1]==addr(new_body)+map_return_offset());
 assert(body[1]>=addr(old_stub) && body[1]<addr(old_stub)+sizeof(callback_stub));
 memcpy(saved,bridge,sizeof(saved)); saved[0]=16; saved[4]=80;
 memcpy(relocated,saved,sizeof(saved));
 assert(production_walk(relocated,96,callback_map,sizeof(callback_map),1,
  addr(new_body),sizeof(callback_body),addr(old_stub),sizeof(callback_stub),relocated+19));
 assert(relocated[19]==body[15]+0x1000 && relocated[20]==body[16]+0x1000);
 assert(relocated[5]==body[1]); /* Pinned boundary PC is retained without code fixup. */
 assert(production_walk(bridge,96,callback_map,sizeof(callback_map),0,
  addr(new_body),sizeof(callback_body),addr(old_stub),sizeof(callback_stub),body+15));
 assert(body[16]==body[15]+12);
}
static void model_callback_gc(struct fake_vm *unused) {
 typedef unsigned (*callback)(unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned);
 unsigned i; struct context *current=vm.ctx;
 (void)unused;
 if(bad_chain) return;
 for(i=0;i<depth;i++) visit_roots(inner+i);
 ++gc_count;
 if(depth==1) {
  unsigned nested_result=((callback)old_stub)(1,2,3,4,5,6,7,8,9,10);
  fprintf(stderr,"nested callback result=%u depth=%u vm.ctx=%p expected.ctx=%p\n",
   nested_result,depth,(void *)vm.ctx,(void *)current);
  assert(nested_result==385);
  assert(depth==1 && vm.ctx==current);
 }
}
static void model_end_callback(struct fake_vm *parent) {
 assert(parent==&vm && depth>0 && parent->ctx==inner+depth-1);
 if(!bad_chain) {
  unsigned *frame=(unsigned *)(uintptr_t)parent->ctx->top;
  unsigned *body=(unsigned *)(uintptr_t)frame[0];
  fprintf(stderr,"callback end depth=%u result.spill=%u root=%x derived=%x native.save=%x body=%p\n",
   depth,body[14],body[15],body[16],parent->ctx->save,(void *)body);
  assert(body[14]==385);
  assert(frame[1]>=addr(new_body) && frame[1]<addr(new_body)+sizeof(callback_body));
  assert(body[15]==(depth==2 ? 0x11000u : 0x12000u) && body[16]==body[15]+12);
 }
 --depth; ++ended;
}
static void *allocate(const unsigned char *data,size_t size) {
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 assert(p!=MAP_FAILED); memcpy(p,data,size); return p;
}
static void patch_body(void *code) {
 assert(sizeof(callback_body_fixups)/sizeof(callback_body_fixups[0])==3);
 assert(callback_body_fixups[0][0]==0 && callback_body_fixups[1][0]==0 && callback_body_fixups[2][0]==0);
 pair(code,callback_body_fixups[0][1],addr((void *)model_begin_callback));
 pair(code,callback_body_fixups[1][1],addr((void *)model_callback_gc));
 pair(code,callback_body_fixups[2][1],addr((void *)model_end_callback));
 seal(code,sizeof(callback_body));
}
static void patch_stub(void *code,void *body) {
 unsigned i,target=0;
 for(i=0;i<sizeof(callback_stub_fixups)/sizeof(callback_stub_fixups[0]);i++) {
  switch(callback_stub_fixups[i][0]) {
  case 9: target=addr(&vm); break;
  case 15: target=addr(&poll); break;
  case 12: target=addr((void *)trampoline); break;
  case 13: target=addr((void *)trampoline2); break;
  case 1: target=addr(body); break;
  default: assert(0);
  }
  pair(code,callback_stub_fixups[i][1],target);
 }
 seal(code,sizeof(callback_stub));
}
/* These must abort through production release guards, with VM assertions off. */
static void rejected_frames(void) {
 unsigned mode,kind;
 for(mode=0;mode<2;mode++) for(kind=0;kind<6;kind++) {
  pid_t child=fork(); int status;
  assert(child>=0);
  if(!child) {
   unsigned f[24]; struct rlimit limit={0,0};
   setrlimit(RLIMIT_CORE,&limit); alarm(5); memset(f,0,sizeof(f));
   f[0]=mode?16:addr(f+4); f[1]=addr(new_body)+420;
   f[4]=mode?80:addr(f+24); f[5]=addr(old_stub)+172;
   f[19]=0x10000; f[20]=0x1000c;
   switch(kind) {
   case 0: f[0]=mode?0:addr(f); break;
   case 1: f[0]=mode?8:addr(f+2); break;
   case 2: f[0]=mode?100:addr(f+25); break;
   case 3: f[1]=addr(old_stub)+172; break;
   case 4: f[5]=1; break;
   case 5: f[1]=1; break;
   }
   production_walk(f,sizeof(f),callback_map,sizeof(callback_map),mode,
    addr(new_body),sizeof(callback_body),addr(old_stub),sizeof(callback_stub),f+19);
   _exit(0);
  }
  assert(waitpid(child,&status,0)==child);
  assert(WIFSIGNALED(status) && WTERMSIG(status)==SIGABRT);
 }
}
int main(void) {
 typedef unsigned (*callback)(unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned);
 unsigned result,i;
 for(i=0;i<3;i++) {
  stack[i]=mmap(0,STACK_WORDS*4,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE|MAP_STACK,-1,0);
  assert(stack[i]!=MAP_FAILED);
  inner[i].top=inner[i].bottom=addr(stack[i]+STACK_WORDS-8);
  inner[i].ds=addr(ds); inner[i].rs=addr(rs);
 }
 vm.ctx=&outer; vm.spare=inner;
 old_body=allocate(callback_body,sizeof(callback_body));
 new_body=allocate(callback_body,sizeof(callback_body));
 old_stub=allocate(callback_stub,sizeof(callback_stub));
 patch_body(old_body); patch_body(new_body);
 patch_stub(old_stub,old_body);
 result=((callback)old_stub)(1,2,3,4,5,6,7,8,9,10);
 assert(result==385 && ended && vm.ctx==&outer);
 if(bad_chain) {
  puts("m88k callback audit FAIL: linked predecessor exceeds callstack_bottom before modeled GC");
  return 1;
 }
 assert(moved && ended==2 && gc_count==2 && depth==0);
 rejected_frames();
 puts("m88k callback audit PASS: actual 128-byte pinned stub, nested ten-argument callbacks, relocated body continuation, unchanged production walkers and live/moved-saved base and derived roots, 12 release-guard rejection controls");
 return 0;
}
