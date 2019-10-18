#include "factor.h"

/* If memory allocation fails, bail out */
void *safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(!ptr) fatal_error("Out of memory in safe_malloc", 0);
	return ptr;
}

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

/* the data heap layout is important:
- two semispaces: tenured and prior
- younger generations follow
this is so that we can easily check if a pointer is in some generation or a
younger one */
F_DATA_HEAP *alloc_data_heap(CELL gens, CELL young_size, CELL aging_size)
{
	young_size = align_page(young_size);
	aging_size = align_page(aging_size);

	F_DATA_HEAP *data_heap = safe_malloc(sizeof(F_DATA_HEAP));
	data_heap->young_size = young_size;
	data_heap->aging_size = aging_size;
	data_heap->gen_count = gens;

	CELL total_size = (gens - 1) * young_size + 2 * aging_size;
	data_heap->segment = alloc_segment(total_size);

	data_heap->generations = safe_malloc(sizeof(F_ZONE) * gens);

	CELL cards_size = total_size / CARD_SIZE;
	data_heap->cards = safe_malloc(cards_size);
	data_heap->cards_end = data_heap->cards + cards_size;

	CELL alloter = data_heap->segment->start;

	alloter = init_zone(&tenured,aging_size,alloter);
	alloter = init_zone(&data_heap->prior,aging_size,alloter);

	int i;

	for(i = gens - 2; i >= 0; i--)
	{
		alloter = init_zone(&data_heap->generations[i],
			young_size,alloter);
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
	if(tagged == F || TAG(tagged) == FIXNUM_TYPE)
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
	case WORD_TYPE:
		return sizeof(F_WORD);
	case ARRAY_TYPE:
	case TUPLE_TYPE:
	case BIGNUM_TYPE:
	case QUOTATION_TYPE:
		return array_size(array_capacity((F_ARRAY*)pointer));
	case BYTE_ARRAY_TYPE:
		return byte_array_size(
			byte_array_capacity((F_BYTE_ARRAY*)pointer));
	case HASHTABLE_TYPE:
		return sizeof(F_HASHTABLE);
	case VECTOR_TYPE:
		return sizeof(F_VECTOR);
	case STRING_TYPE:
		return string_size(string_capacity((F_STRING*)pointer));
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
	default:
		critical_error("Cannot determine untagged_object_size",pointer);
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
	dpush(tag_fixnum((data_heap->prior.size) >> 10));

	for(gen = 0; gen < data_heap->gen_count; gen++)
	{
		F_ZONE *z = &data_heap->generations[gen];
		set_array_nth(a,gen * 2,tag_fixnum((z->end - z->here) >> 10));
		set_array_nth(a,gen * 2 + 1,tag_fixnum((z->size) >> 10));
	}

	dpush(tag_object(a));
}

/* Disables GC and activates next-object ( -- obj ) primitive */
void primitive_begin_scan(void)
{
	primitive_data_gc();
	heap_scan_ptr = tenured.start;
	gc_off = true;
}

/* Push object at heap scan cursor and advance; pushes f when done */
void primitive_next_object(void)
{
	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;
	CELL type;

	if(!gc_off)
		simple_error(ERROR_HEAP_SCAN,F,F);

	if(heap_scan_ptr >= tenured.here)
	{
		dpush(F);
		return;
	}
	
	type = untag_header(value);
	heap_scan_ptr += untagged_object_size(heap_scan_ptr);

	if(type <= HEADER_TYPE)
		dpush(RETAG(obj,type));
	else
		dpush(RETAG(obj,OBJECT_TYPE));
}

/* Re-enables GC */
void primitive_end_scan(void)
{
	gc_off = false;
}

/* Scan all the objects in the card */
INLINE void collect_card(F_CARD *ptr, CELL here)
{
	F_CARD c = *ptr;
	CELL offset = (c & CARD_BASE_MASK);
	CELL card_scan = (CELL)CARD_TO_ADDR(ptr) + offset;
	CELL card_end = (CELL)CARD_TO_ADDR(ptr + 1);

	if(offset == 0x7f)
	{
		if(c == 0xff)
			critical_error("bad card",(CELL)ptr);
		else
			return;
	}

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
	
	for(; ptr <= last_card; ptr++)
	{
		if(card_marked(*ptr))
			collect_card(ptr,here);
	}
}

/* After all old->new forward references have been copied over, we must unmark
the cards */
void unmark_cards(CELL from, CELL to)
{
	F_CARD *ptr = ADDR_TO_CARD(data_heap->generations[from].start);
	CELL here = data_heap->generations[to].here;
	F_CARD *last_card = ADDR_TO_CARD(here - 1);

	for(; ptr <= last_card; ptr++)
		unmark_card(ptr);
}

/* Scan cards in all generations older than the one being collected, copying
old->new references */
void collect_cards(CELL gen)
{
	int i;
	for(i = gen + 1; i < data_heap->gen_count; i++)
		collect_gen_cards(i);
}

void collect_callframe(F_INTERP_FRAME *callframe)
{
	callframe->scan -= callframe->quot;
	callframe->end -= callframe->quot;
	copy_handle(&callframe->quot);
	callframe->scan += callframe->quot;
	callframe->end += callframe->quot;
}

/* Copy all tagged pointers in a range of memory */
void collect_stack(F_SEGMENT *region, CELL top)
{
	CELL bottom = region->start;
	CELL ptr;

	for(ptr = bottom; ptr <= top; ptr += CELLS)
		copy_handle((CELL*)ptr);
}

/* The callstack has a special format */
void collect_callstack(F_SEGMENT *seg, F_INTERP_FRAME *top)
{
	F_INTERP_FRAME *bottom = (F_INTERP_FRAME *)seg->start;
	while(bottom < top)
	{
		collect_callframe(bottom);
		bottom++;
	}
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

	collect_callframe(&callframe);

	collect_stack(extra_roots_region,extra_roots);

	save_stacks();
	stacks = stack_chain;

	while(stacks)
	{
		collect_stack(stacks->data_region,stacks->data);
		collect_stack(stacks->retain_region,stacks->retain);
		collect_callstack(stacks->call_region,stacks->call);

		if(stacks->next != NULL)
			collect_callframe(&stacks->callframe);

		copy_handle(&stacks->catchstack_save);
		copy_handle(&stacks->current_callback_save);

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

INLINE CELL copy_object_impl(CELL pointer)
{
	CELL newpointer = (CELL)copy_untagged_object((void*)UNTAG(pointer),
		object_size(pointer));

	/* install forwarding pointer */
	put(UNTAG(pointer),RETAG(newpointer,GC_COLLECTED));

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
CELL copy_object(CELL pointer)
{
	CELL tag;
	CELL header;

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
	case BIGNUM_TYPE:
		return 0;
	/* these objects have some binary data at the end */
	case WORD_TYPE:
		return sizeof(F_WORD) - CELLS;
	case ALIEN_TYPE:
	case DLL_TYPE:
		return CELLS * 2;
	/* everything else consists entirely of pointers */
	default:
		return unaligned_object_size(pointer);
	}
}

/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
INLINE void collect_object(CELL start)
{
	CELL scan = start;
	CELL payload_start = binary_payload_start(scan);
	CELL end = scan + payload_start;

	scan += CELLS;

	while(scan < end)
	{
		copy_handle((CELL*)scan);
		scan += CELLS;
	}

	/* It is odd to put this hook here, but this is the only special case
	made for any type of object by the GC. If code GC is being performed,
	compiled code blocks referenced by this word must be marked. */
	if(collecting_code && object_type(start) == WORD_TYPE)
	{
		F_WORD *word = (F_WORD *)start;
		if(word->compiledp != F)
			recursive_mark(word->xt);
	}
}

CELL collect_next(CELL scan)
{
	CELL size = untagged_object_size(scan);
	collect_object(scan);
	return scan + size;
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
void begin_gc(CELL gen,
	bool code_gc,
	bool growing_data_heap_,
	CELL requested_bytes)
{
	collecting_code = code_gc;
	growing_data_heap = growing_data_heap_;
	collecting_gen = gen;

	if(growing_data_heap)
	{
		if(gen != TENURED)
			critical_error("Invalid parameters to begin_gc",0);

		old_data_heap = data_heap;
		set_data_heap(grow_data_heap(old_data_heap,requested_bytes));
		newspace = &data_heap->generations[gen];
	}
	else if(gen == TENURED)
	{
		/* when collecting the oldest generation, rotate it
		with the semispace */
		F_ZONE z = data_heap->generations[gen];
		data_heap->generations[gen] = data_heap->prior;
		data_heap->prior = z;
		reset_generation(gen);
		newspace = &data_heap->generations[gen];
		clear_cards(TENURED,TENURED);
	}
	else
	{
		/* when collecting a younger generation, we copy
		reachable objects to the next oldest generation,
		so we set the newspace so the next generation. */
		newspace = &data_heap->generations[gen + 1];
		collecting_gen_start = data_heap->generations[gen].start;
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

	if(collecting_gen == TENURED)
	{
		/* we did a full collection; no more
		old-to-new pointers remain since everything
		is in tenured space */
		unmark_cards(TENURED,TENURED);
		/* all generations except tenured space are
		now empty */
		reset_generations(NURSERY,TENURED - 1);

		major_gc_message();
	}
	else
	{
		/* we collected a younger generation. so the
		next-oldest generation no longer has any
		pointers into the younger generation (the
		younger generation is empty!) */
		unmark_cards(collecting_gen + 1,collecting_gen + 1);
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
}

/* Collect gen and all younger generations.
If growing_data_heap_ is true, we must grow the data heap to such a size that
an allocation of requested_bytes won't fail */
void garbage_collection(volatile CELL gen,
	bool code_gc,
	volatile bool growing_data_heap,
	CELL requested_bytes)
{
	s64 start = current_millis();
	CELL scan;

	if(gc_off)
		critical_error("GC disabled",gen);

	/* we come back here if a generation is full */
	if(setjmp(gc_jmp))
	{
		/* We have no older generations we can try collecting, so we
		resort to growing the data heap */
		if(gen == TENURED)
			growing_data_heap = true;
		/* Collect the next oldest generation */
		else
			gen++;
	}

	begin_gc(gen,code_gc,growing_data_heap,requested_bytes);

	/* initialize chase pointer */
	scan = newspace->here;

	/* collect objects referenced from stacks and environment */
	collect_roots();
	
	/* collect objects referenced from older generations */
	collect_cards(gen);

	if(!code_gc)
	{
		/* if we are doing code GC, then we will copy over literals
		from any code block which gets marked as live. if we are not
		doing code GC, just consider all literals as roots. */
		collect_literals();
	}

	while(scan < newspace->here)
		scan = collect_next(scan);

	end_gc();

	gc_time += (current_millis() - start);
}

void primitive_data_gc(void)
{
	garbage_collection(TENURED,false,false,0);
}

/* Push total time spent on GC */
void primitive_gc_time(void)
{
	box_unsigned_8(gc_time);
}

void simple_gc(void)
{
	maybe_gc(0);
}
