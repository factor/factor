#include "factor.h"

/* Stop-and-copy garbage collection using Cheney's algorithm. */

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %d\n",msg,x);
#endif
}

void collect_roots(void)
{
	int i;

	CELL ptr;

	/*T must be the first in the heap */
	copy_object(&T);
	/* the bignum 0 1 -1 constants must be the next three */
	copy_bignum_constants();
	copy_object(&callframe);

	for(ptr = ds_bot; ptr <= ds; ptr += CELLS)
		copy_object((void*)ptr);

	for(ptr = cs_bot; ptr <= cs; ptr += CELLS)
		copy_object((void*)ptr);

	for(i = 0; i < USER_ENV; i++)
		copy_object(&userenv[i]);
}

/*
Given a pointer to a tagged pointer to oldspace, copy it to newspace.
If the object has already been copied, return the forwarding
pointer address without copying anything; otherwise, install
a new forwarding pointer.
*/
CELL copy_object_impl(CELL pointer)
{
	CELL newpointer;

#ifdef GC_DEBUG
	if(in_zone(&active,pointer))
		critical_error("copy_object given newspace ptr",pointer);
#endif

	gc_debug("copy_object",pointer);
	newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
		object_size(pointer));
	put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));

#ifdef GC_DEBUG
	if(tag == GC_COLLECTED)
		critical_error("installing forwarding pointer in newspace",newpointer);
#endif

	return newpointer;
}

INLINE void collect_object(CELL scan)
{
	switch(untag_header(get(scan)))
	{
	case WORD_TYPE:
		collect_word((F_WORD*)scan);
		break;
	case ARRAY_TYPE:
		collect_array((F_ARRAY*)scan);
		break;
	case VECTOR_TYPE:
		collect_vector((F_VECTOR*)scan);
		break;
	case SBUF_TYPE:
		collect_sbuf((F_SBUF*)scan);
		break;
	case PORT_TYPE:
		collect_port((F_PORT*)scan);
		break;
	case ALIEN_TYPE:
		collect_alien((ALIEN*)scan);
		break;
	case DLL_TYPE:
		collect_dll((ALIEN*)scan);
		break;
	}
}

INLINE CELL collect_next(CELL scan)
{
	CELL size;
	gc_debug("collect_next",scan);
	gc_debug("collect_next header",get(scan));
	switch(TAG(get(scan)))
	{
	case HEADER_TYPE:
		size = untagged_object_size(scan);
		collect_object(scan);
		break;
	default:
		size = CELLS;
		copy_object((CELL*)scan);
		break;
	}
	
	return scan + size;
}

void primitive_gc(void)
{
	int64_t start = current_millis();
	CELL scan;

	gc_in_progress = true;

	flip_zones();
	scan = active.here = active.base;
	collect_roots();
	collect_io_tasks();
	/* collect literal objects referenced from compiled code */
	collect_literals();
	
	while(scan < active.here)
	{
		gc_debug("scan loop",scan);
		scan = collect_next(scan);
	}
	gc_debug("gc done",0);

	gc_in_progress = false;

	gc_time += (current_millis() - start);
}

/* WARNING: only call this from a context where all local variables
are also reachable via the GC roots. */
void maybe_garbage_collection(void)
{
	if(active.here > active.alarm)
		primitive_gc();
}

void primitive_gc_time(void)
{
	maybe_garbage_collection();
	dpush(tag_object(s48_long_long_to_bignum(gc_time)));
}
