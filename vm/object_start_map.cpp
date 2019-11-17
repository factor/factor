#include "master.hpp"

namespace factor {

object_start_map::object_start_map(cell size, cell start)
    : size(size), start(start) {
  cell card_count = size / card_size;
  object_start_offsets = std::make_unique<card[]>(card_count);
  object_start_offsets_end = object_start_offsets.get() + card_count;
  clear_object_start_offsets();
}

object_start_map::~object_start_map() { /* unique_ptr handles deletion */ }

cell object_start_map::find_object_containing_card(cell card_index) {
  if (card_index == 0)
    return start;
  card_index--;

  while (object_start_offsets.get()[card_index] == card_starts_inside_object) {
    // First card should start with an object
    FACTOR_ASSERT(card_index > 0);
    card_index--;
  }
  return start + card_index * card_size + object_start_offsets.get()[card_index];
}

// we need to remember the first object allocated in the card
void object_start_map::record_object_start_offset(object* obj) {
  cell idx = addr_to_card(reinterpret_cast<cell>(obj) - start);
  card obj_start = (reinterpret_cast<cell>(obj) & addr_card_mask);
  object_start_offsets.get()[idx] = std::min(object_start_offsets.get()[idx], obj_start);
}

void object_start_map::clear_object_start_offsets() {
  memset(object_start_offsets.get(), card_starts_inside_object, addr_to_card(size));
}

void object_start_map::update_card_for_sweep(cell index, uint16_t mask) {
  cell offset = object_start_offsets.get()[index];
  if (offset != card_starts_inside_object) {
    mask >>= (offset / data_alignment);

    if (mask == 0) {
      // The rest of the block after the old object start is free
      object_start_offsets.get()[index] = card_starts_inside_object;
    } else {
      // Move the object start forward if necessary
      object_start_offsets.get()[index] =
          (card)(offset + (rightmost_set_bit(mask) * data_alignment));
    }
  }
}

void object_start_map::update_for_sweep(mark_bits* state) {
  for (cell index = 0; index < state->bits_size; index++) {
    cell mask = state->marked.get()[index];
#ifdef FACTOR_64
    update_card_for_sweep(index * 4, mask & 0xffff);
    update_card_for_sweep(index * 4 + 1, (mask >> 16) & 0xffff);
    update_card_for_sweep(index * 4 + 2, (mask >> 32) & 0xffff);
    update_card_for_sweep(index * 4 + 3, (mask >> 48) & 0xffff);
#else
    update_card_for_sweep(index * 2, mask & 0xffff);
    update_card_for_sweep(index * 2 + 1, (mask >> 16) & 0xffff);
#endif
  }
}

}
