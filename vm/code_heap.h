/* compiled code */
F_HEAP code_heap;

INLINE F_BLOCK *compiled_to_block(F_CODE_BLOCK *compiled)
{
	return (F_BLOCK *)compiled - 1;
}

INLINE F_CODE_BLOCK *block_to_compiled(F_BLOCK *block)
{
	return (F_CODE_BLOCK *)(block + 1);
}

void init_code_heap(CELL size);

bool in_code_heap_p(CELL ptr);

void default_word_code(F_WORD *word, bool relocate);

void set_word_code(F_WORD *word, F_CODE_BLOCK *compiled);

typedef void (*CODE_HEAP_ITERATOR)(F_CODE_BLOCK *compiled);

void iterate_code_heap(CODE_HEAP_ITERATOR iter);

void copy_code_heap_roots(void);

void update_code_heap_roots(void);

void primitive_modify_code_heap(void);

void primitive_code_room(void);

void compact_code_heap(void);
