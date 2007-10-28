typedef enum
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
} F_BLOCK_STATUS;

typedef struct _F_BLOCK
{
	F_BLOCK_STATUS status;

	/* In bytes, includes this header */
	CELL size;

	/* Filled in on image load */
	struct _F_BLOCK *next_free;

	/* Used during compaction */
	struct _F_BLOCK *forwarding;

	/* Alignment padding */
	CELL padding[4];
} F_BLOCK;

typedef struct {
	F_SEGMENT *segment;
	F_BLOCK *free_list;
} F_HEAP;

void new_heap(F_HEAP *heap, CELL size);
void build_free_list(F_HEAP *heap, CELL size);
CELL heap_allot(F_HEAP *heap, CELL size);
void unmark_marked(F_HEAP *heap);
void free_unmarked(F_HEAP *heap);
CELL heap_usage(F_HEAP *heap, F_BLOCK_STATUS status);
CELL heap_size(F_HEAP *heap);

INLINE F_BLOCK *next_block(F_HEAP *heap, F_BLOCK *block)
{
	CELL next = ((CELL)block + block->size);
	if(next == heap->segment->end)
		return NULL;
	else
		return (F_BLOCK *)next;
}

/* compiled code */
F_HEAP code_heap;

typedef void (*CODE_HEAP_ITERATOR)(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end);

INLINE void iterate_code_heap_step(F_COMPILED *compiled, CODE_HEAP_ITERATOR iter)
{
	CELL code_start = (CELL)(compiled + 1);
	CELL reloc_start = code_start + compiled->code_length;
	CELL literals_start = reloc_start + compiled->reloc_length;
	CELL words_start = literals_start + compiled->literals_length;
	CELL words_end = words_start + compiled->words_length;

	iter(compiled,code_start,reloc_start,literals_start,words_start,words_end);
}

INLINE F_BLOCK *compiled_to_block(F_COMPILED *compiled)
{
	return (F_BLOCK *)compiled - 1;
}

INLINE F_COMPILED *block_to_compiled(F_BLOCK *block)
{
	return (F_COMPILED *)(block + 1);
}

INLINE F_BLOCK *first_block(F_HEAP *heap)
{
	return (F_BLOCK *)heap->segment->start;
}

INLINE F_BLOCK *last_block(F_HEAP *heap)
{
	return (F_BLOCK *)heap->segment->end;
}

void init_code_heap(CELL size);
bool in_code_heap_p(CELL ptr);
void iterate_code_heap(CODE_HEAP_ITERATOR iter);
void collect_literals(void);
void recursive_mark(F_BLOCK *block);
void dump_heap(F_HEAP *heap);
void code_gc(void);
void compact_code_heap(void);

DECLARE_PRIMITIVE(code_room);
DECLARE_PRIMITIVE(code_gc);
