#include "factor.h"

/* Generational copying garbage collector */

void collect_roots(void)
{
	int i;
	CELL ptr;

	copy_handle(&T);
	copy_handle(&bignum_zero);
	copy_handle(&bignum_pos_one);
	copy_handle(&bignum_neg_one);
	/* we can't use & here since these two are in
	registers on PowerPC */
	COPY_OBJECT(callframe);
	COPY_OBJECT(executing);

	for(ptr = ds_bot; ptr <= ds; ptr += CELLS)
		copy_handle((CELL*)ptr);

	for(ptr = cs_bot; ptr <= cs; ptr += CELLS)
		copy_handle((CELL*)ptr);

	for(i = 0; i < USER_ENV; i++)
		copy_handle(&userenv[i]);
}

/* Given a pointer to oldspace, copy it to newspace. */
INLINE void *copy_untagged_object(void *pointer, CELL size)
{
	void *newpointer;
	if(newspace->here + size >= newspace->limit)
		longjmp(gc_jmp,1);
	newpointer = allot_zone(newspace,size);
	memcpy(newpointer,pointer,size);
	return newpointer;
}

INLINE CELL copy_object_impl(CELL pointer)
{
	CELL newpointer;

	if(pointer < collecting_generation)
		critical_error("asked to copy object outside collected generation",pointer);
	
	newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
		object_size(pointer));

	/* install forwarding pointer */
	put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));

	return newpointer;
}

/*
Given a pointer to a tagged pointer to oldspace, copy it to newspace.
If the object has already been copied, return the forwarding
pointer address without copying anything; otherwise, install
a new forwarding pointer.
*/
CELL copy_object(CELL pointer)
{
	CELL tag;
	CELL header;
	CELL untagged;

	gc_debug("copy object",pointer);

	if(pointer == F)
		return F;

	tag = TAG(pointer);

	if(tag == FIXNUM_TYPE)
		return pointer;

	header = get(UNTAG(pointer));
	untagged = UNTAG(header);
	if(TAG(header) == GC_COLLECTED)
	{
		header = get(untagged);
		while(header == GC_COLLECTED)
		{
			untagged = UNTAG(header);
			header = get(untagged);
		}
		gc_debug("forwarding",untagged);
		return RETAG(untagged,tag);
	}
	else
		return RETAG(copy_object_impl(pointer),tag);
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

/* scan all the objects in the card */
INLINE void collect_card(CARD *ptr, CELL here)
{
	CARD c = *ptr;
	CELL offset = (c & CARD_BASE_MASK);
	CELL card_scan = (CELL)CARD_TO_ADDR(ptr) + offset;
	CELL card_end = (CELL)CARD_TO_ADDR(ptr + 1);

	if(offset == 0x7f)
	{
		if(c == 0xff)
			critical_error("bad card",c);
		else
			return;
	}

	while(card_scan < card_end && card_scan < here)
		card_scan = collect_next(card_scan);
}

INLINE void collect_gen_cards(CELL gen)
{
	CARD *ptr = ADDR_TO_CARD(generations[gen].base);
	CELL here = generations[gen].here;
	CARD *last_card = ADDR_TO_CARD(here);
	
	if(generations[gen].here == generations[gen].limit)
		last_card--;
	
	for(; ptr <= last_card; ptr++)
	{
		if(card_marked(*ptr))
			collect_card(ptr,here);
	}
}

void unmark_cards(CELL from, CELL to)
{
	CARD *ptr = ADDR_TO_CARD(generations[from].base);
	CARD *last_card = ADDR_TO_CARD(generations[to].here);
	if(generations[to].here == generations[to].limit)
		last_card--;
	for(; ptr <= last_card; ptr++)
		unmark_card(ptr);
}

void clear_cards(CELL from, CELL to)
{
	CARD *ptr = ADDR_TO_CARD(generations[from].base);
	CARD *last_card = ADDR_TO_CARD(generations[to].limit);
	for(; ptr < last_card; ptr++)
		clear_card(ptr);
}

void reset_generations(CELL from, CELL to)
{
	CELL i;
	for(i = from; i <= to; i++)
		generations[i].here = generations[i].base;
	clear_cards(from,to);
}

/* scan cards in all generations older than the one being collected */
void collect_cards(CELL gen)
{
	int i;
	for(i = gen + 1; i < GC_GENERATIONS; i++)
		collect_gen_cards(i);
}

void begin_gc(CELL gen)
{
	collecting_generation = generations[gen].base;

	if(gen == TENURED)
	{
		/* when collecting the oldest generation, rotate it
		with the semispace */
		ZONE z = generations[gen];
		generations[gen] = prior;
		prior = z;
		generations[gen].here = generations[gen].base;
		newspace = &generations[gen];
		clear_cards(TENURED,TENURED);
	}
	else
	{
		/* when collecting a younger generation, we copy
		reachable objects to the next oldest generation,
		so we set the newspace so the next generation. */
		newspace = &generations[gen + 1];
	}
}

void end_gc(CELL gen)
{
	if(gen == TENURED)
	{
		/* we did a full collection; no more
		old-to-new pointers remain since everything
		is in tenured space */
		unmark_cards(TENURED,TENURED);
		/* all generations except tenured space are
		now empty */
		reset_generations(NURSERY,TENURED - 1);
	}
	else
	{
		/* we collected a younger generation. so the
		next-oldest generation no longer has any
		pointers into the younger generation (the
		younger generation is empty!) */
		unmark_cards(gen + 1,gen + 1);
		/* all generations up to and including the one
		collected are now empty */
		reset_generations(NURSERY,gen);
	}
}

/* collect gen and all younger generations */
void garbage_collection(CELL gen)
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

	/* we come back here if a generation is full */
	if(setjmp(gc_jmp))
	{
		if(gen == TENURED)
		{
			/* oops, out of memory */
			critical_error("Out of memory",0);
		}
		else
			gen++;
	}

	begin_gc(gen);

	printf("collecting generation %ld\n",gen);

	/* initialize chase pointer */
	scan = newspace->here;

	/* collect objects referenced from stacks and environment */
	collect_roots();
	
	/* collect objects referenced from older generations */
	collect_cards(gen);

	/* collect literal objects referenced from compiled code */
	collect_literals();
	
	while(scan < newspace->here)
		scan = collect_next(scan);

	end_gc(gen);

	gc_debug("gc done",gen);

	gc_in_progress = false;
	gc_time += (current_millis() - start);
	
	gc_debug("total gc time",gc_time);
}

void primitive_gc(void)
{
	CELL gen = to_fixnum(dpop());
	gen = MAX(NURSERY,MIN(TENURED,gen));
	garbage_collection(gen);
}

/* WARNING: only call this from a context where all local variables
are also reachable via the GC roots. */
void maybe_garbage_collection(void)
{
	if(nursery.here > nursery.alarm)
	{
		if(tenured.here > tenured.alarm)
		{
			printf("Major GC\n");
			garbage_collection(TENURED);
		}
		else
		{
			printf("Minor GC\n");
			garbage_collection(NURSERY);
		}
	}
}

void primitive_gc_time(void)
{
	maybe_garbage_collection();
	dpush(tag_bignum(s48_long_long_to_bignum(gc_time)));
}
