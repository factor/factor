#include <algorithm>
#include <ranges>
#include <memory>

namespace factor {

const int mark_bits_granularity = sizeof(cell) * 8;
const int mark_bits_mask = sizeof(cell) * 8 - 1;

struct mark_bits {
  cell size;
  cell start;
  cell bits_size;
  std::unique_ptr<cell[]> marked;
  std::unique_ptr<cell[]> forwarding;

  void clear_mark_bits() { memset(marked.get(), 0, bits_size * sizeof(cell)); }

  void clear_forwarding() { memset(forwarding.get(), 0, bits_size * sizeof(cell)); }

  mark_bits(cell size, cell start)
      : size(size),
        start(start),
        bits_size(size / data_alignment / mark_bits_granularity),
        marked(std::make_unique<cell[]>(bits_size)),
        forwarding(std::make_unique<cell[]>(bits_size)) {
    clear_mark_bits();
    clear_forwarding();
  }

  ~mark_bits() = default;

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
    auto [word_index, word_shift] = bitmap_deref(address);
    return (bits[word_index] & ((cell)1 << word_shift)) != 0;
  }

  void set_bitmap_range(cell* bits, const cell address, const cell data_size) {
    auto [start_word, start_shift] = bitmap_deref(address);
    auto [end_word, end_shift] = bitmap_deref(address + data_size);

    cell start_mask = ((cell)1 << start_shift) - 1;
    cell end_mask = ((cell)1 << end_shift) - 1;

    if (start_word == end_word)
      bits[start_word] |= start_mask ^ end_mask;
    else {
      FACTOR_ASSERT(start_word < bits_size);
      bits[start_word] |= ~start_mask;

      std::fill(bits + start_word + 1, bits + end_word, (cell)-1);

      if (end_mask != 0) {
        FACTOR_ASSERT(end_word < bits_size);
        bits[end_word] |= end_mask;
      }
    }
  }

  bool marked_p(const cell address) { return bitmap_elt(marked.get(), address); }

  void set_marked_p(const cell address, const cell dsize) {
    set_bitmap_range(marked.get(), address, dsize);
  }

  // The eventual destination of a block after compaction is just the number
  // of marked blocks before it. Live blocks must be marked on entry.
  void compute_forwarding() {
    cell accum = 0;
    std::ranges::for_each(std::views::iota(cell{0}, bits_size), [&](cell index) {
      forwarding[index] = accum;
      accum += popcount(marked[index]);
    });
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
