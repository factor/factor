namespace factor {

#if defined(WINDOWS) && defined(FACTOR_ARM64)
const cell seh_area_size = 4096;
#elif defined(WINDOWS) && defined(FACTOR_64)
const cell seh_area_size = 1024;
#else
const cell seh_area_size = 0;
#endif

#if defined(__APPLE__) && defined(FACTOR_ARM64)

// W^X protection for the MAP_JIT code and callback heaps. On Apple Silicon a
// thread's JIT pages are either writable or executable, never both at once.
//
// We track the current per-thread mode in a thread-local so that only the
// outermost writable region performs the hardware flip. This lets GC -- which
// writes the code heap during compaction and pointer updates -- flip for
// itself, yet nest safely inside the compile paths, which must stay writable
// across an internal GC. It replaces the old scheme that flipped W^X on every
// single primitive dispatch (two register writes per primitive, almost always
// wasted) and per alien read.
//
// Invariant: a function needs a jit_writable_scope if and only if it writes
// the code or callback heap directly -- compiling, relocating, installing
// inline caches, or freeing blocks. Allocation alone does NOT need one: any GC
// it triggers flips for itself.
extern thread_local bool jit_thread_writable;

inline void jit_set_writable() {
  pthread_jit_write_protect_np(0);
  jit_thread_writable = true;
}

inline void jit_set_executable() {
  pthread_jit_write_protect_np(1);
  jit_thread_writable = false;
}

// Make the code heap writable for the lifetime of the scope, restoring the
// previous mode on exit. Re-entrant: only the outermost scope flips, so any
// nesting (e.g. a GC triggered inside a compile) is safe and flip-free.
struct jit_writable_scope {
  bool flipped;
  jit_writable_scope() : flipped(!jit_thread_writable) {
    if (flipped)
      jit_set_writable();
  }
  ~jit_writable_scope() {
    if (flipped)
      jit_set_executable();
  }
  jit_writable_scope(const jit_writable_scope&) = delete;
  jit_writable_scope& operator=(const jit_writable_scope&) = delete;
};

// Force the code heap executable when entering Factor code from C (the
// c-to-factor boundary), and after a non-local unwind whose abandoned C frames
// never ran their scopes' destructors (unwind_native_frames). Mirrors the Zig
// VM's ensureExecutable / resetForUnwind; there is no depth to reset because we
// track a single mode rather than a nesting count.
inline void jit_force_executable() {
  if (jit_thread_writable)
    jit_set_executable();
}

#else

struct jit_writable_scope {
  jit_writable_scope() {}
};
inline void jit_set_writable() {}
inline void jit_force_executable() {}

#endif

struct code_heap {
  // The actual memory area
  segment* seg;

  // Segment for the safepoint page, can't be executable on ARM64 MacOS
  segment* safepoint_seg;

  // Memory area reserved for safepoint guard page
  cell safepoint_page;

  // Memory area reserved for SEH. Only used on Windows
  char* seh_area;

  // Memory allocator
  free_list_allocator<code_block>* allocator;

  // For fast lookup of blocks from addresses.
  std::set<cell> all_blocks;


  // Code blocks are initialized in two steps in
  // primitive_modify_code_heap() because they might reference each
  // other. First they are all allocated and placed in this map with
  // their literal tables which are GC roots until the block is
  // initialized. Then they are all initialized by
  // initialize_code_block() which resolves relocations and updates
  // addresses. Uninitialized blocks instructions must not be visited
  // by GC.
  std::map<code_block*, cell> uninitialized_blocks;

  // Code blocks which may reference objects in the nursery
  std::set<code_block*> points_to_nursery;

  // Code blocks which may reference objects in aging space or the nursery
  std::set<code_block*> points_to_aging;

  explicit code_heap(cell size);
  ~code_heap();
  void write_barrier(code_block* compiled);
  void clear_remembered_set();
  bool uninitialized_p(code_block* compiled);
  void free(code_block* compiled);
  void flush_icache();
  void set_safepoint_guard(bool locked);
  void verify_all_blocks_set();
  void initialize_all_blocks_set();
  cell high_water_mark() { return allocator->size / 20; }

  void sweep();

  code_block* code_block_for_address(cell address);
  cell frame_predecessor(cell frame_top);

  bool safepoint_p(cell addr) {
    cell page_mask = ~(getpagesize() - 1);
    return (addr & page_mask) == safepoint_page;
  }
};

}
