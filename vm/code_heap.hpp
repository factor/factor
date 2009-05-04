/* compiled code */
extern F_HEAP code_heap;

void init_code_heap(CELL size);

bool in_code_heap_p(CELL ptr);

void jit_compile_word(CELL word, CELL def, bool relocate);

typedef void (*CODE_HEAP_ITERATOR)(F_CODE_BLOCK *compiled);

void iterate_code_heap(CODE_HEAP_ITERATOR iter);

void copy_code_heap_roots(void);

PRIMITIVE(modify_code_heap);

PRIMITIVE(code_room);

void compact_code_heap(void);

inline static void check_code_pointer(CELL pointer)
{
#ifdef FACTOR_DEBUG
	assert(pointer >= code_heap.segment->start && pointer < code_heap.segment->end);
#endif
}
