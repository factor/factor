typedef struct {
	F_SEGMENT *segment;
	F_FREE_BLOCK *free_list;
} F_HEAP;

void new_heap(F_HEAP *heap, CELL size);
void build_free_list(F_HEAP *heap, CELL size);
F_BLOCK *heap_allot(F_HEAP *heap, CELL size);
void mark_block(F_BLOCK *block);
void unmark_marked(F_HEAP *heap);
void free_unmarked(F_HEAP *heap);
void heap_usage(F_HEAP *heap, CELL *used, CELL *total_free, CELL *max_free);
CELL heap_size(F_HEAP *heap);
CELL compute_heap_forwarding(F_HEAP *heap);
void compact_heap(F_HEAP *heap);

INLINE F_BLOCK *next_block(F_HEAP *heap, F_BLOCK *block)
{
	CELL next = ((CELL)block + block->size);
	if(next == heap->segment->end)
		return NULL;
	else
		return (F_BLOCK *)next;
}

INLINE F_BLOCK *first_block(F_HEAP *heap)
{
	return (F_BLOCK *)heap->segment->start;
}

INLINE F_BLOCK *last_block(F_HEAP *heap)
{
	return (F_BLOCK *)heap->segment->end;
}
