#include "factor.h"

/* Stop-and-copy garbage collection using Cheney's algorithm. */

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %d\n",msg,x);
#endif
}

/* Given a pointer to oldspace, copy it to newspace. */
void* copy_untagged_object(void* pointer, CELL size)
{
	void* newpointer = allot(size);
	memcpy(newpointer,pointer,size);

	return newpointer;
}

/*
Given a pointer to a tagged pointer to oldspace, copy it to newspace.
If the object has already been copied, return the forwarding
pointer address without copying anything; otherwise, install
a new forwarding pointer.
*/
void copy_object(CELL* handle)
{
	CELL pointer = *handle;
	CELL tag = TAG(pointer);
	CELL header, newpointer;

	if(tag == FIXNUM_TYPE)
	{
		/* convinience */
		gc_debug("FIXNUM",pointer);
		return;
	}
	
	if(in_zone(active,pointer))
		critical_error("copy_object given newspace ptr",pointer);

	header = get(UNTAG(pointer));
	
	if(TAG(header) == GC_COLLECTED)
	{
		newpointer = UNTAG(header);
		gc_debug("FORWARDING",newpointer);
	}
	else if(TAG(pointer) == GC_COLLECTED)
	{
		critical_error("asked to copy forwarding pointer",pointer);
		newpointer = 0; /* to shut up gcc */
	}
	else
	{
		gc_debug("copy_object",pointer);
		newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
			object_size(pointer));
		put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));
	}
	
	if(tag == GC_COLLECTED)
		critical_error("installing forwarding pointer in newspace",newpointer);

	*handle = RETAG(newpointer,tag);
}

void collect_object(void)
{
	CELL size = untagged_object_size(scan);
	gc_debug("collect_object",scan);
	gc_debug("collect_object size=",size);
	
	switch(untag_header(get(scan)))
	{
	case WORD_TYPE:
		collect_word((WORD*)scan);
		break;
	case ARRAY_TYPE:
		collect_array((ARRAY*)scan);
		break;
	case VECTOR_TYPE:
		collect_vector((VECTOR*)scan);
		break;
	case SBUF_TYPE:
		collect_sbuf((SBUF*)scan);
		break;
	case PORT_TYPE:
		collect_port((PORT*)scan);
		break;
	}
	
	scan += size;
}

void collect_next(void)
{
	gc_debug("collect_next",scan);
	gc_debug("collect_next header",get(scan));
	switch(TAG(get(scan)))
	{
	case HEADER_TYPE:
		collect_object();
		break;
	default:
		copy_object((CELL*)scan);
		scan += CELLS;
		break;
	}
}

void collect_roots(void)
{
	int i;

	CELL ptr;

	gc_debug("collect_roots",scan);
	/* these two must be the first in the heap */
	copy_object(&F);
	copy_object(&T);
	/* the bignum 0 1 -1 constants must be the next three */
	copy_bignum_constants();
	copy_object(&callframe);

	for(ptr = ds_bot; ptr < ds; ptr += CELLS)
		copy_object((void*)ptr);

	for(ptr = cs_bot; ptr < cs; ptr += CELLS)
		copy_object((void*)ptr);

	for(i = 0; i < USER_ENV; i++)
		copy_object(&userenv[i]);
}

void primitive_gc(void)
{
	gc_in_progress = true;

	flip_zones();
	scan = active->here = active->base;
	collect_roots();
	collect_io_tasks();
	while(scan < active->here)
	{
		gc_debug("scan loop",scan);
		collect_next();
	}
	gc_debug("gc done",0);

	gc_in_progress = false;
}
