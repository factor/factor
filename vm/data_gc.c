#include "master.h"

CELL init_zone(F_ZONE *z, CELL size, CELL start)
{
	z->size = size;
	z->start = z->here = start;
	z->end = start + size;
	return z->end;
}

void init_card_decks(void)
{
	CELL start = align(data_heap->segment->start,DECK_SIZE);
	allot_markers_offset = (CELL)data_heap->allot_markers - (start >> CARD_BITS);
	cards_offset = (CELL)data_heap->cards - (start >> CARD_BITS);
	decks_offset = (CELL)data_heap->decks - (start >> DECK_BITS);
}

F_DATA_HEAP *alloc_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	CELL tenured_size)
{
	young_size = align(young_size,DECK_SIZE);
	aging_size = align(aging_size,DECK_SIZE);
	tenured_size = align(tenured_size,DECK_SIZE);

	F_DATA_HEAP *data_heap = safe_malloc(sizeof(F_DATA_HEAP));
	data_heap->young_size = young_size;
	data_heap->aging_size = aging_size;
	data_heap->tenured_size = tenured_size;
	data_heap->gen_count = gens;

	CELL total_size;
	if(data_heap->gen_count == 2)
		total_size = young_size + 2 * tenured_size;
	else if(data_heap->gen_count == 3)
		total_size = young_size + 2 * aging_size + 2 * tenured_size;
	else
	{
		fatal_error("Invalid number of generations",data_heap->gen_count);
		return NULL; /* can't happen */
	}

	total_size += DECK_SIZE;

	data_heap->segment = alloc_segment(total_size);

	data_heap->generations = safe_malloc(sizeof(F_ZONE) * data_heap->gen_count);
	data_heap->semispaces = safe_malloc(sizeof(F_ZONE) * data_heap->gen_count);

	CELL cards_size = total_size >> CARD_BITS;
	data_heap->allot_markers = safe_malloc(cards_size);
	data_heap->allot_markers_end = data_heap->allot_markers + cards_size;

	data_heap->cards = safe_malloc(cards_size);
	data_heap->cards_end = data_heap->cards + cards_size;

	CELL decks_size = total_size >> DECK_BITS;
	data_heap->decks = safe_malloc(decks_size);
	data_heap->decks_end = data_heap->decks + decks_size;

	CELL alloter = align(data_heap->segment->start,DECK_SIZE);

	alloter = init_zone(&data_heap->generations[TENURED],tenured_size,alloter);
	alloter = init_zone(&data_heap->semispaces[TENURED],tenured_size,alloter);

	if(data_heap->gen_count == 3)
	{
		alloter = init_zone(&data_heap->generations[AGING],aging_size,alloter);
		alloter = init_zone(&data_heap->semispaces[AGING],aging_size,alloter);
	}

	if(data_heap->gen_count >= 2)
	{
		alloter = init_zone(&data_heap->generations[NURSERY],young_size,alloter);
		alloter = init_zone(&data_heap->semispaces[NURSERY],0,alloter);
	}

	if(data_heap->segment->end - alloter > DECK_SIZE)
		critical_error("Bug in alloc_data_heap",alloter);

	return data_heap;
}

F_DATA_HEAP *grow_data_heap(F_DATA_HEAP *data_heap, CELL requested_bytes)
{
	CELL new_tenured_size = (data_heap->tenured_size * 2) + requested_bytes;

	return alloc_data_heap(data_heap->gen_count,
		data_heap->young_size,
		data_heap->aging_size,
		new_tenured_size);
}

void dealloc_data_heap(F_DATA_HEAP *data_heap)
{
	dealloc_segment(data_heap->segment);
	free(data_heap->generations);
	free(data_heap->semispaces);
	free(data_heap->allot_markers);
	free(data_heap->cards);
	free(data_heap->decks);
	free(data_heap);
}

void clear_cards(CELL from, CELL to)
{
	/* NOTE: reverse order due to heap layout. */
	F_CARD *first_card = ADDR_TO_CARD(data_heap->generations[to].start);
	F_CARD *last_card = ADDR_TO_CARD(data_heap->generations[from].end);
	memset(first_card,0,last_card - first_card);
}

