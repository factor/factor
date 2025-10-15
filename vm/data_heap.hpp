#include <memory>
#include <vector>

namespace factor {


struct data_heap {
  cell start;

  cell young_size;
  cell aging_size;
  cell tenured_size;

  std::unique_ptr<segment> seg;

  // Borrowed reference to a factor_vm::nursery
  bump_allocator* nursery;
  std::unique_ptr<aging_space> aging;
  std::unique_ptr<aging_space> aging_semispace;
  std::unique_ptr<tenured_space> tenured;

  std::vector<card> cards;
  card* cards_end;  // Keep for compatibility

  std::vector<card_deck> decks;
  card_deck* decks_end;  // Keep for compatibility

  data_heap(bump_allocator* vm_nursery,
            cell young_size,
            cell aging_size,
            cell tenured_size);
  ~data_heap();
  data_heap* grow(bump_allocator* vm_nursery, cell requested_size);
  template <typename Generation> void clear_cards(Generation* gen);
  template <typename Generation> void clear_decks(Generation* gen);
  void reset_nursery();
  void reset_aging();
  void reset_tenured();
  bool high_fragmentation_p();
  bool low_memory_p();
  void mark_all_cards();
  cell high_water_mark() { return nursery->size + aging->size; }
};

struct data_heap_room {
  cell nursery_size;
  cell nursery_occupied;
  cell nursery_free;
  cell aging_size;
  cell aging_occupied;
  cell aging_free;
  cell tenured_size;
  cell tenured_occupied;
  cell tenured_total_free;
  cell tenured_contiguous_free;
  cell tenured_free_block_count;
  cell cards;
  cell decks;
  cell mark_stack;
};

}
