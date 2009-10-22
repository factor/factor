namespace factor
{

static const cell free_list_count = 32;

struct free_list {
	free_heap_block *small_blocks[free_list_count];
	free_heap_block *large_blocks;
};

template<typename Block> struct free_list_allocator {
	cell size;
	cell start;
	cell end;
	free_list free_blocks;
	mark_bits<Block> state;

	explicit free_list_allocator(cell size, cell start);
	bool contains_p(Block *block);
	Block *first_block();
	Block *last_block();
	Block *next_block_after(Block *block);
	void clear_free_list();
	void add_to_free_list(free_heap_block *block);
	void build_free_list(cell size);
	void assert_free_block(free_heap_block *block);
	free_heap_block *find_free_block(cell size);
	free_heap_block *split_free_block(free_heap_block *block, cell size);
	Block *allot(cell size);
	void free(Block *block);
	void usage(cell *used, cell *total_free, cell *max_free);
	cell occupied();
	void sweep();
	template<typename Iterator> void sweep(Iterator &iter);
	template<typename Iterator> void compact(Iterator &iter);
	template<typename Iterator> void iterate(Iterator &iter);
};

template<typename Block>
free_list_allocator<Block>::free_list_allocator(cell size_, cell start_) :
	size(size_), start(start_), end(start_ + size_), state(mark_bits<Block>(size_,start_))
{
	clear_free_list();
}

template<typename Block> void free_list_allocator<Block>::clear_free_list()
{
	memset(&free_blocks,0,sizeof(free_list));
}

template<typename Block> bool free_list_allocator<Block>::contains_p(Block *block)
{
	return ((cell)block - start) < size;
}

template<typename Block> Block *free_list_allocator<Block>::first_block()
{
	return (Block *)start;
}

template<typename Block> Block *free_list_allocator<Block>::last_block()
{
	return (Block *)end;
}

template<typename Block> Block *free_list_allocator<Block>::next_block_after(Block *block)
{
	return (Block *)((cell)block + block->size());
}

template<typename Block> void free_list_allocator<Block>::add_to_free_list(free_heap_block *block)
{
	if(block->size() < free_list_count * block_granularity)
	{
		int index = block->size() / block_granularity;
		block->next_free = free_blocks.small_blocks[index];
		free_blocks.small_blocks[index] = block;
	}
	else
	{
		block->next_free = free_blocks.large_blocks;
		free_blocks.large_blocks = block;
	}
}

/* Called after reading the heap from the image file, and after heap compaction.
Makes a free list consisting of one free block, at the very end. */
template<typename Block> void free_list_allocator<Block>::build_free_list(cell size)
{
	clear_free_list();
	if(size != this->size)
	{
		free_heap_block *last_block = (free_heap_block *)(start + size);
		last_block->make_free(end - (cell)last_block);
		add_to_free_list(last_block);
	}
}

template<typename Block> void free_list_allocator<Block>::assert_free_block(free_heap_block *block)
{
#ifdef FACTOR_DEBUG
	assert(block->free_p());
#endif
}

template<typename Block> free_heap_block *free_list_allocator<Block>::find_free_block(cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_granularity)
	{
		int index = attempt / block_granularity;
		free_heap_block *block = free_blocks.small_blocks[index];
		if(block)
		{
			assert_free_block(block);
			free_blocks.small_blocks[index] = block->next_free;
			return block;
		}

		attempt *= 2;
	}

	free_heap_block *prev = NULL;
	free_heap_block *block = free_blocks.large_blocks;

	while(block)
	{
		assert_free_block(block);
		if(block->size() >= size)
		{
			if(prev)
				prev->next_free = block->next_free;
			else
				free_blocks.large_blocks = block->next_free;
			return block;
		}

		prev = block;
		block = block->next_free;
	}

	return NULL;
}

template<typename Block> free_heap_block *free_list_allocator<Block>::split_free_block(free_heap_block *block, cell size)
{
	if(block->size() != size)
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->make_free(block->size() - size);
		split->next_free = block->next_free;
		block->make_free(size);
		add_to_free_list(split);
	}

	return block;
}

template<typename Block> Block *free_list_allocator<Block>::allot(cell size)
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

template<typename Block> void free_list_allocator<Block>::free(Block *block)
{
	free_heap_block *free_block = (free_heap_block *)block;
	free_block->make_free(block->size());
	add_to_free_list(free_block);
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
template<typename Block> void free_list_allocator<Block>::usage(cell *used, cell *total_free, cell *max_free)
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
template<typename Block> cell free_list_allocator<Block>::occupied()
{
	Block *scan = first_block();
	Block *last = last_block();

	while(scan != last)
	{
		if(scan->free_p()) break;
		else scan = next_block_after(scan);
	}

	if(scan != last)
	{
		free_heap_block *free_block = (free_heap_block *)scan;
		assert(free_block->free_p());
		assert((cell)scan + free_block->size() == end);

		return (cell)scan - (cell)first_block();
	}
	else
		return size;
}

template<typename Block>
void free_list_allocator<Block>::sweep()
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
		else if(this->state.marked_p(scan))
		{
			if(prev && prev->free_p())
				this->add_to_free_list((free_heap_block *)prev);
			prev = scan;
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
				free_heap_block *free_block = (free_heap_block *)scan;
				free_block->make_free(size);
				prev = scan;
			}
		}

		scan = (Block *)((cell)scan + size);
	}

	if(prev && prev->free_p())
		this->add_to_free_list((free_heap_block *)prev);
}

template<typename Block>
template<typename Iterator>
void free_list_allocator<Block>::sweep(Iterator &iter)
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
		else if(this->state.marked_p(scan))
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
				free_heap_block *free_block = (free_heap_block *)scan;
				free_block->make_free(size);
				prev = scan;
			}
		}

		scan = (Block *)((cell)scan + size);
	}

	if(prev && prev->free_p())
		this->add_to_free_list((free_heap_block *)prev);
}

/* The forwarding map must be computed first by calling
state.compute_forwarding(). */
template<typename Block>
template<typename Iterator>
void free_list_allocator<Block>::compact(Iterator &iter)
{
	heap_compactor<Block,Iterator> compactor(&state,first_block(),iter);
	this->iterate(compactor);

	/* Now update the free list; there will be a single free block at
	the end */
	this->build_free_list((cell)compactor.address - this->start);
}

template<typename Block>
template<typename Iterator>
void free_list_allocator<Block>::iterate(Iterator &iter)
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

}
