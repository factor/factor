#include "master.hpp"

namespace factor
{

cell factorvm::init_zone(zone *z, cell size, cell start)
{
	z->size = size;
	z->start = z->here = start;
	z->end = start + size;
	return z->end;
}


void factorvm::init_card_decks()
{
	cell start = align(data->seg->start,deck_size);
	allot_markers_offset = (cell)data->allot_markers - (start >> card_bits);
	cards_offset = (cell)data->cards - (start >> card_bits);
	decks_offset = (cell)data->decks - (start >> deck_bits);
}

data_heap *factorvm::alloc_data_heap(cell gens, cell young_size,cell aging_size,cell tenured_size)
{
	young_size = align(young_size,deck_size);
	aging_size = align(aging_size,deck_size);
	tenured_size = align(tenured_size,deck_size);

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

	total_size += deck_size;

	data->seg = alloc_segment(total_size);

	data->generations = (zone *)safe_malloc(sizeof(zone) * data->gen_count);
	data->semispaces = (zone *)safe_malloc(sizeof(zone) * data->gen_count);

	cell cards_size = total_size >> card_bits;
	data->allot_markers = (cell *)safe_malloc(cards_size);
	data->allot_markers_end = data->allot_markers + cards_size;

	data->cards = (cell *)safe_malloc(cards_size);
	data->cards_end = data->cards + cards_size;

	cell decks_size = total_size >> deck_bits;
	data->decks = (cell *)safe_malloc(decks_size);
	data->decks_end = data->decks + decks_size;

	cell alloter = align(data->seg->start,deck_size);

	alloter = init_zone(&data->generations[data->tenured()],tenured_size,alloter);
	alloter = init_zone(&data->semispaces[data->tenured()],tenured_size,alloter);

	if(data->gen_count == 3)
	{
		alloter = init_zone(&data->generations[data->aging()],aging_size,alloter);
		alloter = init_zone(&data->semispaces[data->aging()],aging_size,alloter);
	}

	if(data->gen_count >= 2)
	{
		alloter = init_zone(&data->generations[data->nursery()],young_size,alloter);
		alloter = init_zone(&data->semispaces[data->nursery()],0,alloter);
	}

	if(data->seg->end - alloter > deck_size)
		critical_error("Bug in alloc_data_heap",alloter);

	return data;
}


data_heap *factorvm::grow_data_heap(data_heap *data, cell requested_bytes)
{
	cell new_tenured_size = (data->tenured_size * 2) + requested_bytes;

	return alloc_data_heap(data->gen_count,
		data->young_size,
		data->aging_size,
		new_tenured_size);
}


void factorvm::dealloc_data_heap(data_heap *data)
{
	dealloc_segment(data->seg);
	free(data->generations);
	free(data->semispaces);
	free(data->allot_markers);
	free(data->cards);
	free(data->decks);
	free(data);
}


void factorvm::clear_cards(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_card(data->generations[to].start);
	card *last_card = addr_to_card(data->generations[from].end);
	memset(first_card,0,last_card - first_card);
}


void factorvm::clear_decks(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card_deck *first_deck = addr_to_deck(data->generations[to].start);
	card_deck *last_deck = addr_to_deck(data->generations[from].end);
	memset(first_deck,0,last_deck - first_deck);
}


void factorvm::clear_allot_markers(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_allot_marker((object *)data->generations[to].start);
	card *last_card = addr_to_allot_marker((object *)data->generations[from].end);
	memset(first_card,invalid_allot_marker,last_card - first_card);
}


void factorvm::reset_generation(cell i)
{
	zone *z = (i == data->nursery() ? &nursery : &data->generations[i]);

	z->here = z->start;
	if(secure_gc)
		memset((void*)z->start,69,z->size);
}


/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void factorvm::reset_generations(cell from, cell to)
{
	cell i;
	for(i = from; i <= to; i++)
		reset_generation(i);

	clear_cards(from,to);
	clear_decks(from,to);
	clear_allot_markers(from,to);
}


void factorvm::set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = data->generations[data->nursery()];
	init_card_decks();
	clear_cards(data->nursery(),data->tenured());
	clear_decks(data->nursery(),data->tenured());
	clear_allot_markers(data->nursery(),data->tenured());
}


