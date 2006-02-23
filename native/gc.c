#include "factor.h"

/* Generational copying garbage collector */

CELL init_zone(ZONE *z, CELL size, CELL base)
{
	z->base = z->here = base;
	z->limit = z->base + size;
	z->alarm = z->base + (size * 3) / 4;
	return z->limit;
}

/* input parameters must be 8 byte aligned */
/* the heap layout is important:
- two semispaces: tenured and prior
- younger generations follow
there are two reasons for this:
- we can easily check if a pointer is in some generation or a younger one
- the nursery grows into the guard page, so allot() does not have to
check for out of memory, whereas allot_zone() (used by the GC) longjmp()s
back to collecting a higher generation */
void init_arena(CELL gens, CELL young_size, CELL aging_size)
{
	int i;
	CELL alloter;

	CELL total_size = (gens - 1) * young_size + 2 * aging_size;
	CELL cards_size = total_size / CARD_SIZE;

	gen_count = gens;
	generations = safe_malloc(sizeof(ZONE) * gen_count);

	heap_start = (CELL)(alloc_bounded_block(total_size)->start);
	heap_end = heap_start + total_size;

	cards = safe_malloc(cards_size);
	cards_end = cards + cards_size;
	cards_offset = (CELL)cards - (heap_start >> CARD_BITS);

	alloter = heap_start;

	alloter = init_zone(&tenured,aging_size,alloter);
	alloter = init_zone(&prior,aging_size,alloter);

	for(i = gen_count - 2; i >= 0; i--)
		alloter = init_zone(&generations[i],young_size,alloter);

	clear_cards(NURSERY,TENURED);

	if(alloter != heap_start + total_size)
		fatal_error("Oops",alloter);

	heap_scan = false;
	gc_time = 0;
	minor_collections = 0;
	cards_scanned = 0;
}

void collect_roots(void)
{
	int i;
	CELL ptr;
	STACKS *stacks;

	copy_handle(&T);
	copy_handle(&bignum_zero);
	copy_handle(&bignum_pos_one);
	copy_handle(&bignum_neg_one);
	copy_handle(&executing);
	copy_handle(&callframe);

	save_stacks();
	stacks = stack_chain;

	while(stacks)
	{
		/* these two pointers are only set in inactive states */
		if(stacks != stack_chain)
		{
			copy_handle(&stacks->callframe);
			copy_handle(&stacks->catch_save);
		}

		CELL bottom = stacks->data_region->start;
		CELL top = stacks->data;
		
		for(ptr = bottom; ptr <= top; ptr += CELLS)
			copy_handle((CELL*)ptr);
	
		bottom = stacks->call_region->start;
		top = stacks->call;
		
		for(ptr = bottom; ptr <= top; ptr += CELLS)
			copy_handle((CELL*)ptr);
		
		stacks = stacks->next;
	}

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
	CELL newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
		object_size(pointer));

	/* install forwarding pointer */
	put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));

	return newpointer;
}

/* follow a chain of forwarding pointers */
CELL resolve_forwarding(CELL untagged, CELL tag)
{
	CELL header = get(untagged);
	/* another forwarding pointer */
	if(TAG(header) == GC_COLLECTED)
		return resolve_forwarding(UNTAG(header),tag);
	/* we've found the destination */
	else
	{
		CELL pointer = RETAG(untagged,tag);
		if(should_copy(untagged))
			pointer = RETAG(copy_object_impl(pointer),tag);
		return pointer;
	}
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

	gc_debug("copy object",pointer);

	if(pointer == F)
		return F;

	tag = TAG(pointer);

	if(tag == FIXNUM_TYPE)
		return pointer;

	header = get(UNTAG(pointer));
	if(TAG(header) == GC_COLLECTED)
		return resolve_forwarding(UNTAG(header),tag);
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
	case ALIEN_TYPE:
		collect_alien((ALIEN*)scan);
		break;
	case WRAPPER_TYPE:
		collect_wrapper((F_WRAPPER*)scan);
		break;
	}
}

CELL collect_next(CELL scan)
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

void reset_generations(CELL from, CELL to)
{
	CELL i;
	for(i = from; i <= to; i++)
		generations[i].here = generations[i].base;
	clear_cards(from,to);
}

void begin_gc(CELL gen)
{
	collecting_gen = gen;
	collecting_gen_start = generations[gen].base;

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

		fprintf(stderr,"*** Major GC (%ld minor, %ld cards)\n",
			minor_collections,cards_scanned);
		minor_collections = 0;
		cards_scanned = 0;
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
		
		minor_collections++;
	}
}

/* collect gen and all younger generations */
void garbage_collection(CELL gen)
{
	s64 start = current_millis();
	CELL scan;

	if(heap_scan)
		critical_error("GC disabled during heap scan",gen);

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

	gc_time += (current_millis() - start);
	
	gc_debug("total gc time",gc_time);
}

void primitive_gc(void)
{
	CELL gen = to_fixnum(dpop());
	if(gen <= NURSERY)
		gen = NURSERY;
	else if(gen >= TENURED)
		gen = TENURED;
	garbage_collection(gen);
}

/* WARNING: only call this from a context where all local variables
are also reachable via the GC roots. */
void maybe_gc(CELL size)
{
	if(nursery.here + size > nursery.alarm)
	{
		CELL gen = NURSERY;
		while(gen < TENURED)
		{
			ZONE *z = &generations[gen + 1];
			if(z->here < z->alarm)
				break;
			gen++;
		}

		garbage_collection(gen);
	}
}

void simple_gc(void)
{
	maybe_gc(0);
}

void primitive_gc_time(void)
{
	simple_gc();
	dpush(tag_bignum(s48_long_long_to_bignum(gc_time)));
}
