namespace factor
{

static const cell free_list_count = 32;
static const cell block_size_increment = 16;

struct heap_free_list {
	free_heap_block *small_blocks[free_list_count];
	free_heap_block *large_blocks;
};

struct heap {
	bool secure_gc;
	segment *seg;
	heap_free_list free;
	mark_bits<heap_block,block_size_increment> *state;

	explicit heap(bool secure_gc_, cell size, bool executable_p);
	~heap();
	
	inline heap_block *first_block()
	{
		return (heap_block *)seg->start;
	}
	
	inline heap_block *last_block()
	{
		return (heap_block *)seg->end;
	}

	void clear_free_list();
	void add_to_free_list(free_heap_block *block);
	void build_free_list(cell size);
	void assert_free_block(free_heap_block *block);
	free_heap_block *find_free_block(cell size);
	free_heap_block *split_free_block(free_heap_block *block, cell size);
	heap_block *heap_allot(cell size);
	void heap_free(heap_block *block);
	void mark_block(heap_block *block);
	void heap_usage(cell *used, cell *total_free, cell *max_free);
	cell heap_size();
	void compact_heap();

	template<typename Iterator> void sweep_heap(Iterator &iter);
	template<typename Iterator> void compact_heap(Iterator &iter);

	template<typename Iterator> void iterate_heap(Iterator &iter)
	{
		heap_block *scan = first_block();
		heap_block *end = last_block();

		while(scan != end)
		{
			heap_block *next = scan->next();
			if(!scan->free_p()) iter(scan,scan->size());
			scan = next;
		}
	}
};

/* After code GC, all live code blocks are marked, so any
which are not marked can be reclaimed. */
template<typename Iterator> void heap::sweep_heap(Iterator &iter)
{
	this->clear_free_list();

	heap_block *prev = NULL;
	heap_block *scan = this->first_block();
	heap_block *end = this->last_block();

	while(scan != end)
	{
		if(scan->free_p())
		{
			if(prev && prev->free_p())
				prev->set_size(prev->size() + scan->size());
			else
				prev = scan;
		}
		else if(this->state->is_marked_p(scan))
		{
			if(prev && prev->free_p())
				this->add_to_free_list((free_heap_block *)prev);
			prev = scan;
			iter(scan,scan->size());
		}
		else
		{
			if(secure_gc)
				memset(scan + 1,0,scan->size() - sizeof(heap_block));

			if(prev && prev->free_p())
			{
				free_heap_block *free_prev = (free_heap_block *)prev;
				free_prev->set_size(free_prev->size() + scan->size());
			}
			else
			{
				scan->set_free();
				prev = scan;
			}
		}

		scan = scan->next();
	}

	if(prev && prev->free_p())
		this->add_to_free_list((free_heap_block *)prev);
}

/* The forwarding map must be computed first by calling
state->compute_forwarding(). */
template<typename Iterator> void heap::compact_heap(Iterator &iter)
{
	heap_compacter<heap_block,block_size_increment,Iterator> compacter(state,first_block(),iter);
	this->iterate_heap(compacter);

	/* Now update the free list; there will be a single free block at
	the end */
	this->build_free_list((cell)compacter.address - this->seg->start);
}

}
