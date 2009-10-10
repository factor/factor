#include "master.hpp"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get mark/sweep/compact GC. */

namespace factor
{

void heap::clear_free_list()
{
	memset(&free,0,sizeof(heap_free_list));
}

heap::heap(bool secure_gc_, cell size) : secure_gc(secure_gc_)
{
	if(size > (1L << (sizeof(cell) * 8 - 6))) fatal_error("Heap too large",size);
	seg = new segment(align_page(size));
	if(!seg) fatal_error("Out of memory in heap allocator",size);
	clear_free_list();
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

/* Called after reading the code heap from the image file, and after code GC.

In the former case, we must add a large free block from compiling.base + size to
compiling.limit. */
void heap::build_free_list(cell size)
{
	heap_block *prev = NULL;

	clear_free_list();

	size = (size + block_size_increment - 1) & ~(block_size_increment - 1);

	heap_block *scan = first_block();
	free_heap_block *end = (free_heap_block *)(seg->start + size);

	/* Add all free blocks to the free list */
	while(scan && scan < (heap_block *)end)
	{
		if(scan->type() == FREE_BLOCK_TYPE)
			add_to_free_list((free_heap_block *)scan);

		prev = scan;
		scan = next_block(scan);
	}

	/* If there is room at the end of the heap, add a free block. This
	branch is only taken after loading a new image, not after code GC */
	if((cell)(end + 1) <= seg->end)
	{
		end->set_marked_p(false);
		end->set_type(FREE_BLOCK_TYPE);
		end->set_size(seg->end - (cell)end);

		/* add final free block */
		add_to_free_list(end);
	}
	/* This branch is taken if the newly loaded image fits exactly, or
	after code GC */
	else
	{
		/* even if there's no room at the end of the heap for a new
		free block, we might have to jigger it up by a few bytes in
		case prev + prev->size */
		if(prev) prev->set_size(seg->end - (cell)prev);
	}

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
		block->set_marked_p(false);
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
	block->set_marked_p(true);
}

void heap::clear_mark_bits()
{
	heap_block *scan = first_block();

	while(scan)
	{
		scan->set_marked_p(false);
		scan = next_block(scan);
	}
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
void heap::heap_usage(cell *used, cell *total_free, cell *max_free)
{
	*used = 0;
	*total_free = 0;
	*max_free = 0;

	heap_block *scan = first_block();

	while(scan)
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

		scan = next_block(scan);
	}
}

/* The size of the heap, not including the last block if it's free */
cell heap::heap_size()
{
	heap_block *scan = first_block();

	while(next_block(scan) != NULL)
		scan = next_block(scan);

	/* this is the last block in the heap, and it is free */
	if(scan->type() == FREE_BLOCK_TYPE)
		return (cell)scan - seg->start;
	/* otherwise the last block is allocated */
	else
		return seg->size;
}

/* Compute where each block is going to go, after compaction */
cell heap::compute_heap_forwarding()
{
	heap_block *scan = first_block();
	char *address = (char *)first_block();

	while(scan)
	{
		if(scan->type() != FREE_BLOCK_TYPE)
		{
			forwarding[scan] = address;
			address += scan->size();
		}
		scan = next_block(scan);
	}

	return (cell)address - seg->start;
}

void heap::compact_heap()
{
	heap_block *scan = first_block();

	while(scan)
	{
		heap_block *next = next_block(scan);

		if(scan->type() != FREE_BLOCK_TYPE)
			memmove(forwarding[scan],scan,scan->size());
		scan = next;
	}
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
