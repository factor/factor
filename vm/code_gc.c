#include "factor.h"

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get incremental
mark/sweep/compact GC. */
void new_heap(F_HEAP *heap, CELL size)
{
	heap->base = (CELL)(alloc_segment(size)->start);
	if(heap->base == 0)
		fatal_error("Cannot allocate code heap",size);
	heap->limit = heap->base + size;
	heap->free_list = NULL;
}

/* Allocate a code heap during startup */
void init_code_heap(CELL size)
{
	new_heap(&compiling,size);
}

/* If there is no previous block, next_free becomes the head of the free list,
else its linked in */
INLINE void update_free_list(F_HEAP *heap, F_BLOCK *prev, F_BLOCK *next_free)
{
	if(prev)
		prev->next_free = next_free;
	else
		heap->free_list = next_free;
}

/* Called after reading the code heap from the image file. We must build the
free list, and add a large free block from compiling.base + size to
compiling.limit. */
void build_free_list(F_HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = (F_BLOCK *)heap->base;
	F_BLOCK *end = (F_BLOCK *)(heap->base + size);

	/* Add all free blocks to the free list */
	while(scan && scan < end)
	{
		if(scan->status == B_FREE)
		{
			update_free_list(heap,prev,scan);
			prev = scan;
		}

		scan = next_block(heap,scan);
	}

	/* If there is room at the end of the heap, add a free block */
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

/* Allocate a block of memory from the mark and sweep GC heap */
CELL heap_allot(F_HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = heap->free_list;

	size = align8(size);

	while(scan)
	{
		CELL this_size = scan->size - sizeof(F_BLOCK);

		if(scan->status != B_FREE)
			critical_error("Invalid block in free list",(CELL)scan);

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

	return 0; /* can't happen */
}

/* After code GC, all referenced code blocks have status set to B_MARKED, so any
which are allocated and not marked can be reclaimed. */
void free_unmarked(F_HEAP *heap)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = (F_BLOCK *)heap->base;

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
		}

		scan = next_block(heap,scan);
	}

	build_free_list(heap,heap->limit - heap->base);
}

/* Compute total sum of sizes of free blocks */
CELL heap_free_space(F_HEAP *heap)
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

CELL heap_size(F_HEAP *heap)
{
	CELL start = heap->base;
	F_BLOCK *scan = (F_BLOCK *)start;
	while(next_block(heap,scan))
		scan = next_block(heap,scan);
	return (CELL)scan - (CELL)start;
}

/* Apply a function to every code block */
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

/* Copy all literals referenced from a code block to newspace */
void collect_literals_step(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	CELL scan;

	CELL literal_end = literal_start + relocating->literal_length;

	for(scan = literal_start; scan < literal_end; scan += CELLS)
		copy_handle((CELL*)scan);

	/* If the block is not finalized, the words area contains pointers to
	words in the data heap rather than XTs in the code heap */
	if(!relocating->finalized)
	{
		for(scan = words_start; scan < words_end; scan += CELLS)
			copy_handle((CELL*)scan);
	}
}

/* Copy literals referenced from all code blocks to newspace */
void collect_literals(void)
{
	iterate_code_heap(collect_literals_step);
}

/* Mark all XTs referenced from a code block */
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

/* Mark all XTs and literals referenced from a word XT */
void recursive_mark(CELL xt)
{
	F_BLOCK *block = xt_to_block(xt);

	/* If already marked, do nothing */
	if(block->status == B_MARKED)
		return;
	/* Mark it */
	else if(block->status == B_ALLOCATED)
		block->status = B_MARKED;
	/* We should never be asked to mark a free block */
	else
		critical_error("Marking the wrong block",(CELL)block);

	F_COMPILED *compiled = xt_to_compiled(xt);
	iterate_code_heap_step(compiled,collect_literals_step);
	iterate_code_heap_step(compiled,mark_sweep_step);
}

/* Push the free space and total size of the code heap */
void primitive_code_room(void)
{
	dpush(tag_fixnum(heap_free_space(&compiling) / 1024));
	dpush(tag_fixnum((compiling.limit - compiling.base) / 1024));
}

/* Perform a code GC */
void primitive_code_gc(void)
{
	garbage_collection(TENURED,true);
}

/* Dump all code blocks for debugging */
void dump_heap(F_HEAP *heap)
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
