namespace factor {

inline cell align_page(cell a) { return align(a, getpagesize()); }

bool set_memory_locked(cell base, cell size, bool locked);

// segments set up guard pages to check for under/overflow.
// size must be a multiple of the page size
struct segment {
  // Common prefix exposed by the Factor vm vocabulary and the Zig VM.
  cell start;
  cell size;
  cell end;
  cell low_guard_size;

  segment(cell size, bool executable_p, cell low_guard_size = 0);
  ~segment();

  bool underflow_p(cell addr) {
    return addr >= (start - low_guard_size) && addr < start;
  }

  bool overflow_p(cell addr) {
    return addr >= end && addr < (end + getpagesize());
  }

  bool in_segment_p(cell addr) {
    return addr >= start && addr < end;
  }

  void set_border_locked(bool locked) {
    int pagesize = getpagesize();
    cell lo = start - low_guard_size;
    if (!set_memory_locked(lo, low_guard_size, locked)) {
      fatal_error("Cannot (un)protect low guard page", lo);
    }

    cell hi = end;
    if (!set_memory_locked(hi, pagesize, locked)) {
      fatal_error("Cannot (un)protect high guard page", hi);
    }
  }
};

}
