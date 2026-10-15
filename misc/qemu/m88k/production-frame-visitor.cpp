// Exact production collector algorithm; mock allocation/fixup dependencies only.
typedef unsigned int uint32_t;
typedef unsigned char uint8_t;
extern "C" void abort();
extern "C" void* memcpy(void*, const void*, unsigned long);
#ifdef M88K_RELEASE_WALKER_CONTROL
#define FACTOR_ASSERT(x) do {} while (0)
#else
#define FACTOR_ASSERT(x) do { if (!(x)) ::abort(); } while (0)
#endif
#ifndef M88K_DEFAULT_VISITOR_CONTROL
#define FACTOR_GC_ROOTS_AT_PREDECESSOR_SP 1
#endif
namespace factor { typedef unsigned int cell; }
#include "production-gc-info.hpp"
namespace factor {
static bool bitmap_p(uint8_t* bitmap, cell index) {
 return (bitmap[index / 8] & (1u << (index % 8))) != 0;
}
struct code_block {
 gc_info* info;
 cell code_start;
 cell offset(cell address) { return address - code_start; }
 cell size() { return 4096; }
 gc_info* block_gc_info() { return info; }
};
struct mock_fixup {
 static const bool translated_code_block_map = false;
 code_block* translate_code(code_block* code) { return code; }
};
template <typename Fixup> struct slot_visitor {
 Fixup fixup;
 cell* visited;
 void visit_handle(cell* root) { visited = root; *root += 0x1000; }
};
#include "production-frame-visitor.hpp"
}
extern "C" unsigned production_visit(unsigned* frame, unsigned size,
 const unsigned char* map, unsigned length, unsigned* expected_root) {
 using namespace factor;
 alignas(4) unsigned char metadata[256];
 FACTOR_ASSERT(length < 252);
 unsigned padding = (4 - (length % 4)) % 4;
 memcpy(metadata + padding, map, length);
 gc_info* info = (gc_info*)(metadata + padding + length - sizeof(gc_info));
 code_block block = { info };
 slot_visitor<mock_fixup> visitor;
 visitor.visited = 0;
 call_frame_slot_visitor<mock_fixup> frame_visitor(&visitor);
 frame_visitor((cell)frame, size, &block, info->return_addresses()[0]);
 return visitor.visited == expected_root;
}
