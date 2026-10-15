// Exercise the actual GC-map lookup and call-frame root visitor at the
// faulting instruction in Factor-generated SPARC safepoint bytes.
#include "../master.hpp"
#include <cassert>
#include <fstream>
#include <iterator>
namespace factor {
void critical_error(const char* message, cell) { fprintf(stderr, "%s\n", message); ::abort(); }
struct probe_fixup {
  static constexpr bool translated_code_block_map = true;
  unsigned* visits;
  code_block* translate_code(code_block* p) { return p; }
  object* fixup_data(object* p) { ++*visits; return (object*)((cell)p + 16); }
};
}
int main(int argc, char** argv) {
  using namespace factor;
  assert(argc == 3);
  std::ifstream file(argv[1], std::ios::binary);
  std::vector<uint8_t> code((std::istreambuf_iterator<char>(file)), {});
  cell recorded = std::strtoul(argv[2], nullptr, 10);
  cell fault = code.size() - 4;
  uint32_t insn = (uint32_t(code[fault]) << 24) | (uint32_t(code[fault+1]) << 16) |
                  (uint32_t(code[fault+2]) << 8) | code[fault+3];
  assert(insn == 0xc0086000); // LDUB g0,[g1+0]
  assert(fault == (sizeof(cell) == 8 ? 32 : 8));
  assert(recorded == fault);
  alignas(16) uint8_t storage[512] = {};
  auto* block = reinterpret_cast<code_block*>(storage);
  block->header = sizeof(storage);
  auto* info = block->block_gc_info();
  constexpr cell root = JIT_FRAME_SIZE / sizeof(cell);
  info->gc_root_count = root + 1;
  info->derived_root_count = 0;
  info->return_address_count = 1;
  info->return_addresses()[0] = recorded;
  info->gc_info_bitmap()[root / 8] = uint8_t(1u << (root % 8));
  assert(info->return_address_index(fault) == 0);
  assert(info->return_address_index(0) == cell(-1));
  alignas(16) cell windows[128] = {};
  cell fake = (cell)windows;
  cell parent = fake + JIT_FRAME_SIZE + 16;
  windows[0] = 0xabcdef;
  windows[14] = parent - SPARC_STACK_BIAS;
  windows[15] = block->entry_point() + fault - 8;
  cell* spill = reinterpret_cast<cell*>(parent) + root;
  *spill = 0x1002; // tagged non-immediate pointer
  unsigned visits = 0;
  slot_visitor<probe_fixup> slots(nullptr, probe_fixup{&visits});
  call_frame_slot_visitor<probe_fixup> frames(&slots);
  // The old prefix-start map misses the actual fault and leaves its root stale.
  info->return_addresses()[0] = 0;
  frames(fake, parent-fake, block, block->entry_point()+fault);
  assert(visits == 0 && *spill == 0x1002);
  info->return_addresses()[0] = recorded;
  frames(fake, parent-fake, block, block->entry_point()+fault);
  assert(visits == 1 && *spill == 0x1012);
  assert(windows[0] == 0xabcdef);
  assert(windows[14] == parent - SPARC_STACK_BIAS);
  assert(windows[15] + 8 == block->entry_point() + fault);
  printf("SPARC%zu safepoint fault=%zu: production visitor updates parent spill; old map misses\n", sizeof(cell)*8, fault);
}
