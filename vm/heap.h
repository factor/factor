typedef enum
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
} F_BLOCK_STATUS;

typedef struct _F_BLOCK
{
	F_BLOCK_STATUS status;
	struct _F_BLOCK *next_free;
	struct _F_BLOCK *next;
} F_BLOCK;

typedef struct {
	CELL base;
	CELL limit;
	F_BLOCK *free_list;
} HEAP;

typedef void (*HEAP_ITERATOR)(CELL here, F_BLOCK_STATUS status);

void new_heap(HEAP *heap, CELL size);
void build_free_list(HEAP *heap, CELL size);
CELL heap_allot(HEAP *heap, CELL size);
void free_unmarked(HEAP *heap);
