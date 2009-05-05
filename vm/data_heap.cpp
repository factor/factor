#include "master.hpp"

factor::zone nursery;

namespace factor
{

/* Set by the -securegc command line argument */
bool secure_gc;

/* new objects are allocated here */
VM_C_API zone nursery;

/* GC is off during heap walking */
bool gc_off;

data_heap *data;

cell init_zone(zone *z, cell size, cell start)
{
	z->size = size;
	z->start = z->here = start;
	z->end = start + size;
	return z->end;
}

void init_card_decks()
{
	cell start = align(data->seg->start,DECK_SIZE);
	allot_markers_offset = (cell)data->allot_markers - (start >> CARD_BITS);
	cards_offset = (cell)data->cards - (start >> CARD_BITS);
	decks_offset = (cell)data->decks - (start >> DECK_BITS);
}

data_heap *alloc_data_heap(cell gens,
	cell young_size,
	cell aging_size,
	cell tenured_size)
{
	young_size = align(young_size,DECK_SIZE);
	aging_size = align(aging_size,DECK_SIZE);
	tenured_size = align(tenured_size,DECK_SIZE);

	data_heap *data = (data_heap *)safe_malloc(sizeof(data_heap));
	data->young_size = young_size;
	data->aging_size = aging_size;
	data->tenured_size = tenured_size;
	data->gen_count = gens;

	cell total_size;
	if(data->gen_count == 2)
		total_size = young_size + 2 * tenured_size;
	else if(data->gen_count == 3)
		total_size = young_size + 2 * aging_size + 2 * tenured_size;
	else
	{
		fatal_error("Invalid number of generations",data->gen_count);
		return NULL; /* can't happen */
	}

	total_size += DECK_SIZE;

	data->seg = alloc_segment(total_size);

	data->generations = (zone *)safe_malloc(sizeof(zone) * data->gen_count);
	data->semispaces = (zone *)safe_malloc(sizeof(zone) * data->gen_count);

	cell cards_size = total_size >> CARD_BITS;
	data->allot_markers = (cell *)safe_malloc(cards_size);
	data->allot_markers_end = data->allot_markers + cards_size;

	data->cards = (cell *)safe_malloc(cards_size);
	data->cards_end = data->cards + cards_size;

	cell decks_size = total_size >> DECK_BITS;
	data->decks = (cell *)safe_malloc(decks_size);
	data->decks_end = data->decks + decks_size;

	cell alloter = align(data->seg->start,DECK_SIZE);

	alloter = init_zone(&data->generations[TENURED],tenured_size,alloter);
	alloter = init_zone(&data->semispaces[TENURED],tenured_size,alloter);

	if(data->gen_count == 3)
	{
		alloter = init_zone(&data->generations[AGING],aging_size,alloter);
		alloter = init_zone(&data->semispaces[AGING],aging_size,alloter);
	}

	if(data->gen_count >= 2)
	{
		alloter = init_zone(&data->generations[NURSERY],young_size,alloter);
		alloter = init_zone(&data->semispaces[NURSERY],0,alloter);
	}

	if(data->seg->end - alloter > DECK_SIZE)
		critical_error("Bug in alloc_data_heap",alloter);

	return data;
}

data_heap *grow_data_heap(data_heap *data, cell requested_bytes)
{
	cell new_tenured_size = (data->tenured_size * 2) + requested_bytes;

	return alloc_data_heap(data->gen_count,
		data->young_size,
		data->aging_size,
		new_tenured_size);
}

void dealloc_data_heap(data_heap *data)
{
	dealloc_segment(data->seg);
	free(data->generations);
	free(data->semispaces);
	free(data->allot_markers);
	free(data->cards);
	free(data->decks);
	free(data);
}

void clear_cards(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_card(data->generations[to].start);
	card *last_card = addr_to_card(data->generations[from].end);
	memset(first_card,0,last_card - first_card);
}

void clear_decks(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card_deck *first_deck = addr_to_deck(data->generations[to].start);
	card_deck *last_deck = addr_to_deck(data->generations[from].end);
	memset(first_deck,0,last_deck - first_deck);
}

void clear_allot_markers(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_allot_marker((object *)data->generations[to].start);
	card *last_card = addr_to_allot_marker((object *)data->generations[from].end);
	memset(first_card,INVALID_ALLOT_MARKER,last_card - first_card);
}

void reset_generation(cell i)
{
	zone *z = (i == NURSERY ? &nursery : &data->generations[i]);

	z->here = z->start;
	if(secure_gc)
		memset((void*)z->start,69,z->size);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void reset_generations(cell from, cell to)
{
	cell i;
	for(i = from; i <= to; i++)
		reset_generation(i);

	clear_cards(from,to);
	clear_decks(from,to);
	clear_allot_markers(from,to);
}

void set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = data->generations[NURSERY];
	init_card_decks();
	clear_cards(NURSERY,TENURED);
	clear_decks(NURSERY,TENURED);
	clear_allot_markers(NURSERY,TENURED);
}

void init_data_heap(cell gens,
	cell young_size,
	cell aging_size,
	cell tenured_size,
	bool secure_gc_)
{
	set_data_heap(alloc_data_heap(gens,young_size,aging_size,tenured_size));

	gc_locals_region = alloc_segment(getpagesize());
	gc_locals = gc_locals_region->start - sizeof(cell);

	gc_bignums_region = alloc_segment(getpagesize());
	gc_bignums = gc_bignums_region->start - sizeof(cell);

	secure_gc = secure_gc_;

	init_data_gc();
}

/* Size of the object pointed to by a tagged pointer */
cell object_size(cell tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untagged_object_size(untag<object>(tagged));
}

/* Size of the object pointed to by an untagged pointer */
cell untagged_object_size(object *pointer)
{
	return align8(unaligned_object_size(pointer));
}

/* Size of the data area of an object pointed to by an untagged pointer */
cell unaligned_object_size(object *pointer)
{
	switch(pointer->h.hi_tag())
	{
	case ARRAY_TYPE:
		return array_size((array*)pointer);
	case BIGNUM_TYPE:
		return array_size((bignum*)pointer);
	case BYTE_ARRAY_TYPE:
		return array_size((byte_array*)pointer);
	case STRING_TYPE:
		return string_size(string_capacity((string*)pointer));
	case TUPLE_TYPE:
		return tuple_size(untag<tuple_layout>(((tuple *)pointer)->layout));
	case QUOTATION_TYPE:
		return sizeof(quotation);
	case WORD_TYPE:
		return sizeof(word);
	case FLOAT_TYPE:
		return sizeof(boxed_float);
	case DLL_TYPE:
		return sizeof(dll);
	case ALIEN_TYPE:
		return sizeof(alien);
	case WRAPPER_TYPE:
		return sizeof(wrapper);
	case CALLSTACK_TYPE:
		return callstack_size(untag_fixnum(((callstack *)pointer)->length));
	default:
		critical_error("Invalid header",(cell)pointer);
		return -1; /* can't happen */
	}
}

PRIMITIVE(size)
{
	box_unsigned_cell(object_size(dpop()));
}

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
cell binary_payload_start(object *pointer)
{
	switch(pointer->h.hi_tag())
	{
	/* these objects do not refer to other objects at all */
	case FLOAT_TYPE:
	case BYTE_ARRAY_TYPE:
	case BIGNUM_TYPE:
	case CALLSTACK_TYPE:
		return 0;
	/* these objects have some binary data at the end */
	case WORD_TYPE:
		return sizeof(word) - sizeof(cell) * 3;
	case ALIEN_TYPE:
		return sizeof(cell) * 3;
	case DLL_TYPE:
		return sizeof(cell) * 2;
	case QUOTATION_TYPE:
		return sizeof(quotation) - sizeof(cell) * 2;
	case STRING_TYPE:
		return sizeof(string);
	/* everything else consists entirely of pointers */
	case ARRAY_TYPE:
		return array_size<array>(array_capacity((array*)pointer));
	case TUPLE_TYPE:
		return tuple_size(untag<tuple_layout>(((tuple *)pointer)->layout));
	case WRAPPER_TYPE:
		return sizeof(wrapper);
	default:
		critical_error("Invalid header",(cell)pointer);
		return -1; /* can't happen */
	}
}

/* Push memory usage statistics in data heap */
PRIMITIVE(data_room)
{
	dpush(tag_fixnum((data->cards_end - data->cards) >> 10));
	dpush(tag_fixnum((data->decks_end - data->decks) >> 10));

	growable_array a;

	cell gen;
	for(gen = 0; gen < data->gen_count; gen++)
	{
		zone *z = (gen == NURSERY ? &nursery : &data->generations[gen]);
		a.add(tag_fixnum((z->end - z->here) >> 10));
		a.add(tag_fixnum((z->size) >> 10));
	}

	a.trim();
	dpush(a.elements.value());
}

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
cell heap_scan_ptr;

/* Disables GC and activates next-object ( -- obj ) primitive */
void begin_scan()
{
	heap_scan_ptr = data->generations[TENURED].start;
	gc_off = true;
}

PRIMITIVE(begin_scan)
{
	begin_scan();
}

cell next_object()
{
	if(!gc_off)
		general_error(ERROR_HEAP_SCAN,F,F,NULL);

	if(heap_scan_ptr >= data->generations[TENURED].here)
		return F;

	object *obj = (object *)heap_scan_ptr;
	heap_scan_ptr += untagged_object_size(obj);
	return tag_dynamic(obj);
}

/* Push object at heap scan cursor and advance; pushes f when done */
PRIMITIVE(next_object)
{
	dpush(next_object());
}

/* Re-enables GC */
PRIMITIVE(end_scan)
{
	gc_off = false;
}

cell find_all_words()
{
	growable_array words;

	begin_scan();

	cell obj;
	while((obj = next_object()) != F)
	{
		if(tagged<object>(obj).type_p(WORD_TYPE))
			words.add(obj);
	}

	/* End heap scan */
	gc_off = false;

	words.trim();
	return words.elements.value();
}

}
