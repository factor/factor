namespace factor {

struct bump_allocator {
  // offset of 'here' and 'end' is hardcoded in compiler backends
  cell here;
  cell start;
  cell end;
  cell size;

  bump_allocator(cell size, cell start)
      : here(start), start(start), end(start + size), size(size) {}

  bool contains_p(object* obj) {
    return (cell)obj >= start && (cell)obj < end;
  }

  object* allot(cell data_size) {
    cell h = here;
    here = h + align(data_size, data_alignment);
    return (object*)h;
  }

  cell occupied_space() { return here - start; }

  cell free_space() { return end - here; }

  void flush() {
    here = start;
#ifdef FACTOR_DEBUG
    // In case of bugs, there may be bogus references pointing to the
    // memory space after the gc has run. Filling it with a pattern
    // makes accesses to such shadow data fail hard.
    memset_cell((void*)start, 0xbaadbaad, size);
#endif
  }
};

}
