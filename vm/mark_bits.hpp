namespace factor {

const int mark_bits_granularity = sizeof(cell) * 8;
const int mark_bits_mask = sizeof(cell) * 8 - 1;

struct mark_bits {
  cell size;
  cell start;
  cell bits_size;
  cell* marked;
  cell* forwarding;

  void clear_mark_bits() { memset(marked, 0, bits_size * sizeof(cell)); }

  void clear_forwarding() { memset(forwarding, 0, bits_size * sizeof(cell)); }

  mark_bits(cell size, cell start)
      : size(size),
        start(start),
        bits_size(size / data_alignment / mark_bits_granularity),
        marked(new cell[bits_size]),
        forwarding(new cell[bits_size]) {
    clear_mark_bits();
    clear_forwarding();
  }

  ~mark_bits() {
    delete[] marked;
    marked = nullptr;
    delete[] forwarding;
    forwarding = nullptr;
  }

  cell block_line(cell address) {
    return (address - start) / data_alignment;
  }

  cell line_block(cell line) {
    return line * data_alignment + start;
  }

  std::pair<cell, cell> bitmap_deref(const cell address) {
    cell line_number = block_line(address);
    cell word_index = (line_number / mark_bits_granularity);
    cell word_shift = (line_number & mark_bits_mask);
    return std::make_pair(word_index, word_shift);
  }

  bool bitmap_elt(cell* bits, const cell address) {
    std::pair<cell, cell> position = bitmap_deref(address);
    return (bits[position.first] & ((cell)1 << position.second)) != 0;
  }

  void set_bitmap_range(cell* bits, const cell address, const cell data_size) {
    std::pair<cell, cell> bitmap_start = bitmap_deref(address);
    std::pair<cell, cell> end = bitmap_deref(address + data_size);

    cell start_mask = ((cell)1 << bitmap_start.second) - 1;
    cell end_mask = ((cell)1 << end.second) - 1;

    if (bitmap_start.first == end.first)
      bits[bitmap_start.first] |= start_mask ^ end_mask;
    else {
      FACTOR_ASSERT(bitmap_start.first < bits_size);
      bits[bitmap_start.first] |= ~start_mask;

      for (cell index = bitmap_start.first + 1; index < end.first; index++)
        bits[index] = (cell)-1;

      if (end_mask != 0) {
        FACTOR_ASSERT(end.first < bits_size);
        bits[end.first] |= end_mask;
      }
    }
  }

  bool marked_p(const cell address) { return bitmap_elt(marked, address); }

  void set_marked_p(const cell address, const cell dsize) {
    set_bitmap_range(marked, address, dsize);
  }

  // The eventual destination of a block after compaction is just the number
  // of marked blocks before it. Live blocks must be marked on entry.
  void compute_forwarding() {
    cell accum = 0;
    for (cell index = 0; index < bits_size; index++) {
      forwarding[index] = accum;
      accum += popcount(marked[index]);
    }
  }

  // We have the popcount for every mark_bits_granularity entries; look
  // up and compute the rest
  cell forward_block(const cell original) {
    FACTOR_ASSERT(marked_p(original));
    std::pair<cell, cell> position = bitmap_deref(original);
    cell offset = original & (data_alignment - 1);

    cell approx_popcount = forwarding[position.first];
    cell mask = ((cell)1 << position.second) - 1;

    cell new_line_number =
        approx_popcount + popcount(marked[position.first] & mask);
    cell new_block = line_block(new_line_number) + offset;
    FACTOR_ASSERT(new_block <= original);
    return new_block;
  }

  cell next_unmarked_block_after(const cell original) {
    std::pair<cell, cell> position = bitmap_deref(original);
    cell bit_index = position.second;

    for (cell index = position.first; index < bits_size; index++) {
      cell mask = ((fixnum)marked[index] >> bit_index);
      if (~mask) {
        // Found an unmarked block on this page. Stop, it's hammer time
        cell clear_bit = rightmost_clear_bit(mask);
        return line_block(index * mark_bits_granularity + bit_index +
                          clear_bit);
      }
      // No unmarked blocks on this page. Keep looking
      bit_index = 0;
    }

    // No unmarked blocks were found
    return this->start + this->size;
  }

  cell next_marked_block_after(const cell original) {
    std::pair<cell, cell> position = bitmap_deref(original);
    cell bit_index = position.second;

    for (cell index = position.first; index < bits_size; index++) {
      cell mask = (marked[index] >> bit_index);
      if (mask) {
        // Found an marked block on this page. Stop, it's hammer time
        cell set_bit = rightmost_set_bit(mask);
        return line_block(index * mark_bits_granularity + bit_index + set_bit);
      }
      // No marked blocks on this page. Keep looking
      bit_index = 0;
    }

    // No marked blocks were found
    return this->start + this->size;
  }

  cell unmarked_block_size(cell original) {
    cell next_marked = next_marked_block_after(original);
    return next_marked - original;
  }
};

}
