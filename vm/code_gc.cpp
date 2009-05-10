#include "master.hpp"

namespace factor
{

static void clear_free_list(heap *heap)
{
	memset(&heap->free,0,sizeof(heap_free_list));
}

/* This malloc-style heap code is reasonably generic. Maybe in the future, it
will be used for the data heap too, if we ever get incremental
mark/sweep/compact GC. */
void new_heap(heap *heap, cell size)
{
	heap->seg = alloc_segment(align_page(size));
	if(!heap->seg)
		fatal_error("Out of memory in new_heap",size);

	clear_free_list(heap);
}

static void add_to_free_list(heap *heap, free_heap_block *block)
{
	if(block->size < free_list_count * block_size_increment)
	{
		int index = block->size / block_size_increment;
		block->next_free = heap->free.small_blocks[index];
		heap->free.small_blocks[index] = block;
	}
	else
	{
		block->next_free = heap->free.large_blocks;
		heap->free.large_blocks = block;
	}
}

/* Called after reading the code heap from the image file, and after code GC.

In the former case, we must add a large free block from compiling.base + size to
compiling.limit. */
void build_free_list(heap *heap, cell size)
{
	heap_block *prev = NULL;

	clear_free_list(heap);

	size = (size + block_size_increment - 1) & ~(block_size_increment - 1);

	heap_block *scan = first_block(heap);
	free_heap_block *end = (free_heap_block *)(heap->seg->start + size);

	/* Add all free blocks to the free list */
	while(scan && scan < (heap_block *)end)
	{
		switch(scan->status)
		{
		case B_FREE:
			add_to_free_list(heap,(free_heap_block *)scan);
			break;
		case B_ALLOCATED:
			break;
		default:
			critical_error("Invalid scan->status",(cell)scan);
			break;
		}

		prev = scan;
		scan = next_block(heap,scan);
	}

	/* If there is room at the end of the heap, add a free block. This
	branch is only taken after loading a new image, not after code GC */
	if((cell)(end + 1) <= heap->seg->end)
	{
		end->status = B_FREE;
		end->size = heap->seg->end - (cell)end;

		/* add final free block */
		add_to_free_list(heap,end);
	}
	/* This branch is taken if the newly loaded image fits exactly, or
	after code GC */
	else
	{
		/* even if there's no room at the end of the heap for a new
		free block, we might have to jigger it up by a few bytes in
		case prev + prev->size */
		if(prev) prev->size = heap->seg->end - (cell)prev;
	}

}

static void assert_free_block(free_heap_block *block)
{
	if(block->status != B_FREE)
		critical_error("Invalid block in free list",(cell)block);
}
		
static free_heap_block *find_free_block(heap *heap, cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_size_increment)
	{
		int index = attempt / block_size_increment;
		free_heap_block *block = heap->free.small_blocks[index];
		if(block)
		{
			assert_free_block(block);
			heap->free.small_blocks[index] = block->next_free;
			return block;
		}

		attempt *= 2;
	}

	free_heap_block *prev = NULL;
	free_heap_block *block = heap->free.large_blocks;

	while(block)
	{
		assert_free_block(block);
		if(block->size >= size)
		{
			if(prev)
				prev->next_free = block->next_free;
			else
				heap->free.large_blocks = block->next_free;
			return block;
		}

		prev = block;
		block = block->next_free;
	}

	return NULL;
}

static free_heap_block *split_free_block(heap *heap, free_heap_block *block, cell size)
{
	if(block->size != size )
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->status = B_FREE;
		split->size = block->size - size;
		split->next_free = block->next_free;
		block->size = size;
		add_to_free_list(heap,split);
	}

	return block;
}

/* Allocate a block of memory from the mark and sweep GC heap */
heap_block *heap_allot(heap *heap, cell size)
{
	size = (size + block_size_increment - 1) & ~(block_size_increment - 1);

	free_heap_block *block = find_free_block(heap,size);
	if(block)
	{
		block = split_free_block(heap,block,size);

		block->status = B_ALLOCATED;
		return block;
	}
	else
		return NULL;
}

/* Deallocates a block manually */
void heap_free(heap *heap, heap_block *block)
{
	block->status = B_FREE;
	add_to_free_list(heap,(free_heap_block *)block);
}

void mark_block(heap_block *block)
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
		critical_error("Marking the wrong block",(cell)block);
		break;
	}
}

/* If in the middle of code GC, we have to grow the heap, data GC restarts from
scratch, so we have to unmark any marked blocks. */
void unmark_marked(heap *heap)
{
	heap_block *scan = first_block(heap);

	while(scan)
	{
		if(scan->status == B_MARKED)
			scan->status = B_ALLOCATED;

		scan = next_block(heap,scan);
	}
}

/* After code GC, all referenced code blocks have status set to B_MARKED, so any
which are allocated and not marked can be reclaimed. */
void free_unmarked(heap *heap, heap_iterator iter)
{
	clear_free_list(heap);

	heap_block *prev = NULL;
	heap_block *scan = first_block(heap);

	while(scan)
	{
		switch(scan->status)
		{
		case B_ALLOCATED:
			if(secure_gc)
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
				add_to_free_list(heap,(free_heap_block *)prev);
			scan->status = B_ALLOCATED;
			prev = scan;
			iter(scan);
			break;
		default:
			critical_error("Invalid scan->status",(cell)scan);
		}

		scan = next_block(heap,scan);
	}

	if(prev && prev->status == B_FREE)
		add_to_free_list(heap,(free_heap_block *)prev);
}

/* Compute total sum of sizes of free blocks, and size of largest free block */
void heap_usage(heap *heap, cell *used, cell *total_free, cell *max_free)
{
	*used = 0;
	*total_free = 0;
	*max_free = 0;

	heap_block *scan = first_block(heap);

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
			critical_error("Invalid scan->status",(cell)scan);
		}

		scan = next_block(heap,scan);
	}
}

/* The size of the heap, not including the last block if it's free */
cell heap_size(heap *heap)
{
	heap_block *scan = first_block(heap);

	while(next_block(heap,scan) != NULL)
		scan = next_block(heap,scan);

	/* this is the last block in the heap, and it is free */
	if(scan->status == B_FREE)
		return (cell)scan - heap->seg->start;
	/* otherwise the last block is allocated */
	else
		return heap->seg->size;
}

/* Compute where each block is going to go, after compaction */
cell compute_heap_forwarding(heap *heap, unordered_map<heap_block *,char *> &forwarding)
{
	heap_block *scan = first_block(heap);
	char *address = (char *)first_block(heap);

	while(scan)
	{
		if(scan->status == B_ALLOCATED)
		{
			forwarding[scan] = address;
			address += scan->size;
		}
		else if(scan->status == B_MARKED)
			critical_error("Why is the block marked?",0);

		scan = next_block(heap,scan);
	}

	return (cell)address - heap->seg->start;
}

void compact_heap(heap *heap, unordered_map<heap_block *,char *> &forwarding)
{
	heap_block *scan = first_block(heap);

	while(scan)
	{
		heap_block *next = next_block(heap,scan);

		if(scan->status == B_ALLOCATED)
			memmove(forwarding[scan],scan,scan->size);
		scan = next;
	}
}

}