void clear_decks(CELL from, CELL to)
{
	/* NOTE: reverse order due to heap layout. */
	F_DECK *first_deck = ADDR_TO_DECK(data_heap->generations[to].start);
	F_DECK *last_deck = ADDR_TO_DECK(data_heap->generations[from].end);
	memset(first_deck,0,last_deck - first_deck);
}

void clear_allot_markers(CELL from, CELL to)
{
	/* NOTE: reverse order due to heap layout. */
	F_CARD *first_card = ADDR_TO_ALLOT_MARKER(data_heap->generations[to].start);
	F_CARD *last_card = ADDR_TO_ALLOT_MARKER(data_heap->generations[from].end);
	memset(first_card,INVALID_ALLOT_MARKER,last_card - first_card);
}

void set_data_heap(F_DATA_HEAP *data_heap_)
{
	data_heap = data_heap_;
	nursery = data_heap->generations[NURSERY];
	init_card_decks();
	clear_cards(NURSERY,TENURED);
	clear_decks(NURSERY,TENURED);
	clear_allot_markers(NURSERY,TENURED);
}

void gc_reset(void)
{
	int i;
	for(i = 0; i < MAX_GEN_COUNT; i++)
		memset(&gc_stats[i],0,sizeof(F_GC_STATS));

	cards_scanned = 0;
	decks_scanned = 0;
	code_heap_scans = 0;
}

void init_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	CELL tenured_size,
	bool secure_gc_)
{
	set_data_heap(alloc_data_heap(gens,young_size,aging_size,tenured_size));

	gc_locals_region = alloc_segment(getpagesize());
	gc_locals = gc_locals_region->start - CELLS;

	extra_roots_region = alloc_segment(getpagesize());
	extra_roots = extra_roots_region->start - CELLS;

	secure_gc = secure_gc_;

	gc_reset();
}

/* Size of the object pointed to by a tagged pointer */
CELL object_size(CELL tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untagged_object_size(UNTAG(tagged));
}

/* Size of the object pointed to by an untagged pointer */
CELL untagged_object_size(CELL pointer)
{
	return align8(unaligned_object_size(pointer));
}

/* Size of the data area of an object pointed to by an untagged pointer */
CELL unaligned_object_size(CELL pointer)
{
	F_TUPLE *tuple;
	F_TUPLE_LAYOUT *layout;

	switch(untag_header(get(pointer)))
	{
	case ARRAY_TYPE:
	case BIGNUM_TYPE:
		return array_size(array_capacity((F_ARRAY*)pointer));
	case BYTE_ARRAY_TYPE:
		return byte_array_size(
			byte_array_capacity((F_BYTE_ARRAY*)pointer));
	case STRING_TYPE:
		return string_size(string_capacity((F_STRING*)pointer));
	case TUPLE_TYPE:
		tuple = untag_object(pointer);
		layout = untag_object(tuple->layout);
		return tuple_size(layout);
	case QUOTATION_TYPE:
		return sizeof(F_QUOTATION);
	case WORD_TYPE:
		return sizeof(F_WORD);
	case RATIO_TYPE:
		return sizeof(F_RATIO);
	case FLOAT_TYPE:
		return sizeof(F_FLOAT);
	case COMPLEX_TYPE:
		return sizeof(F_COMPLEX);
	case DLL_TYPE:
		return sizeof(F_DLL);
	case ALIEN_TYPE:
		return sizeof(F_ALIEN);
	case WRAPPER_TYPE:
		return sizeof(F_WRAPPER);
	case CALLSTACK_TYPE:
		return callstack_size(
			untag_fixnum_fast(((F_CALLSTACK *)pointer)->length));
	default:
		critical_error("Invalid header",pointer);
		return -1; /* can't happen */
	}
}

void primitive_size(void)
{
	box_unsigned_cell(object_size(dpop()));
}

