#include "factor.h"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get incremental
mark/sweep/compact GC. */
void new_heap(HEAP *heap, CELL size)
{
	heap->base = (CELL)(alloc_bounded_block(size)->start);
	if(heap->base == 0)
		fatal_error("Cannot allocate code heap",size);
	heap->limit = heap->base + size;
	heap->free_list = NULL;
}

void init_code_heap(CELL size)
{
	new_heap(&compiling,size);
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

	size = align8(size);

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
			if(prev && next_block(heap,prev) == scan)
				prev->size += scan->size;
			else
			{
				scan->status = B_FREE;
				update_free_list(heap,prev,scan);
				prev = scan;
			}
		}
		else if(scan->status == B_MARKED)
			scan->status = B_ALLOCATED;

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

CELL heap_size(HEAP *heap)
{
	CELL start = heap->base;
	F_BLOCK *scan = (F_BLOCK *)start;
	while(next_block(heap,scan))
		scan = next_block(heap,scan);
	return (CELL)scan - (CELL)start;
}

void iterate_code_heap(CODE_HEAP_ITERATOR iter)
{
	F_BLOCK *scan = (F_BLOCK *)compiling.base;

	while(scan)
	{
		if(scan->status != B_FREE)
			iterate_code_heap_step((F_COMPILED *)(scan + 1),iter);
		scan = next_block(&compiling,scan);
	}
}

void collect_literals_step(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	CELL scan;

	CELL literal_end = literal_start + relocating->literal_length;

	for(scan = literal_start; scan < literal_end; scan += CELLS)
		copy_handle((CELL*)scan);

	if(!relocating->finalized)
	{
		for(scan = words_start; scan < words_end; scan += CELLS)
			copy_handle((CELL*)scan);
	}
}

void collect_literals(void)
{
	iterate_code_heap(collect_literals_step);
}

void mark_sweep_step(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	CELL scan;

	if(compiled->finalized)
	{
		for(scan = words_start; scan < words_end; scan += CELLS)
			recursive_mark(get(scan));
	}
}

void recursive_mark(CELL xt)
{
	F_BLOCK *block = xt_to_block(xt);

	if(block->status == B_MARKED)
		return;
	else if(block->status == B_ALLOCATED)
		block->status = B_MARKED;
	else
		critical_error("Marking the wrong block",(CELL)block);

	F_COMPILED *compiled = xt_to_compiled(xt);
	iterate_code_heap_step(compiled,collect_literals_step);
	iterate_code_heap_step(compiled,mark_sweep_step);
}

void primitive_code_room(void)
{
	box_unsigned_cell(heap_free_space(&compiling));
	box_unsigned_cell(compiling.limit - compiling.base);
}

void primitive_code_gc(void)
{
	garbage_collection(TENURED,true);
}

void dump_heap(HEAP *heap)
{
	F_BLOCK *scan = (F_BLOCK *)heap->base;

	while(scan)
	{
		char *status;
		switch(scan->status)
		{
		case B_FREE:
			status = "free";
			break;
		case B_ALLOCATED:
			status = "allocated";
			break;
		case B_MARKED:
			status = "marked";
			break;
		default:
			status = "invalid";
			break;
		}

		fprintf(stderr,"%lx %s\n",(CELL)scan,status);

		scan = next_block(heap,scan);
	}
}
