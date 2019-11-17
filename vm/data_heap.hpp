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

  std::unique_ptr<card[]> cards;
  card* cards_end;

  std::unique_ptr<card_deck[]> decks;
  card_deck* decks_end;

  data_heap(bump_allocator* vm_nursery,
            cell young_size,
            cell aging_size,
            cell tenured_size);
  ~data_heap();
  
  // Disable copy operations to prevent double-delete
  data_heap(const data_heap&) = delete;
  data_heap& operator=(const data_heap&) = delete;
  
  // Enable move operations
  data_heap(data_heap&& other) noexcept;
  data_heap& operator=(data_heap&& other) noexcept;
  
  // Swap operation for efficiency
  void swap(data_heap& other) noexcept;
  
  std::unique_ptr<data_heap> grow(bump_allocator* vm_nursery, cell requested_size);
  template <typename Generation> void clear_cards(Generation* gen);
  template <typename Generation> void clear_decks(Generation* gen);
  void reset_nursery();
  void reset_aging();
  void reset_tenured();
  [[nodiscard]] bool high_fragmentation_p();
  [[nodiscard]] bool low_memory_p();
  void mark_all_cards();
  [[nodiscard]] cell high_water_mark() const { return nursery->size + aging->size; }
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