/* Push memory usage statistics in data heap */
void primitive_data_room(void)
{
	F_ARRAY *a = allot_array(ARRAY_TYPE,data_heap->gen_count * 2,F);
	int gen;

	dpush(tag_fixnum((data_heap->cards_end - data_heap->cards) >> 10));
	dpush(tag_fixnum((data_heap->decks_end - data_heap->decks) >> 10));

	for(gen = 0; gen < data_heap->gen_count; gen++)
	{
		F_ZONE *z = (gen == NURSERY ? &nursery : &data_heap->generations[gen]);
		set_array_nth(a,gen * 2,tag_fixnum((z->end - z->here) >> 10));
		set_array_nth(a,gen * 2 + 1,tag_fixnum((z->size) >> 10));
	}

	dpush(tag_object(a));
}

/* Disables GC and activates next-object ( -- obj ) primitive */
void begin_scan(void)
{
	heap_scan_ptr = data_heap->generations[TENURED].start;
	gc_off = true;
}

void primitive_begin_scan(void)
{
	gc();
	begin_scan();
}

CELL next_object(void)
{
	if(!gc_off)
		general_error(ERROR_HEAP_SCAN,F,F,NULL);

	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;
	CELL type;

	if(heap_scan_ptr >= data_heap->generations[TENURED].here)
		return F;

	type = untag_header(value);
	heap_scan_ptr += untagged_object_size(heap_scan_ptr);

	return RETAG(obj,type <= HEADER_TYPE ? type : OBJECT_TYPE);
}

/* Push object at heap scan cursor and advance; pushes f when done */
void primitive_next_object(void)
{
	dpush(next_object());
}

/* Re-enables GC */
void primitive_end_scan(void)
{
	gc_off = false;
}

/* Scan all the objects in the card */
void collect_card(F_CARD *ptr, CELL gen, CELL here)
{
	CELL card_scan = (CELL)CARD_TO_ADDR(ptr) + CARD_OFFSET(ptr);
	CELL card_end = (CELL)CARD_TO_ADDR(ptr + 1);

	if(here < card_end)
		card_end = here;

	collect_next_loop(card_scan,&card_end);

	cards_scanned++;
}

void collect_card_deck(F_DECK *deck, CELL gen, F_CARD mask, F_CARD unmask)
{
	F_CARD *first_card = DECK_TO_CARD(deck);
	F_CARD *last_card = DECK_TO_CARD(deck + 1);

	CELL here = data_heap->generations[gen].here;

	u32 *quad_ptr;
	u32 quad_mask = mask | (mask << 8) | (mask << 16) | (mask << 24);

	for(quad_ptr = (u32 *)first_card; quad_ptr < (u32 *)last_card; quad_ptr++)
	{
		if(*quad_ptr & quad_mask)
		{
			F_CARD *ptr = (F_CARD *)quad_ptr;

			int card;
			for(card = 0; card < 4; card++)
			{
				if(ptr[card] & mask)
				{
					collect_card(&ptr[card],gen,here);
					ptr[card] &= ~unmask;
				}
			}
		}
	}

	decks_scanned++;
}

/* Copy all newspace objects referenced from marked cards to the destination */
void collect_gen_cards(CELL gen)
{
	F_DECK *first_deck = ADDR_TO_DECK(data_heap->generations[gen].start);
	F_DECK *last_deck = ADDR_TO_DECK(data_heap->generations[gen].end);

	F_CARD mask, unmask;

	/* if we are collecting the nursery, we care about old->nursery pointers
	but not old->aging pointers */
	if(collecting_gen == NURSERY)
	{
		mask = CARD_POINTS_TO_NURSERY;

		/* after the collection, no old->nursery pointers remain
		anywhere, but old->aging pointers might remain in tenured
		space */
		if(gen == TENURED)
			unmask = CARD_POINTS_TO_NURSERY;
		/* after the collection, all cards in aging space can be
		cleared */
		else if(HAVE_AGING_P && gen == AGING)
			unmask = CARD_MARK_MASK;
		else
		{
			critical_error("bug in collect_gen_cards",gen);
			return;
		}
	}
	/* if we are collecting aging space into tenured space, we care about
	all old->nursery and old->aging pointers. no old->aging pointers can
	remain */
	else if(HAVE_AGING_P && collecting_gen == AGING)
	{
		if(collecting_aging_again)
		{
			mask = CARD_POINTS_TO_AGING;
			unmask = CARD_MARK_MASK;
		}
		/* after we collect aging space into the aging semispace, no
		old->nursery pointers remain but tenured space might still have
		pointers to aging space. */
		else
		{
			mask = CARD_POINTS_TO_AGING;
			unmask = CARD_POINTS_TO_NURSERY;
		}
	}
	else
	{
		critical_error("bug in collect_gen_cards",gen);
		return;
	}

	F_DECK *ptr;

	for(ptr = first_deck; ptr < last_deck; ptr++)
	{
		if(*ptr & mask)
		{
			collect_card_deck(ptr,gen,mask,unmask);
			*ptr &= ~unmask;
		}
	}
}

