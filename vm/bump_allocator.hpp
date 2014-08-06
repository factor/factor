namespace factor {

template <typename Block> struct bump_allocator {
  /* offset of 'here' and 'end' is hardcoded in compiler backends */
  cell here;
  cell start;
  cell end;
  cell size;

  bump_allocator(cell size, cell start)
      : here(start), start(start), end(start + size), size(size) {}

  bool contains_p(Block* block) { return ((cell)block - start) < size; }

  Block* allot(cell size) {
    cell h = here;
    here = h + align(size, data_alignment);
    return (Block*)h;
  }

  cell occupied_space() { return here - start; }

  cell free_space() { return end - here; }

  cell next_object_after(cell scan) {
    cell size = ((Block*)scan)->size();
    if (scan + size < here)
      return scan + size;
    else
      return 0;
  }

  cell first_object() {
    if (start != here)
      return start;
    else
      return 0;
  }

  void flush() {
    here = start;
#ifdef FACTOR_DEBUG
    /* In case of bugs, there may be bogus references pointing to the
       memory space after the gc has run. Filling it with a pattern
       makes accesses to such shadow data fail hard. */
    memset_cell((void*)start, 0xbaadbaad, size);
#endif
  }
};

}
