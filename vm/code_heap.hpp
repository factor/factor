namespace factor
{

struct code_heap {
	/* The actual memory area */
	segment *seg;

	/* Memory allocator */
	free_list_allocator<code_block> *allocator;

	/* Keys are blocks which need to be initialized by initialize_code_block().
	Values are literal tables. Literal table arrays are GC roots until the
	time the block is initialized, after which point they are discarded. */
	std::map<code_block *, cell> uninitialized_blocks;

	/* Code blocks which may reference objects in the nursery */
	std::set<code_block *> points_to_nursery;

	/* Code blocks which may reference objects in aging space or the nursery */
	std::set<code_block *> points_to_aging;

	explicit code_heap(cell size);
	~code_heap();
	void write_barrier(code_block *compiled);
	void clear_remembered_set();
	bool uninitialized_p(code_block *compiled);
	bool marked_p(code_block *compiled);
	void set_marked_p(code_block *compiled);
	void clear_mark_bits();
	void code_heap_free(code_block *compiled);
	void flush_icache();
};

struct code_heap_room {
	cell size;
	cell occupied_space;
	cell total_free;
	cell contiguous_free;
	cell free_block_count;
};

}
