namespace factor {

#if defined(FACTOR_WITH_ADDRESS_SANITIZER)
static const int segment_guard_pages = 16;
#else
static const int segment_guard_pages = 1;
#endif

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
    cell guard_size = (cell)segment_guard_pages * pagesize;
    cell lo = start - guard_size;
    if (!set_memory_locked(lo, guard_size, locked)) {
      fatal_error("Cannot (un)protect low guard page", lo);
    }

    cell hi = end;
    if (!set_memory_locked(hi, guard_size, locked)) {
      fatal_error("Cannot (un)protect high guard page", hi);
    }
  }
};

}
