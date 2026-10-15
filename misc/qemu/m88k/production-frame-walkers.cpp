// Unchanged production walkers and root visitor; VM allocation dependencies mocked.
#include "production-frame-visitor.cpp"
#define FACTOR_M88K 1
#define FACTOR_LINKED_FRAMES 1
#define FRAME_RETURN_ADDRESS 4
#define JIT_FRAME_SIZE 16
namespace factor {
typedef int fixnum;
static fixnum untag_fixnum(cell value) { return (fixnum)value; }
static void abort() { ::abort(); }
struct segment {
 cell start, end;
 bool in_segment_p(cell address) { return address >= start && address < end; }
};
struct context { cell callstack_top, callstack_bottom; };
struct callstack {
 cell length, base;
 cell frame_top_at(fixnum offset) { return base + offset; }
};
struct code_heap {
 segment* seg;
 code_block* block;
 unsigned lookups;
 code_block* code_block_for_address(cell address) {
  FACTOR_ASSERT(seg->in_segment_p(address));
  ++lookups; return block;
 }
};
struct callback_heap { segment* seg; };
struct factor_vm {
 code_heap* code;
 callback_heap* callbacks;
 template <typename Iterator, typename Fixup>
 void iterate_callstack(context*, Iterator&, Fixup&);
 template <typename Iterator, typename Fixup>
 void iterate_callstack_object(callstack*, Iterator&, Fixup&);
};
template <typename T> struct data_root {
 T* value;
 data_root(T* value, factor_vm*) : value(value) {}
 T* operator->() { return value; }
};
#include "production-frame-walkers.hpp"
}
extern "C" unsigned production_walk(unsigned* frames, unsigned length,
 const unsigned char* map, unsigned map_length, unsigned saved,
 unsigned code_start, unsigned code_length, unsigned stub_start,
 unsigned stub_length, unsigned* expected_root) {
 using namespace factor;
 alignas(4) unsigned char metadata[256];
 FACTOR_ASSERT(map_length < 252);
 unsigned padding = (4 - (map_length % 4)) % 4;
 memcpy(metadata + padding, map, map_length);
 gc_info* info = (gc_info*)(metadata + padding + map_length - sizeof(gc_info));
 code_block block = { info, code_start };
 segment code_segment = { code_start, code_start + code_length };
 segment stub_segment = { stub_start, stub_start + stub_length };
 code_heap heap = { &code_segment, &block, 0 };
 callback_heap callbacks = { &stub_segment };
 factor_vm vm = { &heap, &callbacks };
 slot_visitor<mock_fixup> visitor;
 visitor.visited = 0;
 call_frame_slot_visitor<mock_fixup> frame_visitor(&visitor);
 mock_fixup fixup;
 if (saved) {
  callstack stack = { length, (cell)frames };
  vm.iterate_callstack_object(&stack, frame_visitor, fixup);
 } else {
  context ctx = { (cell)frames, (cell)frames + length };
  vm.iterate_callstack(&ctx, frame_visitor, fixup);
 }
 FACTOR_ASSERT(heap.lookups == 1);
 return visitor.visited == expected_root;
}
