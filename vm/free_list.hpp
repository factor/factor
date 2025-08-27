namespace factor {

static const cell free_list_count = 32;
static const cell allocation_page_size = 1024;

struct free_heap_block {
  cell header;

  bool free_p() const { return (header & 1) == 1; }

  cell size() const {
    cell size = header & ~7;
    FACTOR_ASSERT(size > 0);
    return size;
  }

  void make_free(cell size) {
    FACTOR_ASSERT(size > 0);
    header = size | 1;
  }
};

struct block_size_compare {
  bool operator()(free_heap_block* a, free_heap_block* b) const {
    return a->size() < b->size();
  }
};

struct allocator_room {
  cell size;
  cell occupied_space;
  cell total_free;
  cell contiguous_free;
  cell free_block_count;
};

template <typename Block> struct free_list_allocator {
  // Region of memory managed by this free list allocator.
  cell start;
  cell end;
  cell size;

  // Stores the free blocks
  std::vector<free_heap_block*> small_blocks[free_list_count];
  std::multiset<free_heap_block*, block_size_compare> large_blocks;
  cell free_block_count;
  cell free_space;

  mark_bits state;

  // Initializing & freeing
  free_list_allocator(cell size_, cell start_);
  void initial_free_list(cell occupied);
  void clear_free_list();
  void add_to_free_list(free_heap_block* block);
  void free(Block* block);

  // Allocating
  free_heap_block* find_free_block(cell requested_size);
  free_heap_block* split_free_block(free_heap_block* block, cell requested_size);
  Block* allot(cell requested_size);

  // Data
  bool contains_p(Block* block);
  bool can_allot_p(cell requested_size);
  cell occupied_space();
  cell largest_free_block();
  allocator_room as_allocator_room();

  // Iteration
  void sweep();
  template <typename Iterator> void sweep(Iterator& iter);
  template <typename Iterator, typename Fixup>
  void compact(Iterator& iter, Fixup fixup, const Block** finger);
  template <typename Iterator, typename Fixup>
  void iterate(Iterator& iter, Fixup fixup);
};

template <typename Block>
void free_list_allocator<Block>::clear_free_list() {
  for (cell i = 0; i < free_list_count; i++)
    small_blocks[i].clear();
  large_blocks.clear();
  free_block_count = 0;
  free_space = 0;
}

template <typename Block>
void free_list_allocator<Block>::add_to_free_list(free_heap_block* block) {
  cell block_size = block->size();

  free_block_count++;
  free_space += block_size;

  if (block_size < free_list_count * data_alignment)
    small_blocks[block_size / data_alignment].push_back(block);
  else
    large_blocks.insert(block);
}

template <typename Block>
void free_list_allocator<Block>::initial_free_list(cell occupied) {
  clear_free_list();
  if (occupied != end - start) {
    free_heap_block* last_block = reinterpret_cast<free_heap_block*>(start + occupied);
    last_block->make_free(end - reinterpret_cast<cell>(last_block));
    add_to_free_list(last_block);
  }
}

template <typename Block>
free_list_allocator<Block>::free_list_allocator(cell size_, cell start_)
    : start(start_),
      end(start_ + size_),
      size(size_),
      state(mark_bits(size_, start_)) {
  initial_free_list(0);
}

template <typename Block>
bool free_list_allocator<Block>::contains_p(Block* block) {
  return (reinterpret_cast<cell>(block) - start) < size;
}

template <typename Block>
bool free_list_allocator<Block>::can_allot_p(cell requested_size) {
  return largest_free_block() >= std::max(requested_size, allocation_page_size);
}

template <typename Block>
free_heap_block* free_list_allocator<Block>::split_free_block(
    free_heap_block* block,
    cell requested_size) {
  if (block->size() != requested_size) {
    // split the block in two
    free_heap_block* split = reinterpret_cast<free_heap_block*>(reinterpret_cast<cell>(block) + requested_size);
    split->make_free(block->size() - requested_size);
    block->make_free(requested_size);
    add_to_free_list(split);
  }

  return block;
}

template <typename Block>
free_heap_block* free_list_allocator<Block>::find_free_block(cell requested_size) {
  // Check small free lists
  cell bucket = requested_size / data_alignment;
  if (bucket < free_list_count) {
    std::vector<free_heap_block*>& blocks = small_blocks[bucket];
    if (blocks.size() == 0) {
      // Round up to a multiple of 'requested_size'
      cell large_block_size = ((allocation_page_size + requested_size - 1) / requested_size) * requested_size;

      // Allocate a block this big
      free_heap_block* large_block = find_free_block(large_block_size);
      if (!large_block)
        return NULL;

      large_block = split_free_block(large_block, large_block_size);

      // Split it up into pieces and add each piece back to the free list
      for (cell offset = 0; offset < large_block_size; offset += requested_size) {
        free_heap_block* small_block = large_block;
        large_block = reinterpret_cast<free_heap_block*>(reinterpret_cast<cell>(large_block) + requested_size);
        small_block->make_free(requested_size);
        add_to_free_list(small_block);
      }
    }

    free_heap_block* block = blocks.back();
    blocks.pop_back();

    free_block_count--;
    free_space -= block->size();

    return block;
  } else {
    // Check large free list
    free_heap_block key;
    key.make_free(requested_size);
    auto iter = large_blocks.lower_bound(&key);
    auto end = large_blocks.end();

    if (iter != end) {
      free_heap_block* block = *iter;
      large_blocks.erase(iter);

      free_block_count--;
      free_space -= block->size();

      return block;
    }

    return NULL;
  }
}


template <typename Block>
Block* free_list_allocator<Block>::allot(cell requested_size) {
  cell aligned_size = align(requested_size, data_alignment);

  free_heap_block* block = find_free_block(aligned_size);
  if (block) {
    block = split_free_block(block, aligned_size);
    return reinterpret_cast<Block*>(block);
  }
  return NULL;
}

template <typename Block>
void free_list_allocator<Block>::free(Block* block) {
  free_heap_block* free_block = reinterpret_cast<free_heap_block*>(block);
  free_block->make_free(block->size());
  add_to_free_list(free_block);
}

template <typename Block>
cell free_list_allocator<Block>::occupied_space() {
  return size - free_space;
}

template <typename Block>
cell free_list_allocator<Block>::largest_free_block() {
  if (large_blocks.size()) {
    auto last = large_blocks.rbegin();
    return (*last)->size();
  } else {
    for (int i = free_list_count - 1; i >= 0; i--) {
      if (small_blocks[i].size())
        return small_blocks[i].back()->size();
    }
    return 0;
  }
}

template <typename Block>
template <typename Iterator>
void free_list_allocator<Block>::sweep(Iterator& iter) {
  clear_free_list();

  cell current = this->start;
  cell heap_end = this->end;

  while (current != heap_end) {
    // find next unmarked block
    current = state.next_unmarked_block_after(current);

    if (current != heap_end) {
      // find size
      cell block_size = state.unmarked_block_size(current);
      FACTOR_ASSERT(block_size > 0);

      free_heap_block* free_block = reinterpret_cast<free_heap_block*>(current);
      free_block->make_free(block_size);
      add_to_free_list(free_block);
      iter(reinterpret_cast<Block*>(current), block_size);

      current = current + block_size;
    }
  }
}

template <typename Block> void free_list_allocator<Block>::sweep() {
  auto null_sweep = [](Block* free_block, cell block_size) { (void)free_block; (void)block_size; };
  sweep(null_sweep);
}

// The forwarding map must be computed first by calling
// state.compute_forwarding().
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::compact(Iterator& iter, Fixup fixup,
                                         const Block** finger) {
  cell dest_addr = start;
  auto compact_block_func = [&](Block* block, cell block_size) {
    cell block_addr = reinterpret_cast<cell>(block);
    if (!state.marked_p(block_addr))
      return;
    *finger = reinterpret_cast<Block*>(block_addr + block_size);
    if (dest_addr != reinterpret_cast<cell>(block)) {
      memmove(reinterpret_cast<Block*>(dest_addr), block, block_size);
    }
    iter(block, reinterpret_cast<Block*>(dest_addr), block_size);
    dest_addr += block_size;
  };
  iterate(compact_block_func, fixup);

  // Now update the free list; there will be a single free block at
  // the end
  initial_free_list(dest_addr - start);
}

// During compaction we have to be careful and measure object sizes
// differently
template <typename Block>
template <typename Iterator, typename Fixup>
void free_list_allocator<Block>::iterate(Iterator& iter, Fixup fixup) {
  cell scan = this->start;
  while (scan != this->end) {
    Block* block = reinterpret_cast<Block*>(scan);
    cell block_size = fixup.size(block);
    if (!block->free_p())
      iter(block, block_size);
    scan += block_size;
  }
}

template <typename Block>
allocator_room free_list_allocator<Block>::as_allocator_room() {
  allocator_room room;
  room.size = size;
  room.occupied_space = occupied_space();
  room.total_free = free_space;
  room.contiguous_free = largest_free_block();
  room.free_block_count = free_block_count;
  return room;
}

}
