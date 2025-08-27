namespace factor {

inline cell align_page(cell a) { return align(a, getpagesize()); }

bool set_memory_locked(cell base, cell size, bool locked);

// segments set up guard pages to check for under/overflow.
// size must be a multiple of the page size
struct segment {
  cell start;
  cell size;
  cell end;

  segment(cell size, bool executable_p);
  ~segment();

  // Disable copy operations to prevent double-munmap
  segment(const segment&) = delete;
  segment& operator=(const segment&) = delete;
  
  // Move operations could be implemented if needed
  segment(segment&&) = delete;
  segment& operator=(segment&&) = delete;

  bool underflow_p(cell addr) {
    return addr >= (start - getpagesize()) && addr < start;
  }

  bool overflow_p(cell addr) {
    return addr >= end && addr < (end + getpagesize());
  }

  bool in_segment_p(cell addr) {
    return addr >= start && addr < end;
  }

  void set_border_locked(bool locked) {
    int pagesize = getpagesize();
    cell lo = start - pagesize;
    if (!set_memory_locked(lo, pagesize, locked)) {
      fatal_error("Cannot (un)protect low guard page", lo);
    }

    cell hi = end;
    if (!set_memory_locked(hi, pagesize, locked)) {
      fatal_error("Cannot (un)protect high guard page", hi);
    }
  }
};

}
