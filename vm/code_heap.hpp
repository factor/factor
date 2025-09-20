#include <memory>

namespace factor {

#if defined(WINDOWS) && defined(FACTOR_64)
constexpr cell seh_area_size = 1024;
#else
constexpr cell seh_area_size = 0;
#endif

struct code_heap {
  // The actual memory area
  std::unique_ptr<segment> seg;

  // Memory area reserved for safepoint guard page
  cell safepoint_page;

  // Memory area reserved for SEH. Only used on Windows
  char* seh_area;

  // Memory allocator
  std::unique_ptr<free_list_allocator<code_block>> allocator;

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
