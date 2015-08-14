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

template <typename Block> void free_list_allocator<Block>::sweep() {
  auto null_sweep = [](Block* free_block, cell size) { };
  sweep(null_sweep);
}

/* The forwarding map must be computed first by calling
   state.compute_forwarding(). */
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::compact(Iterator& iter, Fixup fixup,
                                         const Block** finger) {
  cell dest_addr = start;
  auto compact_block_func = [&](Block* block, cell size) {
    cell block_addr = (cell)block;
    if (!this->state.marked_p(block_addr))
      return;
    *finger = (Block*)(block_addr + size);
    memmove((Block*)dest_addr, block, size);
    iter(block, (Block*)dest_addr, size);
    dest_addr += size;
  };
  iterate(compact_block_func, fixup);

  /* Now update the free list; there will be a single free block at
     the end */
  free_blocks.initial_free_list(start, end, dest_addr - start);
}

/* During compaction we have to be careful and measure object sizes
   differently */
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::iterate(Iterator& iter, Fixup fixup) {
  cell scan = this->start;
  while (scan != this->end) {
    Block* block = (Block*)scan;
    cell size = fixup.size(block);
    if (!block->free_p())
      iter(block, size);
    scan += size;
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
