#include "master.hpp"

namespace factor {

data_heap::data_heap(bump_allocator* vm_nursery,
                     cell young_size_,
                     cell aging_size_,
                     cell tenured_size_) {

  young_size_ = align(young_size_, deck_size);
  aging_size_ = align(aging_size_, deck_size);
  tenured_size_ = align(tenured_size_, deck_size);

  young_size = young_size_;
  aging_size = aging_size_;
  tenured_size = tenured_size_;

  cell total_size = young_size + 2 * aging_size + tenured_size + deck_size;
  seg = std::make_unique<segment>(total_size, false);

  cell cards_size = total_size / card_size;
  cards.resize(cards_size, 0);
  cards_end = cards.data() + cards_size;

  cell decks_size = total_size / deck_size;
  decks.resize(decks_size, 0);
  decks_end = decks.data() + decks_size;

  start = align(seg->start, deck_size);

  tenured = std::make_unique<tenured_space>(tenured_size, start);

  aging = std::make_unique<aging_space>(aging_size, tenured->end);
  aging_semispace = std::make_unique<aging_space>(aging_size, aging->end);

  // Initialize vm nursery
  vm_nursery->here = aging_semispace->end;
  vm_nursery->start = aging_semispace->end;
  vm_nursery->end = vm_nursery->start + young_size;
  vm_nursery->size = young_size;
  nursery = vm_nursery;

  FACTOR_ASSERT(seg->end - nursery->end <= deck_size);
}

data_heap::~data_heap() = default;

data_heap* data_heap::grow(bump_allocator* vm_nursery, cell requested_bytes) {
  FACTOR_ASSERT(vm_nursery->occupied_space() == 0);
  cell new_tenured_size = 2 * tenured_size + requested_bytes;
  return new data_heap(vm_nursery, young_size, aging_size, new_tenured_size);
}

template <typename Generation> void data_heap::clear_cards(Generation* gen) {
  cell first_card = addr_to_card(gen->start - start);
  cell last_card = addr_to_card(gen->end - start);
  std::fill(cards.begin() + first_card, cards.begin() + last_card, static_cast<card>(0));
}

template <typename Generation> void data_heap::clear_decks(Generation* gen) {
  cell first_deck = addr_to_deck(gen->start - start);
  cell last_deck = addr_to_deck(gen->end - start);
  std::fill(decks.begin() + first_deck, decks.begin() + last_deck, static_cast<card_deck>(0));
}

void data_heap::reset_nursery() {
  nursery->flush();
}

void data_heap::reset_aging() {
  aging->flush();
  clear_cards(aging.get());
  clear_decks(aging.get());
  aging->starts.clear_object_start_offsets();
}

void data_heap::reset_tenured() {
  clear_cards(tenured.get());
  clear_decks(tenured.get());
}

bool data_heap::high_fragmentation_p() {
  return tenured->largest_free_block() <= high_water_mark();
}

bool data_heap::low_memory_p() {
  return tenured->free_space <= high_water_mark();
}

void data_heap::mark_all_cards() {
  std::fill(cards.begin(), cards.end(), static_cast<card>(0xff));
  std::fill(decks.begin(), decks.end(), static_cast<card_deck>(0xff));
}

void factor_vm::set_data_heap(data_heap* data_) {
  data = data_;
  cards_offset = reinterpret_cast<cell>(data->cards.data()) - addr_to_card(data->start);
  decks_offset = reinterpret_cast<cell>(data->decks.data()) - addr_to_deck(data->start);
}

data_heap_room factor_vm::data_room() {
  data_heap_room room;

  room.nursery_size = data->nursery->size;
  room.nursery_occupied = data->nursery->occupied_space();
  room.nursery_free = data->nursery->free_space();
  room.aging_size = data->aging->size;
  room.aging_occupied = data->aging->occupied_space();
  room.aging_free = data->aging->free_space();
  room.tenured_size = data->tenured->size;
  room.tenured_occupied = data->tenured->occupied_space();
  room.tenured_total_free = data->tenured->free_space;
  room.tenured_contiguous_free = data->tenured->largest_free_block();
  room.tenured_free_block_count = data->tenured->free_block_count;
  room.cards = data->cards.size();
  room.decks = data->decks.size();
  room.mark_stack = mark_stack.capacity() * sizeof(cell);

  return room;
}

// Allocates memory
void factor_vm::primitive_data_room() {
  data_heap_room room = data_room();
  ctx->push(tag<byte_array>(byte_array_from_value(&room)));
}

// Allocates memory
cell factor_vm::instances(cell type) {
  primitive_full_gc();

  std::vector<cell> objects;
  auto object_accumulator = [&](object* obj) {
    if (type == TYPE_COUNT || obj->type() == type)
      objects.push_back(tag_dynamic(obj));
  };
  each_object(object_accumulator);
  return std_vector_to_array(objects);
}

// Allocates memory
void factor_vm::primitive_all_instances() {
  ctx->push(instances(TYPE_COUNT));
}

}
