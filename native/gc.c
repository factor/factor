#include "factor.h"

/* Stop-and-copy garbage collection using Cheney's algorithm. */

/* #define GC_DEBUG /* */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %d\n",msg,x);
#endif
}

/* Given a pointer to a pointer to oldspace, copy it to newspace. */
CELL copy_untagged_object(CELL pointer, CELL size)
{
	CELL newpointer = allot(size);
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

	if(in_zone(active,pointer))
		fatal_error("copy_object given newspace ptr",pointer);

	if(tag == FIXNUM_TYPE)
	{
		/* convinience */
		return;
	}
	
	header = get(UNTAG(pointer));
	
	if(TAG(header) == GC_COLLECTED)
	{
		newpointer = UNTAG(header);
		gc_debug("FORWARDING",newpointer);
	}
	else
	{
		gc_debug("copy_object",pointer);
		newpointer = copy_untagged_object(UNTAG(pointer),
			object_size(pointer));
		put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));
	}
	
	if(tag == GC_COLLECTED)
		fatal_error("installing forwarding pointer in newspace",newpointer);

	*handle = RETAG(newpointer,tag);
}

void collect_object(void)
{
	CELL size = untagged_object_size(scan);
	gc_debug("collect_object",scan);
	gc_debug("collect_object size=",size);
	
	switch(untag_header(get(scan)))
	{
	case ARRAY_TYPE:
		collect_array((ARRAY*)scan);
		break;
	case VECTOR_TYPE:
		collect_vector((VECTOR*)scan);
		break;
	case SBUF_TYPE:
		collect_sbuf((SBUF*)scan);
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
	case XT_TYPE:
		collect_word((WORD*)scan);
		scan += sizeof(WORD);
		break;
	case HEADER_TYPE:
		collect_object();
		break;
	default:
		copy_object(scan);
		scan += CELLS;
		break;
	}
}

void copy_roots(void)
{
	int i;

	CELL ds_depth = env.ds - UNTAG(env.ds_bot);
	CELL cs_depth = env.cs - UNTAG(env.cs_bot);
	
	gc_debug("collect_roots",scan);
	/* these three must be the first in the heap */
	copy_object(&empty);
	gc_debug("empty",empty);
	copy_object(&F);
	gc_debug("f",F);
	copy_object(&T);
	gc_debug("t",T);
	copy_object(&env.dt);
	copy_object(&env.ds_bot);
	env.ds = UNTAG(env.ds_bot) + ds_depth;
	copy_object(&env.cs_bot);
	env.cs = UNTAG(env.cs_bot) + cs_depth;
	copy_object(&env.cf);
	copy_object(&env.boot);
	
	for(i = 0; i < USER_ENV; i++)
		copy_object(&env.user[i]);
}

void primitive_gc(void)
{
	flip_zones();
	scan = active->here = active->base;
	copy_roots();
	while(scan < active->here)
	{
		gc_debug("scan loop",scan);
		collect_next();
	}
	gc_debug("gc done",0);
}
