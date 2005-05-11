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

/* Given a pointer to oldspace, copy it to newspace. */
INLINE void* copy_untagged_object(void* pointer, CELL size)
{
	void* newpointer = allot(size);
	memcpy(newpointer,pointer,size);

	return newpointer;
}

CELL copy_object_impl(CELL pointer);

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %d\n",msg,x);
#endif
}

INLINE CELL copy_object(CELL pointer)
{
	CELL tag;
	CELL header;
	CELL untagged;

	gc_debug("copy object",pointer);

	if(!COLLECTING_GEN(pointer))
		return pointer;

	if(pointer == F)
		return F;

	tag = TAG(pointer);

	if(tag == FIXNUM_TYPE)
		return pointer;

	header = get(UNTAG(pointer));
	untagged = UNTAG(header);
	if(TAG(header) != FIXNUM_TYPE && in_zone(&tenured,untagged))
	{
		gc_debug("forwarding",untagged);
		return RETAG(untagged,tag);
	}
	else
		return RETAG(copy_object_impl(pointer),tag);
}

#define COPY_OBJECT(lvalue) lvalue = copy_object(lvalue)

INLINE void copy_handle(CELL* handle)
{
	COPY_OBJECT(*handle);
}

void collect_roots(void);
void collect_card(CARD *ptr);
void collect_gen_cards(CELL gen);
void collect_cards(void);
void clear_cards(void);
void primitive_gc(void);
void maybe_garbage_collection(void);
void primitive_gc_time(void);
