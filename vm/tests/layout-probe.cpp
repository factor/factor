#include "../master.hpp"
#include <cstddef>
#include <cassert>
#pragma GCC diagnostic ignored "-Winvalid-offsetof"
int main() {
  using namespace factor;
  printf("VM special_objects=%zu expected=%zu; native_cell_align=%zu heap_align=%u\n",
         offsetof(factor_vm, special_objects), 10 * sizeof(cell), alignof(cell), (unsigned)data_alignment);
  assert(offsetof(factor_vm, ctx) == 0);
  assert(offsetof(factor_vm, spare_ctx) == sizeof(cell));
  assert(offsetof(factor_vm, nursery) == 2 * sizeof(cell));
  assert(offsetof(factor_vm, cards_offset) == 6 * sizeof(cell));
  assert(offsetof(factor_vm, decks_offset) == 7 * sizeof(cell));
  assert(offsetof(factor_vm, signal_handler_addr) == 8 * sizeof(cell));
  assert(offsetof(factor_vm, faulting_p) == 9 * sizeof(cell));
  assert(offsetof(factor_vm, special_objects) == 10 * sizeof(cell));
  assert(offsetof(context, callstack_save) == 4 * sizeof(cell));
  assert(offsetof(context, callstack_seg) == 7 * sizeof(cell));
  assert(offsetof(segment, end) == 2 * sizeof(cell));
  assert(offsetof(boxed_float, n) == 8);
  assert(offsetof(alien, address) == 4 * sizeof(cell));
  assert(data_alignment == 16);
  return 0;
}
