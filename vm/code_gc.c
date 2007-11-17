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
CELL heap_allot(F_HEAP *heap, CELL size)
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

		return (CELL)(scan + 1);
	}

	return 0;
}

/* If in the middle of code GC, we have to grow the heap, GC restarts from
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

/* Compute total sum of sizes of free blocks */
CELL heap_usage(F_HEAP *heap, F_BLOCK_STATUS status)
{
	CELL size = 0;
	F_BLOCK *scan = first_block(heap);

	while(scan)
	{
		if(scan->status == status)
			size += scan->size;
		scan = next_block(heap,scan);
	}

	return size;
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
			iterate_code_heap_step(block_to_compiled(scan),iter);
		scan = next_block(&code_heap,scan);
	}
}

/* Copy all literals referenced from a code block to newspace */
void collect_literals_step(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end)
{
	CELL scan;

	CELL literal_end = literals_start + compiled->literals_length;

	for(scan = literals_start; scan < literal_end; scan += CELLS)
		copy_handle((CELL*)scan);

	/* If the block is not finalized, the words area contains pointers to
	words in the data heap rather than XTs in the code heap */
	switch(compiled->finalized)
	{
	case false:
		for(scan = words_start; scan < words_end; scan += CELLS)
			copy_handle((CELL*)scan);
		break;
	case true:
		break;
	default:
		critical_error("Invalid compiled->finalized",(CELL)compiled);
	}
}

/* Copy literals referenced from all code blocks to newspace */
void collect_literals(void)
{
	iterate_code_heap(collect_literals_step);
}

/* Mark all XTs referenced from a code block */
void mark_sweep_step(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end)
{
	F_COMPILED **start = (F_COMPILED **)words_start;
	F_COMPILED **end = (F_COMPILED **)words_end;
	F_COMPILED **iter = start;

	while(iter < end)
		recursive_mark(compiled_to_block(*iter++));
}

/* Mark all XTs and literals referenced from a word XT */
void recursive_mark(F_BLOCK *block)
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
	iterate_code_heap_step(compiled,collect_literals_step);

	switch(compiled->finalized)
	{
	case false:
		break;
	case true:
		iterate_code_heap_step(compiled,mark_sweep_step);
		break;
	default:
		critical_error("Invalid compiled->finalized",(CELL)compiled);
		break;
	}
}

/* Push the free space and total size of the code heap */
DEFINE_PRIMITIVE(code_room)
{
	dpush(tag_fixnum(heap_usage(&code_heap,B_FREE) / 1024));
	dpush(tag_fixnum((code_heap.segment->size) / 1024));
}

void code_gc(void)
{
	garbage_collection(TENURED,true,false,0);
}

DEFINE_PRIMITIVE(code_gc)
{
	code_gc();
}

/* Dump all code blocks for debugging */
void dump_heap(F_HEAP *heap)
{
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
			status = "allocated";
			break;
		case B_MARKED:
			status = "marked";
			break;
		default:
			status = "invalid";
			break;
		}

		fprintf(stderr,"%lx %lx %s\n",(CELL)scan,scan->size,status);

		scan = next_block(heap,scan);
	}
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

			if(word->compiledp != F)
				set_word_xt(word,forward_xt(word->code));
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);

			if(quot->compiledp != F)
				set_quot_xt(quot,forward_xt(quot->code));
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

void compaction_code_block_fixup(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end)
{
	F_COMPILED **iter = (F_COMPILED **)words_start;
	F_COMPILED **end = (F_COMPILED **)words_end;

	while(iter < end)
	{
		*iter = forward_xt(*iter);
		iter++;
	}
}

void forward_block_xts(void)
{
	F_BLOCK *scan = first_block(&code_heap);

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
		{
			iterate_code_heap_step(block_to_compiled(scan),
				compaction_code_block_fixup);
		}

		scan = next_block(&code_heap,scan);
	}
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
	code_gc();

	fprintf(stderr,"*** Code heap compaction...\n");

	/* Figure out where the code heap blocks are going to end up */
	CELL size = compute_heap_forwarding(&code_heap);

	/* Update word and quotation XTs to point to the new locations */
	forward_object_xts();

	/* Update code block XTs to point to the new locations */
	forward_block_xts();

	/* Actually perform the compaction */
	compact_heap(&code_heap);

	/* Now update the free list; there will be a single free block at
	the end */
	build_free_list(&code_heap,size);
}
