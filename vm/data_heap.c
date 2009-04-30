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

void reset_generation(CELL i)
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

void set_data_heap(F_DATA_HEAP *data_heap_)
{
	data_heap = data_heap_;
	nursery = data_heap->generations[NURSERY];
	init_card_decks();
	clear_cards(NURSERY,TENURED);
	clear_decks(NURSERY,TENURED);
	clear_allot_markers(NURSERY,TENURED);
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
	case FLOAT_TYPE:
		return sizeof(F_FLOAT);
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
	case WRAPPER_TYPE:
		return sizeof(F_WRAPPER);
	default:
		critical_error("Invalid header",pointer);
		return -1; /* can't happen */
	}
}

/* Push memory usage statistics in data heap */
void primitive_data_room(void)
{
	dpush(tag_fixnum((data_heap->cards_end - data_heap->cards) >> 10));
	dpush(tag_fixnum((data_heap->decks_end - data_heap->decks) >> 10));

	GROWABLE_ARRAY(a);

	int gen;
	for(gen = 0; gen < data_heap->gen_count; gen++)
	{
		F_ZONE *z = (gen == NURSERY ? &nursery : &data_heap->generations[gen]);
		GROWABLE_ARRAY_ADD(a,tag_fixnum((z->end - z->here) >> 10));
		GROWABLE_ARRAY_ADD(a,tag_fixnum((z->size) >> 10));
	}

	GROWABLE_ARRAY_TRIM(a);
	GROWABLE_ARRAY_DONE(a);
	dpush(a);
}

/* Disables GC and activates next-object ( -- obj ) primitive */
void begin_scan(void)
{
	heap_scan_ptr = data_heap->generations[TENURED].start;
	gc_off = true;
}

void primitive_begin_scan(void)
{
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

	return RETAG(obj,type < HEADER_TYPE ? type : OBJECT_TYPE);
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
	GROWABLE_ARRAY_DONE(words);

	return words;
}