/* Scan cards in all generations older than the one being collected, copying
old->new references */
void collect_cards(void)
{
	int i;
	for(i = collecting_gen + 1; i < data_heap->gen_count; i++)
		collect_gen_cards(i);
}

/* Copy all tagged pointers in a range of memory */
void collect_stack(F_SEGMENT *region, CELL top)
{
	CELL ptr = region->start;

	for(; ptr <= top; ptr += CELLS)
		copy_handle((CELL*)ptr);
}

void collect_stack_frame(F_STACK_FRAME *frame)
{
	recursive_mark(compiled_to_block(frame_code(frame)));
}

/* The base parameter allows us to adjust for a heap-allocated
callstack snapshot */
void collect_callstack(F_CONTEXT *stacks)
{
	if(collecting_gen == TENURED)
	{
		CELL top = (CELL)stacks->callstack_top;
		CELL bottom = (CELL)stacks->callstack_bottom;

		iterate_callstack(top,bottom,collect_stack_frame);
	}
}

void collect_gc_locals(void)
{
	CELL ptr = gc_locals_region->start;

	for(; ptr <= gc_locals; ptr += CELLS)
		copy_handle(*(CELL **)ptr);
}

/* Copy roots over at the start of GC, namely various constants, stacks,
the user environment and extra roots registered with REGISTER_ROOT */
void collect_roots(void)
{
	copy_handle(&T);
	copy_handle(&bignum_zero);
	copy_handle(&bignum_pos_one);
	copy_handle(&bignum_neg_one);

	collect_gc_locals();
	collect_stack(extra_roots_region,extra_roots);

	save_stacks();
	F_CONTEXT *stacks = stack_chain;

	while(stacks)
	{
		collect_stack(stacks->datastack_region,stacks->datastack);
		collect_stack(stacks->retainstack_region,stacks->retainstack);

		copy_handle(&stacks->catchstack_save);
		copy_handle(&stacks->current_callback_save);

		collect_callstack(stacks);

		stacks = stacks->next;
	}

	int i;
	for(i = 0; i < USER_ENV; i++)
		copy_handle(&userenv[i]);
}

/* Given a pointer to oldspace, copy it to newspace */
INLINE void *copy_untagged_object(void *pointer, CELL size)
{
	if(newspace->here + size >= newspace->end)
		longjmp(gc_jmp,1);
	allot_barrier(newspace->here);
	void *newpointer = allot_zone(newspace,size);

	F_GC_STATS *s = &gc_stats[collecting_gen];
	s->object_count++;
	s->bytes_copied += size;

	memcpy(newpointer,pointer,size);
	return newpointer;
}

INLINE void forward_object(CELL pointer, CELL newpointer)
{
	if(pointer != newpointer)
		put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));
}

INLINE CELL copy_object_impl(CELL pointer)
{
	CELL newpointer = (CELL)copy_untagged_object(
		(void*)UNTAG(pointer),
		object_size(pointer));
	forward_object(pointer,newpointer);
	return newpointer;
}

/* Follow a chain of forwarding pointers */
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

/* Given a pointer to a tagged pointer to oldspace, copy it to newspace.
If the object has already been copied, return the forwarding
pointer address without copying anything; otherwise, install
a new forwarding pointer. */
INLINE CELL copy_object(CELL pointer)
{
	CELL tag = TAG(pointer);
	CELL header = get(UNTAG(pointer));

	if(TAG(header) == GC_COLLECTED)
		return resolve_forwarding(UNTAG(header),tag);
	else
		return RETAG(copy_object_impl(pointer),tag);
}

