namespace factor
{

/* compiled code */
extern heap code;

void init_code_heap(cell size);

bool in_code_heap_p(cell ptr);

void jit_compile_word(cell word, cell def, bool relocate);

typedef void (*code_heap_iterator)(code_block *compiled);

void iterate_code_heap(code_heap_iterator iter);

void copy_code_heap_roots();

PRIMITIVE(modify_code_heap);

PRIMITIVE(code_room);

void compact_code_heap();

inline static void check_code_pointer(cell ptr)
{
#ifdef FACTOR_DEBUG
	assert(in_code_heap_p(ptr));
#endif
}

}
