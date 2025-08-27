namespace factor {

// The compiled code heap is structured into blocks.
struct code_block {
  // header format (bits indexed with least significant as zero):
  // bit   0  : free?
  // bits  1-2: type (as a code_block_type)
  // if not free:
  //   bits  3-23: code size / 8
  //   bits 24-31: stack frame size / 16
  // if free:
  //   bits  3-end: code size / 8
  cell header;
  cell owner;      // tagged pointer to word, quotation or f
  cell parameters; // tagged pointer to array or f
  cell relocation; // tagged pointer to byte-array or f

  bool free_p() const { return (header & 1) == 1; }

  code_block_type type() const {
    return static_cast<code_block_type>((header >> 1) & 0x3);
  }

  void set_type(code_block_type type) {
    header = ((header & ~0x7) | (static_cast<cell>(type) << 1));
  }

  bool pic_p() const { return type() == CODE_BLOCK_PIC; }

  cell size() const {
    cell size;
    if (free_p())
      size = header & ~static_cast<cell>(7);
    else
      size = header & 0xFFFFF8;
    FACTOR_ASSERT(size > 0);
    return size;
  }

  cell stack_frame_size() const {
    if (free_p())
      return 0;
    return (header >> 20) & 0xFF0;
  }

  cell stack_frame_size_for_address(cell addr) const {
    cell natural_frame_size = stack_frame_size();
    // The first instruction in a code block is the prolog safepoint,
    // and a leaf procedure code block will record a frame size of zero.
    // If we're seeing a stack frame in either of these cases, it's a
    // fake "leaf frame" set up by the signal handler.
    if (natural_frame_size == 0 || addr == entry_point())
      return LEAF_FRAME_SIZE;
    return natural_frame_size;
  }

  void set_stack_frame_size(cell frame_size) {
    FACTOR_ASSERT(size() < 0xFFFFFF);
    FACTOR_ASSERT(!free_p());
    FACTOR_ASSERT(frame_size % 16 == 0);
    FACTOR_ASSERT(frame_size <= 0xFF0);
    header = (header & 0xFFFFFF) | (frame_size << 20);
  }

  template <typename Fixup> cell size(Fixup fixup) const { (void)fixup; return size(); }

  cell entry_point() const { return reinterpret_cast<cell>(this + 1); }

  // GC info is stored at the end of the block
  gc_info* block_gc_info() const {
    const void* ptr = reinterpret_cast<const uint8_t*>(this) + size() - sizeof(gc_info);
    // Ensure proper alignment for gc_info
    return static_cast<gc_info*>(__builtin_assume_aligned(const_cast<void*>(ptr), alignof(gc_info)));
  }

  void flush_icache() { factor::flush_icache(reinterpret_cast<cell>(this), size()); }

  template <typename Iterator> void each_instruction_operand(Iterator& iter) {
    if (!to_boolean(relocation))
      return;

    byte_array* rels = untag<byte_array>(relocation);

    cell index = 0;
    cell length = untag_fixnum(rels->capacity) / sizeof(relocation_entry);

    for (cell i = 0; i < length; i++) {
      relocation_entry rel = rels->data<relocation_entry>()[i];
      iter(instruction_operand(rel, this, index));
      index += rel.number_of_parameters();
    }
  }

  cell offset(cell addr) const { return addr - entry_point(); }

  cell address_for_offset(cell offset) const {
    return entry_point() + offset;
  }

  cell scan(factor_vm* vm, cell addr) const;
  cell owner_quot() const;
};

VM_C_API void undefined_symbol(void);

inline code_block* word::code() const {
  FACTOR_ASSERT(entry_point != 0);
  return reinterpret_cast<code_block*>(entry_point) - 1;
}

inline code_block* quotation::code() const {
  FACTOR_ASSERT(entry_point != 0);
  return reinterpret_cast<code_block*>(entry_point) - 1;
}

}
