namespace factor
{

struct code_heap_layout {
	cell block_size(heap_block *block)
	{
		return block->size();
	}
};

struct code_heap : heap<heap_block,code_heap_layout> {
	/* Set of blocks which need full relocation. */
	std::set<code_block *> needs_fixup;

	/* Code blocks which may reference objects in the nursery */
	std::set<code_block *> points_to_nursery;

	/* Code blocks which may reference objects in aging space or the nursery */
	std::set<code_block *> points_to_aging;

	explicit code_heap(bool secure_gc, cell size);
	void write_barrier(code_block *compiled);
	void clear_remembered_set();
	bool needs_fixup_p(code_block *compiled);
	void code_heap_free(code_block *compiled);
	code_block *forward_code_block(code_block *compiled);
};

}
