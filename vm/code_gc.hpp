namespace factor
{

static const cell free_list_count = 16;
static const cell block_size_increment = 32;

struct heap_free_list {
	free_heap_block *small_blocks[free_list_count];
	free_heap_block *large_blocks;
};

struct heap {
	segment *seg;
	heap_free_list free;
};

typedef void (*heap_iterator)(heap_block *compiled);

void new_heap(heap *h, cell size);
void build_free_list(heap *h, cell size);
heap_block *heap_allot(heap *h, cell size);
void heap_free(heap *h, heap_block *block);
void mark_block(heap_block *block);
void unmark_marked(heap *heap);
void free_unmarked(heap *heap, heap_iterator iter);
void heap_usage(heap *h, cell *used, cell *total_free, cell *max_free);
cell heap_size(heap *h);
cell compute_heap_forwarding(heap *h, unordered_map<heap_block *,char *> &forwarding);
void compact_heap(heap *h, unordered_map<heap_block *,char *> &forwarding);

inline static heap_block *next_block(heap *h, heap_block *block)
{
	cell next = ((cell)block + block->size);
	if(next == h->seg->end)
		return NULL;
	else
		return (heap_block *)next;
}

inline static heap_block *first_block(heap *h)
{
	return (heap_block *)h->seg->start;
}

inline static heap_block *last_block(heap *h)
{
	return (heap_block *)h->seg->end;
}

}
