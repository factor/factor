namespace factor {

inline cell align_page(cell a) { return align(a, static_cast<cell>(getpagesize())); }

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
  
  // Enable move operations
  segment(segment&& other) noexcept : start(other.start), size(other.size), end(other.end) {
    other.start = 0;
    other.size = 0;
    other.end = 0;
  }
  
  segment& operator=(segment&& other) noexcept {
    if (this != &other) {
      // Swap with other, then other will clean up our old resources
      std::swap(start, other.start);
      std::swap(size, other.size);
      std::swap(end, other.end);
    }
    return *this;
  }

  bool underflow_p(cell addr) {
    return addr >= (start - static_cast<cell>(getpagesize())) && addr < start;
  }

  bool overflow_p(cell addr) {
    return addr >= end && addr < (end + static_cast<cell>(getpagesize()));
  }

  bool in_segment_p(cell addr) {
    return addr >= start && addr < end;
  }

  void set_border_locked(bool locked) {
    int pagesize = getpagesize();
    cell lo = start - static_cast<cell>(pagesize);
    if (!set_memory_locked(lo, static_cast<cell>(pagesize), locked)) {
      fatal_error("Cannot (un)protect low guard page", lo);
    }

    cell hi = end;
    if (!set_memory_locked(hi, static_cast<cell>(pagesize), locked)) {
      fatal_error("Cannot (un)protect high guard page", hi);
    }
  }
};

}
