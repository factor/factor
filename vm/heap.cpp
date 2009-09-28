#include "master.hpp"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get mark/sweep/compact GC. */

namespace factor
{

void heap::clear_free_list()
{
	memset(&free,0,sizeof(heap_free_list));
}

heap::heap(factor_vm *myvm_, cell size)
{
	myvm = myvm_;
	seg = new segment(myvm,align_page(size));
	if(!seg) fatal_error("Out of memory in new_heap",size);
	clear_free_list();
}

void heap::add_to_free_list(free_heap_block *block)
{
	if(block->size < free_list_count * block_size_increment)
	{
		int index = block->size / block_size_increment;
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
		switch(scan->status)
		{
		case B_FREE:
			add_to_free_list((free_heap_block *)scan);
			break;
		case B_ALLOCATED:
			break;
		default:
			myvm->critical_error("Invalid scan->status",(cell)scan);
			break;
		}

		prev = scan;
		scan = next_block(scan);
	}

	/* If there is room at the end of the heap, add a free block. This
	branch is only taken after loading a new image, not after code GC */
	if((cell)(end + 1) <= seg->end)
	{
		end->status = B_FREE;
		end->size = seg->end - (cell)end;

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
		if(prev) prev->size = seg->end - (cell)prev;
	}

}

void heap::assert_free_block(free_heap_block *block)
{
	if(block->status != B_FREE)
		myvm->critical_error("Invalid block in free list",(cell)block);
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
		if(block->size >= size)
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
	if(block->size != size )
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->status = B_FREE;
		split->size = block->size - size;
		split->next_free = block->next_free;
		block->size = size;
		add_to_free_list(split);
	}

	return block;
}

/* Allocate a block of memory from the mark and sweep GC heap */
heap_block *heap::heap_allot(cell size)
{
	size = (size + block_size_increment - 1) & ~(block_size_increment - 1);

	free_heap_block *block = find_free_block(size);
	if(block)
	{
		block = split_free_block(block,size);

		block->status = B_ALLOCATED;
		return block;
	}
	else
		return NULL;
}

/* Deallocates a block manually */
void heap::heap_free(heap_block *block)
{
	block->status = B_FREE;
	add_to_free_list((free_heap_block *)block);
}

void heap::mark_block(heap_block *block)
{
	/* If already marked, do nothing */
	switch(block->status)
	{
	case B_MARKED:
		return;
	case B_ALLOCATED:
		block->status = B_MARKED;
		break;
	default:
		myvm->critical_error("Marking the wrong block",(cell)block);
		break;
	}
}

/* If in the middle of code GC, we have to grow the heap, data GC restarts from
scratch, so we have to unmark any marked blocks. */
void heap::unmark_marked()
{
	heap_block *scan = first_block();

	while(scan)
	{
		if(scan->status == B_MARKED)
			scan->status = B_ALLOCATED;

		scan = next_block(scan);
	}
}

/* After code GC, all referenced code blocks have status set to B_MARKED, so any
which are allocated and not marked can be reclaimed. */
void heap::free_unmarked(heap_iterator iter)
{
	clear_free_list();

	heap_block *prev = NULL;
	heap_block *scan = first_block();

	while(scan)
	{
		switch(scan->status)
		{
		case B_ALLOCATED:
			if(myvm->secure_gc)
				memset(scan + 1,0,scan->size - sizeof(heap_block));

			if(prev && prev->status == B_FREE)
				prev->size += scan->size;
			else
			{
				scan->status = B_FREE;
				prev = scan;
			}
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
			(myvm->*iter)(scan);
			break;
		default:
			myvm->critical_error("Invalid scan->status",(cell)scan);
		}

		scan = next_block(scan);
	}

	if(prev && prev->status == B_FREE)
		add_to_free_list((free_heap_block *)prev);
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
		switch(scan->status)
		{
		case B_ALLOCATED:
			*used += scan->size;
			break;
		case B_FREE:
			*total_free += scan->size;
			if(scan->size > *max_free)
				*max_free = scan->size;
			break;
		default:
			myvm->critical_error("Invalid scan->status",(cell)scan);
		}

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
	if(scan->status == B_FREE)
		return (cell)scan - seg->start;
	/* otherwise the last block is allocated */
	else
		return seg->size;
}

/* Compute where each block is going to go, after compaction */
cell heap::compute_heap_forwarding(unordered_map<heap_block *,char *> &forwarding)
{
	heap_block *scan = first_block();
	char *address = (char *)first_block();

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
		{
			forwarding[scan] = address;
			address += scan->size;
		}
		else if(scan->status == B_MARKED)
			myvm->critical_error("Why is the block marked?",0);

		scan = next_block(scan);
	}

	return (cell)address - seg->start;
}

void heap::compact_heap(unordered_map<heap_block *,char *> &forwarding)
{
	heap_block *scan = first_block();

	while(scan)
	{
		heap_block *next = next_block(scan);

		if(scan->status == B_ALLOCATED)
			memmove(forwarding[scan],scan,scan->size);
		scan = next;
	}
}

}
