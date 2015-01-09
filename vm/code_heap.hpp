namespace factor {

#if defined(WINDOWS) && defined(FACTOR_64)
const cell seh_area_size = 1024;
#else
const cell seh_area_size = 0;
#endif

struct code_heap {
  /* The actual memory area */
  segment* seg;

  /* Memory area reserved for safepoint guard page */
  void* safepoint_page;

  /* Memory area reserved for SEH. Only used on Windows */
  char* seh_area;

  /* Memory allocator */
  free_list_allocator<code_block>* allocator;

  std::set<cell> all_blocks;

  /* Keys are blocks which need to be initialized by initialize_code_block().
     Values are literal tables. Literal table arrays are GC roots until the
     time the block is initialized, after which point they are discarded. */
  std::map<code_block*, cell> uninitialized_blocks;

  /* Code blocks which may reference objects in the nursery */
  std::set<code_block*> points_to_nursery;

  /* Code blocks which may reference objects in aging space or the nursery */
  std::set<code_block*> points_to_aging;

  explicit code_heap(cell size);
  ~code_heap();
  void write_barrier(code_block* compiled);
  void clear_remembered_set();
  bool uninitialized_p(code_block* compiled);
  bool marked_p(code_block* compiled);
  void set_marked_p(code_block* compiled);
  void free(code_block* compiled);
  void flush_icache();
  void guard_safepoint();
  void unguard_safepoint();
  void verify_all_blocks_set();
  void initialize_all_blocks_set();

  void sweep();

  code_block* code_block_for_address(cell address);

  bool safepoint_p(cell addr) {
    cell page_mask = ~(getpagesize() - 1);
    return (addr & page_mask) == (cell)safepoint_page;
  }
};

}