void factorvm::init_data_heap(cell gens,cell young_size,cell aging_size,cell tenured_size,bool secure_gc_)
{
	set_data_heap(alloc_data_heap(gens,young_size,aging_size,tenured_size));
	secure_gc = secure_gc_;
	init_data_gc();
}


/* Size of the object pointed to by a tagged pointer */
cell factorvm::object_size(cell tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untagged_object_size(untag<object>(tagged));
}


/* Size of the object pointed to by an untagged pointer */
cell factorvm::untagged_object_size(object *pointer)
{
	return align8(unaligned_object_size(pointer));
}


/* Size of the data area of an object pointed to by an untagged pointer */
cell factorvm::unaligned_object_size(object *pointer)
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
		return 0; /* can't happen */
	}
}


inline void factorvm::primitive_size()
{
	box_unsigned_cell(object_size(dpop()));
}

PRIMITIVE(size)
{
	PRIMITIVE_GETVM()->primitive_size();
}

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
cell factorvm::binary_payload_start(object *pointer)
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
                return 0; /* can't happen */
	}
}


/* Push memory usage statistics in data heap */
inline void factorvm::primitive_data_room()
{
	dpush(tag_fixnum((data->cards_end - data->cards) >> 10));
	dpush(tag_fixnum((data->decks_end - data->decks) >> 10));

	growable_array a(this);

	cell gen;
	for(gen = 0; gen < data->gen_count; gen++)
	{
		zone *z = (gen == data->nursery() ? &nursery : &data->generations[gen]);
		a.add(tag_fixnum((z->end - z->here) >> 10));
		a.add(tag_fixnum((z->size) >> 10));
	}

	a.trim();
	dpush(a.elements.value());
}

PRIMITIVE(data_room)
{
	PRIMITIVE_GETVM()->primitive_data_room();
}

/* Disables GC and activates next-object ( -- obj ) primitive */
void factorvm::begin_scan()
{
	heap_scan_ptr = data->generations[data->tenured()].start;
	gc_off = true;
}


void factorvm::end_scan()
{
	gc_off = false;
}


inline void factorvm::primitive_begin_scan()
{
	begin_scan();
}

PRIMITIVE(begin_scan)
{
	PRIMITIVE_GETVM()->primitive_begin_scan();
}

cell factorvm::next_object()
{
	if(!gc_off)
		general_error(ERROR_HEAP_SCAN,F,F,NULL);

	if(heap_scan_ptr >= data->generations[data->tenured()].here)
		return F;

	object *obj = (object *)heap_scan_ptr;
	heap_scan_ptr += untagged_object_size(obj);
	return tag_dynamic(obj);
}


/* Push object at heap scan cursor and advance; pushes f when done */
inline void factorvm::primitive_next_object()
{
	dpush(next_object());
}

PRIMITIVE(next_object)
{
	PRIMITIVE_GETVM()->primitive_next_object();
}

/* Re-enables GC */
inline void factorvm::primitive_end_scan()
{
	gc_off = false;
}

PRIMITIVE(end_scan)
{
	PRIMITIVE_GETVM()->primitive_end_scan();
}

template<typename TYPE> void factorvm::each_object(TYPE &functor)
{
	begin_scan();
	cell obj;
	while((obj = next_object()) != F)
		functor(tagged<object>(obj));
	end_scan();
}


namespace
{

struct word_counter {
	cell count;
	word_counter() : count(0) {}
	void operator()(tagged<object> obj) { if(obj.type_p(WORD_TYPE)) count++; }
};

struct word_accumulator {
	growable_array words;
	word_accumulator(int count,factorvm *vm) : words(vm,count) {}
	void operator()(tagged<object> obj) { if(obj.type_p(WORD_TYPE)) words.add(obj.value()); }
};

}

cell factorvm::find_all_words()
{
	word_counter counter;
	each_object(counter);
	word_accumulator accum(counter.count,this);
	each_object(accum);
	accum.words.trim();
	return accum.words.elements.value();
}


}
