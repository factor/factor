namespace factor
{

struct code_heap : heap {
	/* Set of blocks which need full relocation. */
	unordered_set<code_block *> needs_fixup;
	
	/* Maps code blocks to the youngest generation containing
	one of their literals. If this is tenured (0), the code block
	is not part of the remembered set. */
	unordered_map<code_block *, cell> remembered_set;

	/* Minimum value in the above map. */
	cell youngest_referenced_generation;

	explicit code_heap(bool secure_gc, cell size);
	void write_barrier(code_block *compiled);
	bool needs_fixup_p(code_block *compiled);
	void code_heap_free(code_block *compiled);
};

}
