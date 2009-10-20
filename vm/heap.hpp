namespace factor
{

static const cell free_list_count = 32;

struct heap_free_list {
	free_heap_block *small_blocks[free_list_count];
	free_heap_block *large_blocks;
};

template<typename Block> struct heap {
	bool secure_gc;
	segment *seg;
	heap_free_list free;
	mark_bits<Block> *state;

	explicit heap(bool secure_gc_, cell size, bool executable_p);
	~heap();

	inline Block *first_block()
	{
		return (Block *)seg->start;
	}

	inline Block *last_block()
	{
		return (Block *)seg->end;
	}

	Block *next_block_after(heap_block *block)
	{
		return (Block *)((cell)block + block->size());
	}

	void clear_free_list();
	void add_to_free_list(free_heap_block *block);
	void build_free_list(cell size);
	void assert_free_block(free_heap_block *block);
	free_heap_block *find_free_block(cell size);
	free_heap_block *split_free_block(free_heap_block *block, cell size);
	Block *heap_allot(cell size);
	void heap_free(Block *block);
	void mark_block(Block *block);
	void heap_usage(cell *used, cell *total_free, cell *max_free);
	cell heap_size();

	template<typename Iterator> void sweep_heap(Iterator &iter);
	template<typename Iterator> void compact_heap(Iterator &iter);

	template<typename Iterator> void iterate_heap(Iterator &iter)
	{
		Block *scan = first_block();
		Block *end = last_block();

		while(scan != end)
		{
			cell size = scan->size();
			Block *next = (Block *)((cell)scan + size);
			if(!scan->free_p()) iter(scan,size);
			scan = next;
		}
	}
};

template<typename Block> void heap<Block>::clear_free_list()
{
	memset(&free,0,sizeof(heap_free_list));
}

template<typename Block> heap<Block>::heap(bool secure_gc_, cell size, bool executable_p) : secure_gc(secure_gc_)
{
	if(size > (1L << (sizeof(cell) * 8 - 6))) fatal_error("Heap too large",size);
	seg = new segment(align_page(size),executable_p);
	if(!seg) fatal_error("Out of memory in heap allocator",size);
	state = new mark_bits<Block>(seg->start,size);
	clear_free_list();
}

template<typename Block> heap<Block>::~heap()
{
	delete seg;
	seg = NULL;
	delete state;
	state = NULL;
}

template<typename Block> void heap<Block>::add_to_free_list(free_heap_block *block)
{
	if(block->size() < free_list_count * block_granularity)
	{
		int index = block->size() / block_granularity;
		block->next_free = free.small_blocks[index];
		free.small_blocks[index] = block;
	}
	else
	{
		block->next_free = free.large_blocks;
		free.large_blocks = block;
	}
}

/* Called after reading the code heap from the image file, and after code heap
compaction. Makes a free list consisting of one free block, at the very end. */
template<typename Block> void heap<Block>::build_free_list(cell size)
{
	clear_free_list();
	free_heap_block *end = (free_heap_block *)(seg->start + size);
	end->set_free();
	end->set_size(seg->end - (cell)end);
	add_to_free_list(end);
}

template<typename Block> void heap<Block>::assert_free_block(free_heap_block *block)
{
#ifdef FACTOR_DEBUG
	assert(block->free_p());
#endif
}

template<typename Block> free_heap_block *heap<Block>::find_free_block(cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_granularity)
	{
		int index = attempt / block_granularity;
		free_heap_block *block = free.small_blocks[index];
		if(block)
		{
			assert_free_block(block);
			free.small_blocks[index] = block->next_free;
			return block;
		}

		attempt *= 2;
	}

	free_heap_block *prev = NULL;
	free_heap_block *block = free.large_blocks;

	while(block)
	{
		assert_free_block(block);
		if(block->size() >= size)
		{
			if(prev)
				prev->next_free = block->next_free;
			else
				free.large_blocks = block->next_free;
			return block;
		}

		prev = block;
		block = block->next_free;
	}

	return NULL;
}

template<typename Block> free_heap_block *heap<Block>::split_free_block(free_heap_block *block, cell size)
{
	if(block->size() != size)
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->set_free();
		split->set_size(block->size() - size);
		split->next_free = block->next_free;
		block->set_size(size);
		add_to_free_list(split);
	}

	return block;
}

template<typename Block> Block *heap<Block>::heap_allot(cell size)
{
	size = align(size,block_granularity);

	free_heap_block *block = find_free_block(size);
	if(block)
	{
		block = split_free_block(block,size);
		return (Block *)block;
	}
	else
		return NULL;
}

template<typename Block> void heap<Block>::heap_free(Block *block)
{
	free_heap_block *free_block = (free_heap_block *)block;
	free_block->set_free();
	add_to_free_list(free_block);
}

template<typename Block> void heap<Block>::mark_block(Block *block)
{
	state->set_marked_p(block);
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
template<typename Block> void heap<Block>::heap_usage(cell *used, cell *total_free, cell *max_free)
{
	*used = 0;
	*total_free = 0;
	*max_free = 0;

	Block *scan = first_block();
	Block *end = last_block();

	while(scan != end)
	{
		cell size = scan->size();

		if(scan->free_p())
		{
			*total_free += size;
			if(size > *max_free)
				*max_free = size;
		}
		else
			*used += size;

		scan = next_block_after(scan);
	}
}

/* The size of the heap after compaction */
template<typename Block> cell heap<Block>::heap_size()
{
	Block *scan = first_block();
	Block *end = last_block();

	while(scan != end)
	{
		if(scan->free_p()) break;
		else scan = next_block_after(scan);
	}

	if(scan != end)
	{
		free_heap_block *free_block = (free_heap_block *)scan;
		assert(free_block->free_p());
		assert((cell)scan + free_block->size() == seg->end);

		return (cell)scan - (cell)first_block();
	}
	else
		return seg->size;
}

/* After code GC, all live code blocks are marked, so any
which are not marked can be reclaimed. */
template<typename Block>
template<typename Iterator>
void heap<Block>::sweep_heap(Iterator &iter)
{
	this->clear_free_list();

	Block *prev = NULL;
	Block *scan = this->first_block();
	Block *end = this->last_block();

	while(scan != end)
	{
		cell size = scan->size();

		if(scan->free_p())
		{
			if(prev && prev->free_p())
			{
				free_heap_block *free_prev = (free_heap_block *)prev;
				free_prev->set_size(free_prev->size() + size);
			}
			else
				prev = scan;
		}
		else if(this->state->is_marked_p(scan))
		{
			if(prev && prev->free_p())
				this->add_to_free_list((free_heap_block *)prev);
			prev = scan;
			iter(scan,size);
		}
		else
		{
			if(prev && prev->free_p())
			{
				free_heap_block *free_prev = (free_heap_block *)prev;
				free_prev->set_size(free_prev->size() + size);
			}
			else
			{
				scan->set_free();
				prev = scan;
			}
		}

		scan = (Block *)((cell)scan + size);
	}

	if(prev && prev->free_p())
		this->add_to_free_list((free_heap_block *)prev);
}

/* The forwarding map must be computed first by calling
state->compute_forwarding(). */
template<typename Block>
template<typename Iterator>
void heap<Block>::compact_heap(Iterator &iter)
{
	heap_compactor<Block,Iterator> compactor(state,first_block(),iter);
	this->iterate_heap(compactor);

	/* Now update the free list; there will be a single free block at
	the end */
	this->build_free_list((cell)compactor.address - this->seg->start);
}

}
