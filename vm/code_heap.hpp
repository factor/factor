namespace factor
{

struct code_heap {
	/* The actual memory area */
	segment *seg;

	/* Memory allocator */
	free_list_allocator<code_block> *allocator;

	/* Set of blocks which need full relocation. */
	std::set<code_block *> needs_fixup;

	/* Code blocks which may reference objects in the nursery */
	std::set<code_block *> points_to_nursery;

	/* Code blocks which may reference objects in aging space or the nursery */
	std::set<code_block *> points_to_aging;

	explicit code_heap(cell size);
	~code_heap();
	void write_barrier(code_block *compiled);
	void clear_remembered_set();
	bool needs_fixup_p(code_block *compiled);
	bool marked_p(code_block *compiled);
	void set_marked_p(code_block *compiled);
	void clear_mark_bits();
	void code_heap_free(code_block *compiled);
};

}