void copy_handle(CELL *handle)
{
	CELL pointer = *handle;

	if(!immediate_p(pointer) && should_copy(pointer))
		*handle = copy_object(pointer);
}

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
CELL binary_payload_start(CELL pointer)
{
	F_TUPLE *tuple;
	F_TUPLE_LAYOUT *layout;

	switch(untag_header(get(pointer)))
	{
	/* these objects do not refer to other objects at all */
	case FLOAT_TYPE:
	case BYTE_ARRAY_TYPE:
	case BIGNUM_TYPE:
	case CALLSTACK_TYPE:
		return 0;
	/* these objects have some binary data at the end */
	case WORD_TYPE:
		return sizeof(F_WORD) - CELLS * 3;
	case ALIEN_TYPE:
		return CELLS * 3;
	case DLL_TYPE:
		return CELLS * 2;
	case QUOTATION_TYPE:
		return sizeof(F_QUOTATION) - CELLS * 2;
	case STRING_TYPE:
		return sizeof(F_STRING);
	/* everything else consists entirely of pointers */
	case ARRAY_TYPE:
		return array_size(array_capacity((F_ARRAY*)pointer));
	case TUPLE_TYPE:
		tuple = untag_object(pointer);
		layout = untag_object(tuple->layout);
		return tuple_size(layout);
	case RATIO_TYPE:
		return sizeof(F_RATIO);
	case COMPLEX_TYPE:
		return sizeof(F_COMPLEX);
	case WRAPPER_TYPE:
		return sizeof(F_WRAPPER);
	default:
		critical_error("Invalid header",pointer);
		return -1; /* can't happen */
	}
}

void do_code_slots(CELL scan)
{
	F_WORD *word;
	F_QUOTATION *quot;
	F_CALLSTACK *stack;

	switch(object_type(scan))
	{
	case WORD_TYPE:
		word = (F_WORD *)scan;
		recursive_mark(compiled_to_block(word->code));
		if(word->profiling)
			recursive_mark(compiled_to_block(word->profiling));
		break;
	case QUOTATION_TYPE:
		quot = (F_QUOTATION *)scan;
		if(quot->compiledp != F)
			recursive_mark(compiled_to_block(quot->code));
		break;
	case CALLSTACK_TYPE:
		stack = (F_CALLSTACK *)scan;
		iterate_callstack_object(stack,collect_stack_frame);
		break;
	}
}

CELL collect_next_nursery(CELL scan)
{
	CELL *obj = (CELL *)scan;
	CELL *end = (CELL *)(scan + binary_payload_start(scan));

	if(obj != end)
	{
		obj++;

		CELL nursery_start = nursery.start;
		CELL nursery_end = nursery.end;

		for(; obj < end; obj++)
		{
			CELL pointer = *obj;

			if(!immediate_p(pointer)
				&& (pointer >= nursery_start && pointer < nursery_end))
				*obj = copy_object(pointer);
		}
	}

	return scan + untagged_object_size(scan);
}

CELL collect_next_aging(CELL scan)
{
	CELL *obj = (CELL *)scan;
	CELL *end = (CELL *)(scan + binary_payload_start(scan));

	if(obj != end)
	{
		obj++;

		CELL tenured_start = data_heap->generations[TENURED].start;
		CELL tenured_end = data_heap->generations[TENURED].end;

		CELL newspace_start = newspace->start;
		CELL newspace_end = newspace->end;

		for(; obj < end; obj++)
		{
			CELL pointer = *obj;

			if(!immediate_p(pointer)
				&& !(pointer >= newspace_start && pointer < newspace_end)
				&& !(pointer >= tenured_start && pointer < tenured_end))
				*obj = copy_object(pointer);
		}
	}

	return scan + untagged_object_size(scan);
}

