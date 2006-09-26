#include "factor.h"

void new_heap(HEAP *heap, CELL size)
{
	heap->base = (CELL)(alloc_bounded_block(size)->start);
	if(heap->base == 0)
		fatal_error("Cannot allocate code heap",size);
	heap->limit = heap->base + size;
	heap->free_list = NULL;
}

INLINE void update_free_list(HEAP *heap, F_BLOCK *prev, F_BLOCK *next_free)
{
	if(prev)
		prev->next_free = next_free;
	else
		heap->free_list = next_free;
}

/* called after reading the code heap from the image file. we must build the
free list, and add a large free block from compiling.base + size to
compiling.limit. */
void build_free_list(HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = (F_BLOCK *)heap->base;
	F_BLOCK *end = (F_BLOCK *)(heap->base + size);

	while(scan && scan < end)
	{
		if(scan->status == B_FREE)
		{
			update_free_list(heap,prev,scan);
			prev = scan;
		}

		scan = next_block(heap,scan);
	}

	if((CELL)(end + 1) <= heap->limit)
	{
		end->status = B_FREE;
		end->next_free = NULL;
		end->size = heap->limit - (CELL)end;
	}
	else
	{
		end = NULL;

		if(prev)
			prev->size = heap->limit - (CELL)prev;
	}

	update_free_list(heap,prev,end);
}

CELL heap_allot(HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = heap->free_list;

	while(scan)
	{
		CELL this_size = scan->size - sizeof(F_BLOCK);

		if(this_size < size)
		{
			prev = scan;
			scan = scan->next_free;
			continue;
		}

		/* we found a candidate block */
		F_BLOCK *next_free;

		if(this_size - size <= sizeof(F_BLOCK))
		{
			/* too small to be split */
			next_free = scan->next_free;
		}
		else
		{
			/* split the block in two */
			CELL new_size = size + sizeof(F_BLOCK);
			F_BLOCK *split = (F_BLOCK *)((CELL)scan + new_size);
			split->status = B_FREE;
			split->size = scan->size - new_size;
			split->next_free = scan->next_free;
			scan->size = new_size;
			next_free = split;
		}

		/* update the free list */
		update_free_list(heap,prev,next_free);

		/* this is our new block */
		scan->status = B_ALLOCATED;

		return (CELL)(scan + 1);
	}

	if(heap->base == 0)
		critical_error("Code heap is full",size);

	return 0; /* can't happen */
}

/* free blocks which are allocated and not marked */
void free_unmarked(HEAP *heap)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = (F_BLOCK *)heap->base;

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
		{
			/* merge blocks? */
			if(next_block(heap,prev) == scan)
				prev->size += scan->size;
			else
			{
				scan->status = B_FREE;
				update_free_list(heap,prev,scan);
				prev = scan;
			}
		}

		scan = next_block(heap,scan);
	}

	if(prev)
		prev->next_free = NULL;
}

CELL heap_free_space(HEAP *heap)
{
	CELL size = 0;
	F_BLOCK *scan = (F_BLOCK *)heap->base;

	while(scan)
	{
		if(scan->status == B_FREE)
			size += scan->size;
		scan = next_block(heap,scan);
	}

	return size;
}
