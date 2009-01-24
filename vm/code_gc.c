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

/* Allocate a code heap during startup */
void init_code_heap(CELL size)
{
	new_heap(&code_heap,size);
}

bool in_code_heap_p(CELL ptr)
{
	return (ptr >= code_heap.segment->start
		&& ptr <= code_heap.segment->end);
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

/* Called after reading the code heap from the image file, and after code GC.

In the former case, we must add a large free block from compiling.base + size to
compiling.limit. */
void build_free_list(F_HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *prev_free = NULL;
	F_BLOCK *scan = first_block(heap);
	F_BLOCK *end = (F_BLOCK *)(heap->segment->start + size);

	/* Add all free blocks to the free list */
	while(scan && scan < end)
	{
		switch(scan->status)
		{
		case B_FREE:
			update_free_list(heap,prev_free,scan);
			prev_free = scan;
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
		end->status = B_FREE;
		end->next_free = NULL;
		end->size = heap->segment->end - (CELL)end;

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
void *heap_allot(F_HEAP *heap, CELL size)
{
	F_BLOCK *prev = NULL;
	F_BLOCK *scan = heap->free_list;

	size = (size + 31) & ~31;

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

		return scan + 1;
	}

	return NULL;
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

/* Apply a function to every code block */
void iterate_code_heap(CODE_HEAP_ITERATOR iter)
{
	F_BLOCK *scan = first_block(&code_heap);

	while(scan)
	{
		if(scan->status != B_FREE)
			iter(block_to_compiled(scan));
		scan = next_block(&code_heap,scan);
	}
}

void update_literal_references_step(F_REL *rel, F_COMPILED *compiled)
{
	if(REL_TYPE(rel) == RT_IMMEDIATE)
	{
		CELL offset = rel->offset + (CELL)(compiled + 1);
		F_ARRAY *literals = untag_object(compiled->literals);
		F_FIXNUM absolute_value = array_nth(literals,REL_ARGUMENT(rel));
		apply_relocation(REL_CLASS(rel),offset,absolute_value);
	}
}

/* Update pointers to literals from compiled code. */
void update_literal_references(F_COMPILED *compiled)
{
	iterate_relocations(compiled,update_literal_references_step);
	flush_icache_for(compiled);
}

/* Copy all literals referenced from a code block to newspace. Only for
aging and nursery collections */
void copy_literal_references(F_COMPILED *compiled)
{
	if(collecting_gen >= compiled->last_scan)
	{
		if(collecting_accumulation_gen_p())
			compiled->last_scan = collecting_gen;
		else
			compiled->last_scan = collecting_gen + 1;

		/* initialize chase pointer */
		CELL scan = newspace->here;

		copy_handle(&compiled->literals);
		copy_handle(&compiled->relocation);

		/* do some tracing so that all reachable literals are now
		at their final address */
		copy_reachable_objects(scan,&newspace->here);

		update_literal_references(compiled);
	}
}

/* Copy literals referenced from all code blocks to newspace. Only for
aging and nursery collections */
void copy_code_heap_roots(void)
{
	iterate_code_heap(copy_literal_references);
}

/* Mark all XTs and literals referenced from a word XT. Only for tenured
collections */
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

	F_COMPILED *compiled = block_to_compiled(block);

	copy_handle(&compiled->literals);
	copy_handle(&compiled->relocation);

	flush_icache_for(compiled);
}

/* Update literals referenced from all code blocks. Only for tenured
collections, done at the end. */
void update_code_heap_roots(void)
{
	iterate_code_heap(update_literal_references);
}

/* Push the free space and total size of the code heap */
void primitive_code_room(void)
{
	CELL used, total_free, max_free;
	heap_usage(&code_heap,&used,&total_free,&max_free);
	dpush(tag_fixnum((code_heap.segment->size) / 1024));
	dpush(tag_fixnum(used / 1024));
	dpush(tag_fixnum(total_free / 1024));
	dpush(tag_fixnum(max_free / 1024));
}

/* Dump all code blocks for debugging */
void dump_heap(F_HEAP *heap)
{
	CELL size = 0;

	F_BLOCK *scan = first_block(heap);

	while(scan)
	{
		char *status;
		switch(scan->status)
		{
		case B_FREE:
			status = "free";
			break;
		case B_ALLOCATED:
			size += object_size(block_to_compiled(scan)->relocation);
			status = "allocated";
			break;
		case B_MARKED:
			size += object_size(block_to_compiled(scan)->relocation);
			status = "marked";
			break;
		default:
			status = "invalid";
			break;
		}

		print_cell_hex((CELL)scan); print_string(" ");
		print_cell_hex(scan->size); print_string(" ");
		print_string(status); print_string("\n");

		scan = next_block(heap,scan);
	}
	
	print_cell(size); print_string(" bytes of relocation data\n");
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

F_COMPILED *forward_xt(F_COMPILED *compiled)
{
	return block_to_compiled(compiled_to_block(compiled)->forwarding);
}

void forward_frame_xt(F_STACK_FRAME *frame)
{
	CELL offset = (CELL)FRAME_RETURN_ADDRESS(frame) - (CELL)frame_code(frame);
	F_COMPILED *forwarded = forward_xt(frame_code(frame));
	frame->xt = (XT)(forwarded + 1);
	FRAME_RETURN_ADDRESS(frame) = (XT)((CELL)forwarded + offset);
}

void forward_object_xts(void)
{
	begin_scan();

	CELL obj;

	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			F_WORD *word = untag_object(obj);

			word->code = forward_xt(word->code);
			if(word->profiling)
				word->profiling = forward_xt(word->profiling);
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);

			if(quot->compiledp != F)
				quot->code = forward_xt(quot->code);
		}
		else if(type_of(obj) == CALLSTACK_TYPE)
		{
			F_CALLSTACK *stack = untag_object(obj);
			iterate_callstack_object(stack,forward_frame_xt);
		}
	}

	/* End the heap scan */
	gc_off = false;
}

/* Set the XT fields now that the heap has been compacted */
void fixup_object_xts(void)
{
	begin_scan();

	CELL obj;

	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			F_WORD *word = untag_object(obj);
			update_word_xt(word);
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);

			if(quot->compiledp != F)
				set_quot_xt(quot,quot->code);
		}
	}

	/* End the heap scan */
	gc_off = false;
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

/* Move all free space to the end of the code heap. This is not very efficient,
since it makes several passes over the code and data heaps, but we only ever
do this before saving a deployed image and exiting, so performaance is not
critical here */
void compact_code_heap(void)
{
	/* Free all unreachable code blocks */
	gc();

	/* Figure out where the code heap blocks are going to end up */
	CELL size = compute_heap_forwarding(&code_heap);

	/* Update word and quotation code pointers */
	forward_object_xts();

	/* Actually perform the compaction */
	compact_heap(&code_heap);

	/* Update word and quotation XTs */
	fixup_object_xts();

	/* Now update the free list; there will be a single free block at
	the end */
	build_free_list(&code_heap,size);
}
