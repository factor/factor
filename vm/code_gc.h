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
} F_HEAP;

void new_heap(F_HEAP *heap, CELL size);
void build_free_list(F_HEAP *heap, CELL size);
CELL heap_allot(F_HEAP *heap, CELL size);
void free_unmarked(F_HEAP *heap);
CELL heap_free_space(F_HEAP *heap);
CELL heap_size(F_HEAP *heap);

INLINE F_BLOCK *next_block(F_HEAP *heap, F_BLOCK *block)
{
	CELL next = ((CELL)block + block->size);
	if(next == heap->limit)
		return NULL;
	else
		return (F_BLOCK *)next;
}

/* compiled code */
F_HEAP compiling;

/* The compiled code heap is structured into blocks. */
typedef struct
{
	CELL code_length; /* # bytes */
	CELL reloc_length; /* # bytes */
	CELL literal_length; /* # bytes */
	CELL words_length; /* # bytes */
	CELL finalized; /* has finalize_code_block() been called on this yet? */
} F_COMPILED;

typedef void (*CODE_HEAP_ITERATOR)(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end);

INLINE void iterate_code_heap_step(F_COMPILED *compiled, CODE_HEAP_ITERATOR iter)
{
	CELL code_start = (CELL)(compiled + 1);
	CELL reloc_start = code_start + compiled->code_length;
	CELL literal_start = reloc_start + compiled->reloc_length;
	CELL words_start = literal_start + compiled->literal_length;
	CELL words_end = words_start + compiled->words_length;

	iter(compiled,code_start,reloc_start,literal_start,words_start,words_end);
}

INLINE F_BLOCK *xt_to_block(CELL xt)
{
	return (F_BLOCK *)(xt - sizeof(F_BLOCK) - sizeof(F_COMPILED));
}

INLINE F_COMPILED *xt_to_compiled(CELL xt)
{
	return (F_COMPILED *)(xt - sizeof(F_COMPILED));
}

void init_code_heap(CELL size);
void iterate_code_heap(CODE_HEAP_ITERATOR iter);
void collect_literals(void);
void recursive_mark(CELL xt);
void primitive_code_room(void);
void primitive_code_gc(void);
void dump_heap(F_HEAP *heap);
