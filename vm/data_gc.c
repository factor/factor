#include "master.h"

CELL init_zone(F_ZONE *z, CELL size, CELL start)
{
	z->size = size;
	z->start = z->here = start;
	z->end = start + size;
	return z->end;
}

void init_cards_offset(void)
{
	cards_offset = (CELL)data_heap->cards
		- (data_heap->segment->start >> CARD_BITS);
}

F_DATA_HEAP *alloc_data_heap(CELL gens, CELL young_size, CELL aging_size)
{
	young_size = align_page(young_size);
	aging_size = align_page(aging_size);

	F_DATA_HEAP *data_heap = safe_malloc(sizeof(F_DATA_HEAP));
	data_heap->young_size = young_size;
	data_heap->aging_size = aging_size;
	data_heap->gen_count = gens;

	CELL total_size;
	if(data_heap->gen_count == 1)
		total_size = 2 * aging_size;
	else if(data_heap->gen_count == 2)
		total_size = (gens - 1) * young_size + 2 * aging_size;
	else if(data_heap->gen_count == 3)
		total_size = gens * young_size + 2 * aging_size;
	else
	{
		fatal_error("Invalid number of generations",data_heap->gen_count);
		return NULL; /* can't happen */
	}

	data_heap->segment = alloc_segment(total_size);

	data_heap->generations = safe_malloc(sizeof(F_ZONE) * gens);
	data_heap->semispaces = safe_malloc(sizeof(F_ZONE) * gens);

	CELL cards_size = total_size / CARD_SIZE;
	data_heap->cards = safe_malloc(cards_size);
	data_heap->cards_end = data_heap->cards + cards_size;

	CELL alloter = data_heap->segment->start;

	alloter = init_zone(&data_heap->semispaces[NURSERY],0,alloter);

	alloter = init_zone(&data_heap->generations[TENURED],aging_size,alloter);
	alloter = init_zone(&data_heap->semispaces[TENURED],aging_size,alloter);

	int i;

	if(data_heap->gen_count > 2)
	{
		alloter = init_zone(&data_heap->generations[AGING],young_size,alloter);
		alloter = init_zone(&data_heap->semispaces[AGING],young_size,alloter);

		for(i = gens - 3; i >= 0; i--)
		{
			alloter = init_zone(&data_heap->generations[i],
				young_size,alloter);
		}
	}
	else
	{
		for(i = gens - 2; i >= 0; i--)
		{
			alloter = init_zone(&data_heap->generations[i],
				young_size,alloter);
		}
	}

	if(alloter != data_heap->segment->end)
		critical_error("Bug in alloc_data_heap",alloter);

	return data_heap;
}

F_DATA_HEAP *grow_data_heap(F_DATA_HEAP *data_heap, CELL requested_bytes)
{
	CELL new_young_size = (data_heap->young_size * 2) + requested_bytes;
	CELL new_aging_size = (data_heap->aging_size * 2) + requested_bytes;

	return alloc_data_heap(data_heap->gen_count,
		new_young_size,
		new_aging_size);
}

void dealloc_data_heap(F_DATA_HEAP *data_heap)
{
	dealloc_segment(data_heap->segment);
	free(data_heap->generations);
	free(data_heap->semispaces);
	free(data_heap->cards);
	free(data_heap);
}

/* Every card stores the offset of the first object in that card, which must be
cleared when a generation has been cleared */
void clear_cards(CELL from, CELL to)
{
	/* NOTE: reverse order due to heap layout. */
	F_CARD *last_card = ADDR_TO_CARD(data_heap->generations[from].end);
	F_CARD *ptr = ADDR_TO_CARD(data_heap->generations[to].start);
	for(; ptr < last_card; ptr++)
		clear_card(ptr);
}

void set_data_heap(F_DATA_HEAP *data_heap_)
{
	data_heap = data_heap_;
	nursery = &data_heap->generations[NURSERY];
	init_cards_offset();
	clear_cards(NURSERY,TENURED);
}

void init_data_heap(CELL gens,
	CELL young_size,
	CELL aging_size,
	bool secure_gc_)
{
	set_data_heap(alloc_data_heap(gens,young_size,aging_size));

	extra_roots_region = alloc_segment(getpagesize());
	extra_roots = extra_roots_region->start - CELLS;

	gc_time = 0;
	minor_collections = 0;
	cards_scanned = 0;
	secure_gc = secure_gc_;
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
	switch(untag_header(get(pointer)))
	{
	case ARRAY_TYPE:
	case TUPLE_TYPE:
	case BIGNUM_TYPE:
		return array_size(array_capacity((F_ARRAY*)pointer));
	case BYTE_ARRAY_TYPE:
		return byte_array_size(
			byte_array_capacity((F_BYTE_ARRAY*)pointer));
	case BIT_ARRAY_TYPE:
		return bit_array_size(
			bit_array_capacity((F_BIT_ARRAY*)pointer));
	case FLOAT_ARRAY_TYPE:
		return float_array_size(
			float_array_capacity((F_FLOAT_ARRAY*)pointer));
	case STRING_TYPE:
		return string_size(string_capacity((F_STRING*)pointer));
	case QUOTATION_TYPE:
		return sizeof(F_QUOTATION);
	case WORD_TYPE:
		return sizeof(F_WORD);
	case HASHTABLE_TYPE:
		return sizeof(F_HASHTABLE);
	case VECTOR_TYPE:
		return sizeof(F_VECTOR);
	case SBUF_TYPE:
		return sizeof(F_SBUF);
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
	case CURRY_TYPE:
		return sizeof(F_CURRY);
	case CALLSTACK_TYPE:
		return callstack_size(
			untag_fixnum_fast(((F_CALLSTACK *)pointer)->length));
	default:
		critical_error("Invalid header",pointer);
		return -1; /* can't happen */
	}
}

