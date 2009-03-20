#include "master.h"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get incremental
mark/sweep/compact GC. */
void new_heap(F_HEAP *heap, CELL size)
{
	heap->segment = alloc_segment(align_page(size));
	if(!heap->segment)
		fatal_error("Out of memory in new_heap",size);
	heap->free_list = NULL;
}

/* If there is no previous block, next_free becomes the head of the free list,
else its linked in */
INLINE void update_free_list(F_HEAP *heap, F_FREE_BLOCK *prev, F_FREE_BLOCK *next_free)
{
	if(prev)
		prev->next_free = next_free;
	else
		heap->free_list = next_free;
}

/* Called after reading the code heap from the image file, and after code GC.

In the former case, we must add a large free block from compiling.base + size to
compiling.limit. */
void build_free_list(F_HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_FREE_BLOCK *prev_free = NULL;
	F_BLOCK *scan = first_block(heap);
	F_FREE_BLOCK *end = (F_FREE_BLOCK *)(heap->segment->start + size);

	/* Add all free blocks to the free list */
	while(scan && scan < (F_BLOCK *)end)
	{
		switch(scan->status)
		{
		case B_FREE:
			update_free_list(heap,prev_free,(F_FREE_BLOCK *)scan);
			prev_free = (F_FREE_BLOCK *)scan;
			break;
		case B_ALLOCATED:
			break;
		default:
			critical_error("Invalid scan->status",(CELL)scan);
			break;
		}

		prev = scan;
		scan = next_block(heap,scan);
	}

	/* If there is room at the end of the heap, add a free block. This
	branch is only taken after loading a new image, not after code GC */
	if((CELL)(end + 1) <= heap->segment->end)
	{
		end->block.status = B_FREE;
		end->block.size = heap->segment->end - (CELL)end;
		end->next_free = NULL;

		/* add final free block */
		update_free_list(heap,prev_free,end);
	}
	/* This branch is taken if the newly loaded image fits exactly, or
	after code GC */
	else
	{
		/* even if there's no room at the end of the heap for a new
		free block, we might have to jigger it up by a few bytes in
		case prev + prev->size */
		if(prev)
			prev->size = heap->segment->end - (CELL)prev;

		/* this is the last free block */
		update_free_list(heap,prev_free,NULL);
	}

}

/* Allocate a block of memory from the mark and sweep GC heap */
F_BLOCK *heap_allot(F_HEAP *heap, CELL size)
{
	F_FREE_BLOCK *prev = NULL;
	F_FREE_BLOCK *scan = heap->free_list;

	size = (size + 31) & ~31;

	while(scan)
	{
		if(scan->block.status != B_FREE)
			critical_error("Invalid block in free list",(CELL)scan);

		if(scan->block.size < size)
		{
			prev = scan;
			scan = scan->next_free;
			continue;
		}

		/* we found a candidate block */
		F_FREE_BLOCK *next_free;

		if(scan->block.size - size <= sizeof(F_BLOCK) * 2)
		{
			/* too small to be split */
			next_free = scan->next_free;
		}
		else
		{
			/* split the block in two */
			F_FREE_BLOCK *split = (F_FREE_BLOCK *)((CELL)scan + size);
			split->block.status = B_FREE;
			split->block.size = scan->block.size - size;
			split->next_free = scan->next_free;
			scan->block.size = size;
			next_free = split;
		}

		/* update the free list */
		update_free_list(heap,prev,next_free);

		/* this is our new block */
		scan->block.status = B_ALLOCATED;
		return &scan->block;
	}

	return NULL;
}

void mark_block(F_BLOCK *block)
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
		critical_error("Marking the wrong block",(CELL)block);
		break;
	}
}

/* If in the middle of code GC, we have to grow the heap, data GC restarts from
scratch, so we have to unmark any marked blocks. */
void unmark_marked(F_HEAP *heap)
{
	F_BLOCK *scan = first_block(heap);

	while(scan)
	{
		if(scan->status == B_MARKED)
			scan->status = B_ALLOCATED;

		scan = next_block(heap,scan);
	}
}

/* After code GC, all referenced code blocks have status set to B_MARKED, so any
which are allocated and not marked can be reclaimed. */
void free_unmarked(F_HEAP *heap)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = first_block(heap);

	while(scan)
	{
		switch(scan->status)
		{
		case B_ALLOCATED:
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
			break;
		case B_MARKED:
			scan->status = B_ALLOCATED;
			prev = scan;
			break;
		default:
			critical_error("Invalid scan->status",(CELL)scan);
		}

		scan = next_block(heap,scan);
	}

	build_free_list(heap,heap->segment->size);
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
void heap_usage(F_HEAP *heap, CELL *used, CELL *total_free, CELL *max_free)
{
	*used = 0;
	*total_free = 0;
	*max_free = 0;

	F_BLOCK *scan = first_block(heap);

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
			critical_error("Invalid scan->status",(CELL)scan);
		}

		scan = next_block(heap,scan);
	}
}

/* The size of the heap, not including the last block if it's free */
CELL heap_size(F_HEAP *heap)
{
	F_BLOCK *scan = first_block(heap);

	while(next_block(heap,scan) != NULL)
		scan = next_block(heap,scan);

	/* this is the last block in the heap, and it is free */
	if(scan->status == B_FREE)
		return (CELL)scan - heap->segment->start;
	/* otherwise the last block is allocated */
	else
		return heap->segment->size;
}

/* Compute where each block is going to go, after compaction */
CELL compute_heap_forwarding(F_HEAP *heap)
{
	F_BLOCK *scan = first_block(heap);
	CELL address = (CELL)first_block(heap);

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
		{
			scan->forwarding = (F_BLOCK *)address;
			address += scan->size;
		}
		else if(scan->status == B_MARKED)
			critical_error("Why is the block marked?",0);

		scan = next_block(heap,scan);
	}

	return address - heap->segment->start;
}

void compact_heap(F_HEAP *heap)
{
	F_BLOCK *scan = first_block(heap);

	while(scan)
	{
		F_BLOCK *next = next_block(heap,scan);

		if(scan->status == B_ALLOCATED && scan != scan->forwarding)
			memcpy(scan->forwarding,scan,scan->size);
		scan = next;
	}
}