/* This function is performance-critical */
CELL collect_next_tenured(CELL scan)
{
	CELL *obj = (CELL *)scan;
	CELL *end = (CELL *)(scan + binary_payload_start(scan));

	if(obj != end)
	{
		obj++;

		CELL newspace_start = newspace->start;
		CELL newspace_end = newspace->end;

		for(; obj < end; obj++)
		{
			CELL pointer = *obj;

			if(!immediate_p(pointer) && !(pointer >= newspace_start && pointer < newspace_end))
				*obj = copy_object(pointer);
		}
	}

	do_code_slots(scan);

	return scan + untagged_object_size(scan);
}

void collect_next_loop(CELL scan, CELL *end)
{
	if(HAVE_NURSERY_P && collecting_gen == NURSERY)
	{
		while(scan < *end)
			scan = collect_next_nursery(scan);
	}
	else if(HAVE_AGING_P && collecting_gen == AGING)
	{
		while(scan < *end)
			scan = collect_next_aging(scan);
	}
	else if(collecting_gen == TENURED)
	{
		while(scan < *end)
			scan = collect_next_tenured(scan);
	}
}

INLINE void reset_generation(CELL i)
{
	F_ZONE *z = (i == NURSERY ? &nursery : &data_heap->generations[i]);

	z->here = z->start;
	if(secure_gc)
		memset((void*)z->start,69,z->size);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void reset_generations(CELL from, CELL to)
{
	CELL i;
	for(i = from; i <= to; i++)
		reset_generation(i);

	clear_cards(from,to);
	clear_decks(from,to);
	clear_allot_markers(from,to);
}

/* Prepare to start copying reachable objects into an unused zone */
void begin_gc(CELL requested_bytes)
{
	if(growing_data_heap)
	{
		if(collecting_gen != TENURED)
			critical_error("Invalid parameters to begin_gc",0);

		old_data_heap = data_heap;
		set_data_heap(grow_data_heap(old_data_heap,requested_bytes));
		newspace = &data_heap->generations[TENURED];
	}
	else if(collecting_accumulation_gen_p())
	{
		/* when collecting one of these generations, rotate it
		with the semispace */
		F_ZONE z = data_heap->generations[collecting_gen];
		data_heap->generations[collecting_gen] = data_heap->semispaces[collecting_gen];
		data_heap->semispaces[collecting_gen] = z;
		reset_generation(collecting_gen);
		newspace = &data_heap->generations[collecting_gen];
		clear_cards(collecting_gen,collecting_gen);
		clear_decks(collecting_gen,collecting_gen);
		clear_allot_markers(collecting_gen,collecting_gen);
	}
	else
	{
		/* when collecting a younger generation, we copy
		reachable objects to the next oldest generation,
		so we set the newspace so the next generation. */
		newspace = &data_heap->generations[collecting_gen + 1];
	}
}

void end_gc(CELL gc_elapsed)
{
	F_GC_STATS *s = &gc_stats[collecting_gen];

	s->collections++;
	s->gc_time += gc_elapsed;
	if(s->max_gc_time < gc_elapsed)
		s->max_gc_time = gc_elapsed;

	if(growing_data_heap)
	{
		dealloc_data_heap(old_data_heap);
		old_data_heap = NULL;
		growing_data_heap = false;
	}

	if(collecting_accumulation_gen_p())
	{
		/* all younger generations except are now empty.
		if collecting_gen == NURSERY here, we only have 1 generation;
		old-school Cheney collector */
		if(collecting_gen != NURSERY)
			reset_generations(NURSERY,collecting_gen - 1);
	}
	else if(HAVE_NURSERY_P && collecting_gen == NURSERY)
	{
		nursery.here = nursery.start;
	}
	else
	{
		/* all generations up to and including the one
		collected are now empty */
		reset_generations(NURSERY,collecting_gen);
	}

	if(collecting_gen == TENURED)
	{
		/* now that all reachable code blocks have been marked,
		deallocate the rest */
		free_unmarked(&code_heap);
	}

	collecting_aging_again = false;
}

/* Collect gen and all younger generations.
If growing_data_heap_ is true, we must grow the data heap to such a size that
an allocation of requested_bytes won't fail */
void garbage_collection(CELL gen,
	bool growing_data_heap_,
	CELL requested_bytes)
{
	if(gc_off)
	{
		critical_error("GC disabled",gen);
		return;
	}

	s64 start = current_micros();

	performing_gc = true;
	growing_data_heap = growing_data_heap_;
	collecting_gen = gen;

	/* we come back here if a generation is full */
	if(setjmp(gc_jmp))
	{
		/* We have no older generations we can try collecting, so we
		resort to growing the data heap */
		if(collecting_gen == TENURED)
		{
			growing_data_heap = true;

			/* see the comment in unmark_marked() */
			unmark_marked(&code_heap);
		}
		/* we try collecting AGING space twice before going on to
		collect TENURED */
		else if(HAVE_AGING_P
			&& collecting_gen == AGING
			&& !collecting_aging_again)
		{
			collecting_aging_again = true;
		}
		/* Collect the next oldest generation */
		else
		{
			collecting_gen++;
		}
	}

	begin_gc(requested_bytes);

	/* initialize chase pointer */
	CELL scan = newspace->here;

	/* collect objects referenced from stacks and environment */
	collect_roots();
	/* collect objects referenced from older generations */
	collect_cards();

	/* don't scan code heap unless it has pointers to this
	generation or younger */
	if(collecting_gen >= last_code_heap_scan)
	{
		if(collecting_gen != TENURED)
		{
		
			/* if we are doing code GC, then we will copy over
			literals from any code block which gets marked as live.
			if we are not doing code GC, just consider all literals
			as roots. */
			code_heap_scans++;

			collect_literals();
		}

		if(collecting_accumulation_gen_p())
			last_code_heap_scan = collecting_gen;
		else
			last_code_heap_scan = collecting_gen + 1;
	}

	collect_next_loop(scan,&newspace->here);

	CELL gc_elapsed = (current_micros() - start);

	end_gc(gc_elapsed);

	performing_gc = false;
}

void gc(void)
{
	garbage_collection(TENURED,false,0);
}

void minor_gc(void)
{
	garbage_collection(NURSERY,false,0);
}

void primitive_gc(void)
{
	gc();
}

void primitive_gc_stats(void)
{
	GROWABLE_ARRAY(stats);

	CELL i;
	u64 total_gc_time = 0;

	for(i = 0; i < MAX_GEN_COUNT; i++)
	{
		F_GC_STATS *s = &gc_stats[i];
		GROWABLE_ARRAY_ADD(stats,allot_cell(s->collections));
		GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(s->gc_time)));
		GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(s->max_gc_time)));
		GROWABLE_ARRAY_ADD(stats,allot_cell(s->collections == 0 ? 0 : s->gc_time / s->collections));
		GROWABLE_ARRAY_ADD(stats,allot_cell(s->object_count));
		GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(s->bytes_copied)));

		total_gc_time += s->gc_time;
	}

	GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(total_gc_time)));
	GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(cards_scanned)));
	GROWABLE_ARRAY_ADD(stats,tag_bignum(long_long_to_bignum(decks_scanned)));
	GROWABLE_ARRAY_ADD(stats,allot_cell(code_heap_scans));

	GROWABLE_ARRAY_TRIM(stats);
	dpush(stats);
}

void primitive_gc_reset(void)
{
	gc_reset();
}

void primitive_become(void)
{
	F_ARRAY *new_objects = untag_array(dpop());
	F_ARRAY *old_objects = untag_array(dpop());

	CELL capacity = array_capacity(new_objects);
	if(capacity != array_capacity(old_objects))
		critical_error("bad parameters to become",0);

	CELL i;

	for(i = 0; i < capacity; i++)
	{
		CELL old_obj = array_nth(old_objects,i);
		CELL new_obj = array_nth(new_objects,i);

		forward_object(old_obj,new_obj);
	}

	gc();

	compile_all_words();
}

CELL find_all_words(void)
{
	GROWABLE_ARRAY(words);

	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
			GROWABLE_ARRAY_ADD(words,obj);
	}

	/* End heap scan */
	gc_off = false;

	GROWABLE_ARRAY_TRIM(words);

	return words;
}
