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
  cards = std::make_unique<card[]>(cards_size);
  cards_end = cards.get() + cards_size;
  memset(cards.get(), 0, cards_size);

  cell decks_size = total_size / deck_size;
  decks = std::make_unique<card_deck[]>(decks_size);
  decks_end = decks.get() + decks_size;
  memset(decks.get(), 0, decks_size);

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

data_heap::~data_heap() {
  // unique_ptr automatically handles deletion
}

data_heap::data_heap(data_heap&& other) noexcept 
    : start(other.start),
      young_size(other.young_size),
      aging_size(other.aging_size),
      tenured_size(other.tenured_size),
      seg(std::move(other.seg)),
      nursery(other.nursery),
      aging(std::move(other.aging)),
      aging_semispace(std::move(other.aging_semispace)),
      tenured(std::move(other.tenured)),
      cards(std::move(other.cards)),
      cards_end(other.cards_end),
      decks(std::move(other.decks)),
      decks_end(other.decks_end) {
  other.start = 0;
  other.nursery = nullptr;
  other.cards_end = nullptr;
  other.decks_end = nullptr;
}

data_heap& data_heap::operator=(data_heap&& other) noexcept {
  if (this != &other) {
    swap(other);
  }
  return *this;
}

void data_heap::swap(data_heap& other) noexcept {
  using std::swap;
  swap(start, other.start);
  swap(young_size, other.young_size);
  swap(aging_size, other.aging_size);
  swap(tenured_size, other.tenured_size);
  swap(seg, other.seg);
  swap(nursery, other.nursery);
  swap(aging, other.aging);
  swap(aging_semispace, other.aging_semispace);
  swap(tenured, other.tenured);
  swap(cards, other.cards);
  swap(cards_end, other.cards_end);
  swap(decks, other.decks);
  swap(decks_end, other.decks_end);
}

std::unique_ptr<data_heap> data_heap::grow(bump_allocator* vm_nursery, cell requested_bytes) {
  FACTOR_ASSERT(vm_nursery->occupied_space() == 0);
  cell new_tenured_size = 2 * tenured_size + requested_bytes;
  return std::make_unique<data_heap>(vm_nursery, young_size, aging_size, new_tenured_size);
}

template <typename Generation> void data_heap::clear_cards(Generation* gen) {
  cell first_card = addr_to_card(gen->start - start);
  cell last_card = addr_to_card(gen->end - start);
  memset(&cards.get()[first_card], 0, last_card - first_card);
}

template <typename Generation> void data_heap::clear_decks(Generation* gen) {
  cell first_deck = addr_to_deck(gen->start - start);
  cell last_deck = addr_to_deck(gen->end - start);
  memset(&decks.get()[first_deck], 0, last_deck - first_deck);
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
  memset(cards.get(), 0xff, cards_end - cards.get());
  memset(decks.get(), 0xff, decks_end - decks.get());
}

void factor_vm::set_data_heap(std::unique_ptr<data_heap> data_) {
  data = std::move(data_);
  cards_offset = reinterpret_cast<cell>(data->cards.get()) - addr_to_card(data->start);
  decks_offset = reinterpret_cast<cell>(data->decks.get()) - addr_to_deck(data->start);
}

data_heap_room factor_vm::data_room() {
  data_heap_room room;

  room.nursery_size = data->nursery->size;
  room.nursery_occupied = data->nursery->occupied_space();
  room.nursery_free = data->nursery->free_space();
  room.aging_size = data->aging.get()->size;
  room.aging_occupied = data->aging.get()->occupied_space();
  room.aging_free = data->aging.get()->free_space();
  room.tenured_size = data->tenured.get()->size;
  room.tenured_occupied = data->tenured.get()->occupied_space();
  room.tenured_total_free = data->tenured.get()->free_space;
  room.tenured_contiguous_free = data->tenured.get()->largest_free_block();
  room.tenured_free_block_count = data->tenured.get()->free_block_count;
  room.cards = data->cards_end - data->cards.get();
  room.decks = data->decks_end - data->decks.get();
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
