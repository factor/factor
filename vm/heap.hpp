namespace factor
{

static const cell free_list_count = 16;
static const cell block_size_increment = 32;

struct heap_free_list {
	free_heap_block *small_blocks[free_list_count];
	free_heap_block *large_blocks;
};

struct heap {
	factor_vm *myvm;
	segment *seg;
	heap_free_list free;

	explicit heap(factor_vm *myvm, cell size);

	inline heap_block *next_block(heap_block *block)
	{
		cell next = ((cell)block + block->size);
		if(next == seg->end)
			return NULL;
		else
			return (heap_block *)next;
	}
	
	inline heap_block *first_block()
	{
		return (heap_block *)seg->start;
	}
	
	inline heap_block *last_block()
	{
		return (heap_block *)seg->end;
	}

	void clear_free_list();
	void new_heap(cell size);
	void add_to_free_list(free_heap_block *block);
	void build_free_list(cell size);
	void assert_free_block(free_heap_block *block);
	free_heap_block *find_free_block(cell size);
	free_heap_block *split_free_block(free_heap_block *block, cell size);
	heap_block *heap_allot(cell size);
	void heap_free(heap_block *block);
	void mark_block(heap_block *block);
	void unmark_marked();
	void heap_usage(cell *used, cell *total_free, cell *max_free);
	cell heap_size();
	cell compute_heap_forwarding(unordered_map<heap_block *,char *> &forwarding);
	void compact_heap(unordered_map<heap_block *,char *> &forwarding);

	heap_block *free_allocated(heap_block *prev, heap_block *scan);

	/* After code GC, all referenced code blocks have status set to B_MARKED, so any
	which are allocated and not marked can be reclaimed. */
	template<typename Iterator> void free_unmarked(Iterator &iter)
	{
		clear_free_list();
	
		heap_block *prev = NULL;
		heap_block *scan = first_block();
	
		while(scan)
		{
			switch(scan->status)
			{
			case B_ALLOCATED:
				prev = free_allocated(prev,scan);
				break;
			case B_FREE:
				if(prev && prev->status == B_FREE)
					prev->size += scan->size;
				else
					prev = scan;
				break;
			case B_MARKED:
				if(prev && prev->status == B_FREE)
					add_to_free_list((free_heap_block *)prev);
				scan->status = B_ALLOCATED;
				prev = scan;
				iter(scan);
				break;
			}
	
			scan = next_block(scan);
		}
	
		if(prev && prev->status == B_FREE)
			add_to_free_list((free_heap_block *)prev);
	}
};

}
