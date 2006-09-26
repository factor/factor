typedef enum
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
} F_BLOCK_STATUS;

typedef struct _F_BLOCK
{
	F_BLOCK_STATUS status;
	CELL size;
	struct _F_BLOCK *next_free;
} F_BLOCK;

typedef struct {
	CELL base;
	CELL limit;
	F_BLOCK *free_list;
} HEAP;

void new_heap(HEAP *heap, CELL size);
void build_free_list(HEAP *heap, CELL size);
CELL heap_allot(HEAP *heap, CELL size);
void free_unmarked(HEAP *heap);
CELL heap_free_space(HEAP *heap);
CELL heap_size(HEAP *heap);

INLINE F_BLOCK *next_block(HEAP *heap, F_BLOCK *block)
{
	CELL next = ((CELL)block + block->size);
	if(next == heap->limit)
		return NULL;
	else
		return (F_BLOCK *)next;
}