DEFINE_PRIMITIVE(size)
{
	box_unsigned_cell(object_size(dpop()));
}

/* Push memory usage statistics in data heap */
DEFINE_PRIMITIVE(data_room)
{
	F_ARRAY *a = allot_array(ARRAY_TYPE,data_heap->gen_count * 2,F);
	int gen;

	dpush(tag_fixnum((data_heap->cards_end - data_heap->cards) >> 10));

	for(gen = 0; gen < data_heap->gen_count; gen++)
	{
		F_ZONE *z = &data_heap->generations[gen];
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

DEFINE_PRIMITIVE(begin_scan)
{
	data_gc();
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
DEFINE_PRIMITIVE(next_object)
{
	dpush(next_object());
}

/* Re-enables GC */
DEFINE_PRIMITIVE(end_scan)
{
	gc_off = false;
}

/* Scan all the objects in the card */
INLINE void collect_card(F_CARD *ptr, CELL gen, CELL here)
{
	F_CARD c = *ptr;
	CELL offset = (c & CARD_BASE_MASK);

	if(offset == CARD_BASE_MASK)
	{
		if(c == 0xff)
			critical_error("bad card",(CELL)ptr);
		else
			return;
	}

	CELL card_scan = (CELL)CARD_TO_ADDR(ptr) + offset;
	CELL card_end = (CELL)CARD_TO_ADDR(ptr + 1);

	while(card_scan < card_end && card_scan < here)
		card_scan = collect_next(card_scan);

	cards_scanned++;
}

/* Copy all newspace objects referenced from marked cards to the destination */
INLINE void collect_gen_cards(CELL gen)
{
	F_CARD *ptr = ADDR_TO_CARD(data_heap->generations[gen].start);
	CELL here = data_heap->generations[gen].here;
	F_CARD *last_card = ADDR_TO_CARD(here - 1);

	CELL mask, unmask;

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

	for(; ptr <= last_card; ptr++)
	{
		if(*ptr & mask)
		{
			collect_card(ptr,gen,here);
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
	CELL bottom = region->start;
	CELL ptr;

	for(ptr = bottom; ptr <= top; ptr += CELLS)
		copy_handle((CELL*)ptr);
}

void collect_stack_frame(F_STACK_FRAME *frame)
{
	if(frame_type(frame) == QUOTATION_TYPE)
	{
		CELL scan = frame->scan - frame->array;
		copy_handle(&frame->array);
		frame->scan = scan + frame->array;
	}

	if(collecting_code)
		recursive_mark(frame->xt);
}

/* The base parameter allows us to adjust for a heap-allocated
callstack snapshot */
void collect_callstack(F_CONTEXT *stacks)
{
	CELL top = (CELL)stacks->callstack_top;
	CELL bottom = (CELL)stacks->callstack_bottom;
	CELL base = bottom;
	iterate_callstack(top,bottom,base,collect_stack_frame);
}

/* Copy roots over at the start of GC, namely various constants, stacks,
the user environment and extra roots registered with REGISTER_ROOT */
void collect_roots(void)
{
	int i;
	F_CONTEXT *stacks;

	copy_handle(&T);
	copy_handle(&bignum_zero);
	copy_handle(&bignum_pos_one);
	copy_handle(&bignum_neg_one);

	collect_stack(extra_roots_region,extra_roots);

	save_stacks();
	stacks = stack_chain;

	while(stacks)
	{
		collect_stack(stacks->datastack_region,stacks->datastack);
		collect_stack(stacks->retainstack_region,stacks->retainstack);

		copy_handle(&stacks->catchstack_save);
		copy_handle(&stacks->current_callback_save);

		collect_callstack(stacks);

		stacks = stacks->next;
	}

	for(i = 0; i < USER_ENV; i++)
		copy_handle(&userenv[i]);
}

/* Given a pointer to oldspace, copy it to newspace */
INLINE void *copy_untagged_object(void *pointer, CELL size)
{
	void *newpointer;
	if(newspace->here + size >= newspace->end)
		longjmp(gc_jmp,1);
	allot_barrier(newspace->here);
	newpointer = allot_zone(newspace,size);
	memcpy(newpointer,pointer,size);
	return newpointer;
}

INLINE void forward_object(CELL pointer, CELL newpointer)
{
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
	switch(untag_header(get(pointer)))
	{
	/* these objects do not refer to other objects at all */
	case STRING_TYPE:
	case FLOAT_TYPE:
	case BYTE_ARRAY_TYPE:
	case BIT_ARRAY_TYPE:
	case FLOAT_ARRAY_TYPE:
	case BIGNUM_TYPE:
	case CALLSTACK_TYPE:
		return 0;
	/* these objects have some binary data at the end */
	case WORD_TYPE:
		return sizeof(F_WORD) - CELLS;
	case ALIEN_TYPE:
		return CELLS * 3;
	case DLL_TYPE:
		return CELLS * 2;
	case QUOTATION_TYPE:
		return sizeof(F_QUOTATION) - CELLS;
	/* everything else consists entirely of pointers */
	default:
		return unaligned_object_size(pointer);
	}
}

void collect_callstack_object(F_CALLSTACK *callstack)
{
	iterate_callstack_object(callstack,collect_stack_frame);
}

CELL collect_next(CELL scan)
{
	do_slots(scan,copy_handle);

	/* Special behaviors */
	F_WORD *word;
	F_QUOTATION *quot;
	F_CALLSTACK *stack;

	switch(object_type(scan))
	{
	case WORD_TYPE:
		word = (F_WORD *)scan;
		if(collecting_code && word->compiledp != F)
			recursive_mark(word->xt);
		break;
	case QUOTATION_TYPE:
		quot = (F_QUOTATION *)scan;
		if(collecting_code && quot->xt != NULL)
			recursive_mark(quot->xt);
		break;
	case CALLSTACK_TYPE:
		stack = (F_CALLSTACK *)scan;
		collect_callstack_object(stack);
		break;
	}

	return scan + untagged_object_size(scan);
}

INLINE void reset_generation(CELL i)
{
	F_ZONE *z = &data_heap->generations[i];
	z->here = z->start;
	if(secure_gc)
		memset((void*)z->start,69,z->size);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void reset_generations(CELL from, CELL to)
{
	CELL i;
	for(i = from; i <= to; i++) reset_generation(i);
	clear_cards(from,to);
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
		newspace = &data_heap->generations[collecting_gen];
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
	}
	else
	{
		/* when collecting a younger generation, we copy
		reachable objects to the next oldest generation,
		so we set the newspace so the next generation. */
		newspace = &data_heap->generations[collecting_gen + 1];
	}
}

void major_gc_message(void)
{
	fprintf(stderr,"*** %s GC (%ld minor, %ld cards)\n",
		collecting_code ? "Code and data" : "Data",
		minor_collections,cards_scanned);
	fflush(stderr);
	minor_collections = 0;
	cards_scanned = 0;
}

void end_gc(void)
{
	if(growing_data_heap)
	{
		dealloc_data_heap(old_data_heap);
		old_data_heap = NULL;
		growing_data_heap = false;

		fprintf(stderr,"*** Data heap resized to %lu bytes\n",
			data_heap->segment->size);
	}

	if(collecting_accumulation_gen_p())
	{
		/* all younger generations except are now empty.
		if collecting_gen == NURSERY here, we only have 1 generation;
		old-school Cheney collector */
		if(collecting_gen != NURSERY)
			reset_generations(NURSERY,collecting_gen - 1);

		if(collecting_gen == TENURED)
			major_gc_message();
		else if(HAVE_AGING_P && collecting_gen == AGING)
			minor_collections++;
	}
	else
	{
		/* all generations up to and including the one
		collected are now empty */
		reset_generations(NURSERY,collecting_gen);

		minor_collections++;
	}

	if(collecting_code)
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
	bool code_gc,
	bool growing_data_heap_,
	CELL requested_bytes)
{
	if(gc_off)
	{
		critical_error("GC disabled",gen);
		return;
	}

	s64 start = current_millis();

	performing_gc = true;
	collecting_code = code_gc;
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
			if(collecting_code)
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

	if(!collecting_code)
	{
		/* don't scan code heap unless it has pointers to this
		generation or younger */
		if(collecting_gen >= last_code_heap_scan)
		{
			/* if we are doing code GC, then we will copy over
			literals from any code block which gets marked as live.
			if we are not doing code GC, just consider all literals
			as roots. */
			collect_literals();
			if(collecting_accumulation_gen_p())
				last_code_heap_scan = collecting_gen;
			else
				last_code_heap_scan = collecting_gen + 1;
		}
	}

	while(scan < newspace->here)
		scan = collect_next(scan);

	end_gc();

	gc_time += (current_millis() - start);
	performing_gc = false;
}

void data_gc(void)
{
	garbage_collection(TENURED,false,false,0);
}

DEFINE_PRIMITIVE(data_gc)
{
	data_gc();
}

/* Push total time spent on GC */
DEFINE_PRIMITIVE(gc_time)
{
	box_unsigned_8(gc_time);
}

void simple_gc(void)
{
	maybe_gc(0);
}

DEFINE_PRIMITIVE(become)
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

	data_gc();
}
