#include "master.hpp"

namespace factor
{

void factor_vm::init_card_decks()
{
	cell start = align(data->seg->start,deck_size);
	allot_markers_offset = (cell)data->allot_markers - (start >> card_bits);
	cards_offset = (cell)data->cards - (start >> card_bits);
	decks_offset = (cell)data->decks - (start >> deck_bits);
}

data_heap::data_heap(factor_vm *myvm, cell gen_count_, cell young_size_, cell aging_size_, cell tenured_size_)
{
	young_size_ = align(young_size_,deck_size);
	aging_size_ = align(aging_size_,deck_size);
	tenured_size_ = align(tenured_size_,deck_size);

	young_size = young_size_;
	aging_size = aging_size_;
	tenured_size = tenured_size_;
	gen_count = gen_count_;

	cell total_size;
	if(gen_count == 2)
		total_size = young_size + 2 * tenured_size;
	else if(gen_count == 3)
		total_size = young_size + 2 * aging_size + 2 * tenured_size;
	else
	{
		total_size = 0;
		fatal_error("Invalid number of generations",gen_count);
	}

	total_size += deck_size;

	seg = new segment(myvm,total_size);

	generations = new zone[gen_count];
	semispaces = new zone[gen_count];

	cell cards_size = total_size >> card_bits;
	allot_markers = new char[cards_size];
	allot_markers_end = allot_markers + cards_size;

	cards = new char[cards_size];
	cards_end = cards + cards_size;

	cell decks_size = total_size >> deck_bits;
	decks = new char[decks_size];
	decks_end = decks + decks_size;

	cell alloter = align(seg->start,deck_size);

	alloter = generations[tenured()].init_zone(tenured_size,alloter);
	alloter = semispaces[tenured()].init_zone(tenured_size,alloter);

	if(gen_count == 3)
	{
		alloter = generations[aging()].init_zone(aging_size,alloter);
		alloter = semispaces[aging()].init_zone(aging_size,alloter);
	}

	if(gen_count >= 2)
	{
		alloter = generations[nursery()].init_zone(young_size,alloter);
		alloter = semispaces[nursery()].init_zone(0,alloter);
	}

	if(seg->end - alloter > deck_size)
		myvm->critical_error("Bug in alloc_data_heap",alloter);
}

data_heap *factor_vm::grow_data_heap(data_heap *data, cell requested_bytes)
{
	cell new_tenured_size = (data->tenured_size * 2) + requested_bytes;

	return new data_heap(this,
		data->gen_count,
		data->young_size,
		data->aging_size,
		new_tenured_size);
}

data_heap::~data_heap()
{
	delete seg;
	delete[] generations;
	delete[] semispaces;
	delete[] allot_markers;
	delete[] cards;
	delete[] decks;
}

void factor_vm::clear_cards(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_card(data->generations[to].start);
	card *last_card = addr_to_card(data->generations[from].end);
	memset(first_card,0,last_card - first_card);
}

void factor_vm::clear_decks(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card_deck *first_deck = addr_to_deck(data->generations[to].start);
	card_deck *last_deck = addr_to_deck(data->generations[from].end);
	memset(first_deck,0,last_deck - first_deck);
}

void factor_vm::clear_allot_markers(cell from, cell to)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_allot_marker((object *)data->generations[to].start);
	card *last_card = addr_to_allot_marker((object *)data->generations[from].end);
	memset(first_card,invalid_allot_marker,last_card - first_card);
}

void factor_vm::reset_generation(cell i)
{
	zone *z = (i == data->nursery() ? &nursery : &data->generations[i]);

	z->here = z->start;
	if(secure_gc)
		memset((void*)z->start,69,z->size);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void factor_vm::reset_generations(cell from, cell to)
{
	cell i;
	for(i = from; i <= to; i++)
		reset_generation(i);

	clear_cards(from,to);
	clear_decks(from,to);
	clear_allot_markers(from,to);
}

void factor_vm::set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = data->generations[data->nursery()];
	init_card_decks();
	clear_cards(data->nursery(),data->tenured());
	clear_decks(data->nursery(),data->tenured());
	clear_allot_markers(data->nursery(),data->tenured());
}

void factor_vm::init_data_heap(cell gens,cell young_size,cell aging_size,cell tenured_size,bool secure_gc_)
{
	set_data_heap(new data_heap(this,gens,young_size,aging_size,tenured_size));
	secure_gc = secure_gc_;
	init_data_gc();
}

/* Size of the object pointed to by a tagged pointer */
cell factor_vm::object_size(cell tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untagged_object_size(untag<object>(tagged));
}

/* Size of the object pointed to by an untagged pointer */
cell factor_vm::untagged_object_size(object *pointer)
{
	return align8(unaligned_object_size(pointer));
}

/* Size of the data area of an object pointed to by an untagged pointer */
cell factor_vm::unaligned_object_size(object *pointer)
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

void factor_vm::primitive_size()
{
	box_unsigned_cell(object_size(dpop()));
}

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
cell factor_vm::binary_payload_start(object *pointer)
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
void factor_vm::primitive_data_room()
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

/* Disables GC and activates next-object ( -- obj ) primitive */
void factor_vm::begin_scan()
{
	heap_scan_ptr = data->generations[data->tenured()].start;
	gc_off = true;
}

void factor_vm::end_scan()
{
	gc_off = false;
}

void factor_vm::primitive_begin_scan()
{
	begin_scan();
}

cell factor_vm::next_object()
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
void factor_vm::primitive_next_object()
{
	dpush(next_object());
}

/* Re-enables GC */
void factor_vm::primitive_end_scan()
{
	gc_off = false;
}

template<typename TYPE> void factor_vm::each_object(TYPE &functor)
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
	word_accumulator(int count,factor_vm *vm) : words(vm,count) {}
	void operator()(tagged<object> obj) { if(obj.type_p(WORD_TYPE)) words.add(obj.value()); }
};

}

cell factor_vm::find_all_words()
{
	word_counter counter;
	each_object(counter);
	word_accumulator accum(counter.count,this);
	each_object(accum);
	accum.words.trim();
	return accum.words.elements.value();
}

}
