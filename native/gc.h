bool gc_in_progress;

/* GC is off during heap walking */
bool heap_scan;

s64 gc_time;

/* only meaningful during a GC */
CELL collecting_generation;

/* test if the pointer is in generation being collected, or a younger one.
init_arena() arranges things so that the older generations are first,
so we have to check that the pointer occurs after the beginning of
the requested generation. */
#define COLLECTING_GEN(ptr) (collecting_generation <= ptr)

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %ld\n",msg,x);
#endif
}

CELL copy_object(CELL pointer);
#define COPY_OBJECT(lvalue) if(COLLECTING_GEN(lvalue)) lvalue = copy_object(lvalue)

INLINE void copy_handle(CELL *handle)
{
	COPY_OBJECT(*handle);
}

void clear_cards(CELL from, CELL to);
void unmark_cards(CELL from, CELL to);
void primitive_gc(void);
void garbage_collection(CELL gen);
void maybe_garbage_collection(void);
void primitive_gc_time(void);

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;
