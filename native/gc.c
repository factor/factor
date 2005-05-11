#include "factor.h"

/* Generational copying garbage collector */

void collect_roots(void)
{
	int i;
	CELL ptr;

	gc_debug("root: t",T);
	COPY_OBJECT(T);
	gc_debug("root: bignum_zero",bignum_zero);
	COPY_OBJECT(bignum_zero);
	gc_debug("root: bignum_pos_one",bignum_pos_one);
	COPY_OBJECT(bignum_pos_one);
	gc_debug("root: bignum_neg_one",bignum_neg_one);
	COPY_OBJECT(bignum_neg_one);
	gc_debug("root: callframe",callframe);
	COPY_OBJECT(callframe);
	gc_debug("root: executing",executing);
	COPY_OBJECT(executing);

	for(ptr = ds_bot; ptr <= ds; ptr += CELLS)
		copy_handle((CELL*)ptr);

	for(ptr = cs_bot; ptr <= cs; ptr += CELLS)
		copy_handle((CELL*)ptr);

	for(i = 0; i < USER_ENV; i++)
		copy_handle(&userenv[i]);
}

void clear_cards(void)
{
	BYTE *ptr;
	for(ptr = cards; ptr < cards_end; ptr++)
		clear_card(ptr);
}

void collect_cards(void)
{
	BYTE *ptr;
	for(ptr = cards; ptr < cards_end; ptr++)
	{
		CARD c = *ptr;
		if(card_marked(*ptr))
		{
			CELL offset = (c & CARD_BASE_MASK);
			if(offset == 0x7f)
				critical_error("bad card",c);
			CELL ea = (CELL)CARD_TO_ADDR(c) + offset;
			printf("write barrier hit %d\n",offset);
			printf("object header: %x\n",get(ea));
			clear_card(ptr);
		}
	}
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

	gc_debug("copy_object",pointer);
	newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
		object_size(pointer));
	put(UNTAG(pointer),RETAG(newpointer,OBJECT_TYPE));

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
	case TUPLE_TYPE:
		collect_array((F_ARRAY*)scan);
		break;
	case HASHTABLE_TYPE:
		collect_hashtable((F_HASHTABLE*)scan);
		break;
	case VECTOR_TYPE:
		collect_vector((F_VECTOR*)scan);
		break;
	case SBUF_TYPE:
		collect_sbuf((F_SBUF*)scan);
		break;
	case DLL_TYPE:
		collect_dll((DLL*)scan);
		break;
	case DISPLACED_ALIEN_TYPE:
		collect_displaced_alien((DISPLACED_ALIEN*)scan);
		break;
	}
}

INLINE CELL collect_next(CELL scan)
{
	CELL size;
	gc_debug("collect_next",scan);
	gc_debug("collect_next header",get(scan));
	if(headerp(get(scan)))
	{
		size = untagged_object_size(scan);
		collect_object(scan);
	}
	else
	{
		size = CELLS;
		copy_handle((CELL*)scan);
	}

	return scan + size;
}

void primitive_gc(void)
{
	s64 start = current_millis();
	CELL scan;

	if(heap_scan)
	{
		fprintf(stderr,"GC disabled\n");
		fflush(stderr);
		return;
	}

	gc_in_progress = true;

	flip_zones();
	scan = active.base;

	collect_roots();
	collect_cards();

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
	dpush(tag_bignum(s48_long_long_to_bignum(gc_time)));
}
