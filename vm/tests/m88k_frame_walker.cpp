// Exercises the production linked-frame walkers with a minimal moving-heap fixture.
#include <cassert>
#include <stdint.h>
#include <cstring>
#include <cstdio>
#define FACTOR_ASSERT assert
#define FACTOR_LINKED_FRAMES
#ifndef M88K_FRAME_WALKER_HEADER
#define M88K_FRAME_WALKER_HEADER "../callstack.hpp"
#endif
namespace factor {
typedef uintptr_t cell;
typedef intptr_t fixnum;
static const unsigned FRAME_RETURN_ADDRESS=sizeof(cell);
struct context { cell callstack_top,callstack_bottom; };
struct code_block { unsigned id; };
struct callstack {
 cell length;
 cell payload[24];
 cell frame_top_at(cell offset) { return (cell)payload+offset; }
};
inline fixnum untag_fixnum(cell value) { return (fixnum)value; }
static void* moving_root;
template<class T> struct data_root {
 T* value;
 data_root(T* p,void*) : value(p) { moving_root=&value; }
 T* operator->() { return value; }
};
struct code_heap {
 code_block blocks[3];
 code_heap() { for(unsigned i=0;i<3;++i)blocks[i].id=i; }
 code_block* code_block_for_address(cell address) {
  unsigned id=(unsigned)(address&0xff);
  assert(id>=1&&id<=3);return &blocks[id-1];
 }
};
struct no_fixup {
 static const bool translated_code_block_map=false;
 code_block* translate_code(code_block* owner) { return owner; }
};
struct factor_vm {
 code_heap* code;
 template<class Iterator,class Fixup> void iterate_callstack(context*,Iterator&,Fixup&);
 template<class Iterator> void iterate_callstack(context*,Iterator&);
 template<class Iterator,class Fixup> void iterate_callstack_object(callstack*,Iterator&,Fixup&);
 template<class Iterator> void iterate_callstack_object(callstack*,Iterator&);
};
}
#include M88K_FRAME_WALKER_HEADER
using namespace factor;
struct relocation_fixup {
 static const bool translated_code_block_map=false;
 unsigned count;
 relocation_fixup():count(0){}
 code_block* translate_code(code_block* owner) { ++count;return owner; }
};
struct visitor {
 unsigned count;
 cell expected[3];
 callstack* moved;
 bool move_saved;
 visitor():count(0),moved(0),move_saved(false){}
 void operator()(cell top,cell size,code_block* owner,cell address) {
  unsigned id=owner->id;
  assert(id==count);assert(size==expected[id]);
  assert((address&0xff)==id+1);
  *(cell*)(top+FRAME_RETURN_ADDRESS)=0x2000+id+1;
  // A native bridge's map sees the suspended caller's first spill at +8cells;
  // the caller sees the same root at +4cells. Forwarding is idempotent.
  cell* root=(cell*)(top+(id==0?8:4)*sizeof(cell));
  assert(*root==0x1234||*root==0x5678);*root=0x5678;
  ++count;
  if(move_saved&&count==1) {
   callstack** slot=(callstack**)moving_root;
   moved=new callstack;std::memcpy(moved,*slot,sizeof(callstack));*slot=moved;
  }
 }
};
int main() {
 code_heap heap;factor_vm vm;vm.code=&heap;
 const unsigned sizes[]={4,8,8};
 cell storage[20]={};cell base=(cell)storage;
 unsigned offset=0;
 visitor live;
 for(unsigned i=0;i<3;++i) {
  storage[offset]=base+(offset+sizes[i])*sizeof(cell);
  storage[offset+1]=0x1000+i+1;
  storage[offset+4]=0x1234;
  live.expected[i]=sizes[i]*sizeof(cell);offset+=sizes[i];
 }
 // Bridge root aliases caller's first spill at storage[8].
 context ctx={base,base+sizeof(storage)};
 relocation_fixup fix;vm.iterate_callstack(&ctx,live,fix);
 assert(live.count==3&&fix.count==3);
 assert(storage[1]==0x2001&&storage[5]==0x2002&&storage[13]==0x2003);
 callstack saved={};saved.length=sizeof(storage);std::memcpy(saved.payload,storage,sizeof(storage));
 offset=0;
 for(unsigned i=0;i<3;++i) { saved.payload[offset]=sizes[i]*sizeof(cell);offset+=sizes[i]; }
 visitor snapshot;snapshot.move_saved=true;
 for(unsigned i=0;i<3;++i)snapshot.expected[i]=sizes[i]*sizeof(cell);
 vm.iterate_callstack_object(&saved,snapshot);
 assert(snapshot.count==3&&snapshot.moved);
 assert(snapshot.moved->payload[1]==0x2001&&snapshot.moved->payload[5]==0x2002&&snapshot.moved->payload[13]==0x2003);
 delete snapshot.moved;
 std::puts("m88k production frame walker gate PASS: live links saved sizes moving root code fixup bridge spill map");
 return 0;
}
