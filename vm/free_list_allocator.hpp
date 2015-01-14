namespace factor {

struct allocator_room {
  cell size;
  cell occupied_space;
  cell total_free;
  cell contiguous_free;
  cell free_block_count;
};

template <typename Block> struct free_list_allocator {
  cell size;
  cell start;
  cell end;
  free_list free_blocks;
  mark_bits state;

  free_list_allocator(cell size, cell start);
  void initial_free_list(cell occupied);
  bool contains_p(Block* block);
  Block* next_allocated_block_after(Block* block);
  bool can_allot_p(cell size);
  Block* allot(cell size);
  void free(Block* block);
  cell occupied_space();
  cell free_space();
  cell largest_free_block();
  cell free_block_count();
  void sweep();
  template <typename Iterator> void sweep(Iterator& iter);
  template <typename Iterator, typename Fixup>
  void compact(Iterator& iter, Fixup fixup, const Block** finger);
  template <typename Iterator, typename Fixup>
  void iterate(Iterator& iter, Fixup fixup);
  template <typename Iterator> void iterate(Iterator& iter);
  allocator_room as_allocator_room();
};

template <typename Block>
free_list_allocator<Block>::free_list_allocator(cell size, cell start)
    : size(size),
      start(start),
      end(start + size),
      state(mark_bits(size, start)) {
  initial_free_list(0);
}

template <typename Block>
void free_list_allocator<Block>::initial_free_list(cell occupied) {
  free_blocks.initial_free_list(start, end, occupied);
}

template <typename Block>
bool free_list_allocator<Block>::contains_p(Block* block) {
  return ((cell)block - start) < size;
}

template <typename Block>
Block* free_list_allocator<Block>::next_allocated_block_after(Block* block) {
  while ((cell)block != this->end && block->free_p()) {
    free_heap_block* free_block = (free_heap_block*)block;
    block = (Block*)((cell)free_block + free_block->size());
  }

  if ((cell)block == this->end)
    return NULL;
  else
    return block;
}

template <typename Block>
bool free_list_allocator<Block>::can_allot_p(cell size) {
  return free_blocks.can_allot_p(size);
}

template <typename Block> Block* free_list_allocator<Block>::allot(cell size) {
  size = align(size, data_alignment);

  free_heap_block* block = free_blocks.find_free_block(size);
  if (block) {
    block = free_blocks.split_free_block(block, size);
    return (Block*)block;
  } else
    return NULL;
}

template <typename Block> void free_list_allocator<Block>::free(Block* block) {
  free_heap_block* free_block = (free_heap_block*)block;
  free_block->make_free(block->size());
  free_blocks.add_to_free_list(free_block);
}

template <typename Block> cell free_list_allocator<Block>::free_space() {
  return free_blocks.free_space;
}

template <typename Block> cell free_list_allocator<Block>::occupied_space() {
  return size - free_blocks.free_space;
}

template <typename Block>
cell free_list_allocator<Block>::largest_free_block() {
  return free_blocks.largest_free_block();
}

template <typename Block> cell free_list_allocator<Block>::free_block_count() {
  return free_blocks.free_block_count;
}

template <typename Block>
template <typename Iterator>
void free_list_allocator<Block>::sweep(Iterator& iter) {
  free_blocks.clear_free_list();

  cell start = this->start;
  cell end = this->end;

  while (start != end) {
    /* find next unmarked block */
    start = state.next_unmarked_block_after(start);

    if (start != end) {
      /* find size */
      cell size = state.unmarked_block_size(start);
      FACTOR_ASSERT(size > 0);

      free_heap_block* free_block = (free_heap_block*)start;
      free_block->make_free(size);
      free_blocks.add_to_free_list(free_block);
      iter((Block*)start, size);

      start = start + size;
    }
  }
}

template <typename Block> struct null_sweep_iterator {
  void operator()(Block* free_block, cell size) {}
};

template <typename Block> void free_list_allocator<Block>::sweep() {
  null_sweep_iterator<Block> none;
  sweep(none);
}

template <typename Block, typename Iterator> struct heap_compactor {
  mark_bits* state;
  char* address;
  Iterator& iter;
  const Block** finger;

  heap_compactor(mark_bits* state, Block* address,
                 Iterator& iter, const Block** finger)
      : state(state), address((char*)address), iter(iter), finger(finger) {}

  void operator()(Block* block, cell size) {
    if (this->state->marked_p((cell)block)) {
      *finger = (Block*)((char*)block + size);
      memmove((Block*)address, block, size);
      iter(block, (Block*)address, size);
      address += size;
    }
  }
};

/* The forwarding map must be computed first by calling
   state.compute_forwarding(). */
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::compact(Iterator& iter, Fixup fixup,
                                         const Block** finger) {
  heap_compactor<Block, Iterator> compactor(&state, (Block*)start, iter, finger);
  iterate(compactor, fixup);

  /* Now update the free list; there will be a single free block at
     the end */
  free_blocks.initial_free_list(start, end, (cell)compactor.address - start);
}

/* During compaction we have to be careful and measure object sizes
   differently */
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::iterate(Iterator& iter, Fixup fixup) {
  Block* scan = (Block*)this->start;
  Block* end = (Block*)this->end;

  while (scan != end) {
    cell size = fixup.size(scan);
    Block* next = (Block*)((cell)scan + size);
    if (!scan->free_p())
      iter(scan, size);
    scan = next;
  }
}

template <typename Block>
template <typename Iterator>
void free_list_allocator<Block>::iterate(Iterator& iter) {
  iterate(iter, no_fixup());
}

template <typename Block>
allocator_room free_list_allocator<Block>::as_allocator_room() {
  allocator_room room;

  room.size = size;
  room.occupied_space = occupied_space();
  room.total_free = free_space();
  room.contiguous_free = largest_free_block();
  room.free_block_count = free_block_count();
  return room;
}

}
