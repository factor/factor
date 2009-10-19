#include "master.hpp"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get mark/sweep/compact GC. */

namespace factor
{

void heap::clear_free_list()
{
	memset(&free,0,sizeof(heap_free_list));
}

heap::heap(bool secure_gc_, cell size, bool executable_p) : secure_gc(secure_gc_)
{
	if(size > (1L << (sizeof(cell) * 8 - 6))) fatal_error("Heap too large",size);
	seg = new segment(align_page(size),executable_p);
	if(!seg) fatal_error("Out of memory in heap allocator",size);
	state = new mark_bits<heap_block,block_size_increment>(seg->start,size);
	clear_free_list();
}

heap::~heap()
{
	delete seg;
	seg = NULL;
	delete state;
	state = NULL;
}

void heap::add_to_free_list(free_heap_block *block)
{
	if(block->size() < free_list_count * block_size_increment)
	{
		int index = block->size() / block_size_increment;
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
void heap::build_free_list(cell size)
{
	clear_free_list();
	free_heap_block *end = (free_heap_block *)(seg->start + size);
	end->set_type(FREE_BLOCK_TYPE);
	end->set_size(seg->end - (cell)end);
	add_to_free_list(end);
}

void heap::assert_free_block(free_heap_block *block)
{
	if(block->type() != FREE_BLOCK_TYPE)
		critical_error("Invalid block in free list",(cell)block);
}

free_heap_block *heap::find_free_block(cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_size_increment)
	{
		int index = attempt / block_size_increment;
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

free_heap_block *heap::split_free_block(free_heap_block *block, cell size)
{
	if(block->size() != size )
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->set_type(FREE_BLOCK_TYPE);
		split->set_size(block->size() - size);
		split->next_free = block->next_free;
		block->set_size(size);
		add_to_free_list(split);
	}

	return block;
}

/* Allocate a block of memory from the mark and sweep GC heap */
heap_block *heap::heap_allot(cell size, cell type)
{
	size = (size + block_size_increment - 1) & ~(block_size_increment - 1);

	free_heap_block *block = find_free_block(size);
	if(block)
	{
		block = split_free_block(block,size);
		block->set_type(type);
		return block;
	}
	else
		return NULL;
}

/* Deallocates a block manually */
void heap::heap_free(heap_block *block)
{
	block->set_type(FREE_BLOCK_TYPE);
	add_to_free_list((free_heap_block *)block);
}

void heap::mark_block(heap_block *block)
{
	state->set_marked_p(block);
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
void heap::heap_usage(cell *used, cell *total_free, cell *max_free)
{
	*used = 0;
	*total_free = 0;
	*max_free = 0;

	heap_block *scan = first_block();
	heap_block *end = last_block();

	while(scan != end)
	{
		cell size = scan->size();

		if(scan->type() == FREE_BLOCK_TYPE)
		{
			*total_free += size;
			if(size > *max_free)
				*max_free = size;
		}
		else
			*used += size;

		scan = scan->next();
	}
}

/* The size of the heap after compaction */
cell heap::heap_size()
{
	heap_block *scan = first_block();
	heap_block *end = last_block();
	
	while(scan != end)
	{
		if(scan->type() == FREE_BLOCK_TYPE) break;
		else scan = scan->next();
	}

	assert(scan->type() == FREE_BLOCK_TYPE);
	assert((cell)scan + scan->size() == seg->end);

	return (cell)scan - (cell)first_block();
}

void heap::compact_heap()
{
	forwarding.clear();
	state->compute_forwarding();

	heap_block *scan = first_block();
	heap_block *end = last_block();

	char *address = (char *)scan;

	/* Slide blocks up while building the forwarding hashtable. */
	while(scan != end)
	{
		heap_block *next = scan->next();
 
		if(state->is_marked_p(scan))
		{
			cell size = scan->size();
			memmove(address,scan,size);
			forwarding[scan] = address;
			address += size;
		}

		scan = next;
	}

	/* Now update the free list; there will be a single free block at
	the end */
	build_free_list((cell)address - seg->start);
}

heap_block *heap::free_allocated(heap_block *prev, heap_block *scan)
{
	if(secure_gc)
		memset(scan + 1,0,scan->size() - sizeof(heap_block));

	if(prev && prev->type() == FREE_BLOCK_TYPE)
	{
		prev->set_size(prev->size() + scan->size());
		return prev;
	}
	else
	{
		scan->set_type(FREE_BLOCK_TYPE);
		return scan;
	}
}

}
