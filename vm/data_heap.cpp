#include "master.hpp"

namespace factor
{

void factor_vm::init_card_decks()
{
	cell start = align(data->seg->start,deck_size);
	cards_offset = (cell)data->cards - (start >> card_bits);
	decks_offset = (cell)data->decks - (start >> deck_bits);
}

data_heap::data_heap(factor_vm *myvm, cell young_size_, cell aging_size_, cell tenured_size_)
{
	young_size_ = align(young_size_,deck_size);
	aging_size_ = align(aging_size_,deck_size);
	tenured_size_ = align(tenured_size_,deck_size);

	young_size = young_size_;
	aging_size = aging_size_;
	tenured_size = tenured_size_;

	cell total_size = young_size + 2 * aging_size + 2 * tenured_size;

	total_size += deck_size;

	seg = new segment(total_size);

	cell cards_size = total_size >> card_bits;

	cards = new char[cards_size];
	cards_end = cards + cards_size;

	cell decks_size = total_size >> deck_bits;
	decks = new char[decks_size];
	decks_end = decks + decks_size;

	cell start = align(seg->start,deck_size);

	tenured = new tenured_space(tenured_size,start);
	tenured_semispace = new tenured_space(tenured_size,tenured->end);

	aging = new aging_space(aging_size,tenured_semispace->end);
	aging_semispace = new aging_space(aging_size,aging->end);

	nursery = new zone(young_size,aging_semispace->end);

	assert(seg->end - nursery->end <= deck_size);
}

data_heap::~data_heap()
{
	delete seg;
	delete nursery;
	delete aging;
	delete aging_semispace;
	delete tenured;
	delete tenured_semispace;
	delete[] cards;
	delete[] decks;
}

data_heap *factor_vm::grow_data_heap(data_heap *data, cell requested_bytes)
{
	cell new_tenured_size = (data->tenured_size * 2) + requested_bytes;

	return new data_heap(this,
		data->young_size,
		data->aging_size,
		new_tenured_size);
}

void factor_vm::clear_cards(old_space *gen)
{
	/* NOTE: reverse order due to heap layout. */
	card *first_card = addr_to_card(gen->start);
	card *last_card = addr_to_card(gen->end);
	memset(first_card,0,last_card - first_card);
}

void factor_vm::clear_decks(old_space *gen)
{
	/* NOTE: reverse order due to heap layout. */
	card_deck *first_deck = addr_to_deck(gen->start);
	card_deck *last_deck = addr_to_deck(gen->end);
	memset(first_deck,0,last_deck - first_deck);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
void factor_vm::reset_generation(old_space *gen)
{
	gen->here = gen->start;
	if(secure_gc) memset((void*)gen->start,69,gen->size);

	clear_cards(gen);
	clear_decks(gen);
	gen->clear_object_start_offsets();
}

void factor_vm::set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = *data->nursery;
	nursery.here = nursery.start;
	init_card_decks();
	reset_generation(data->aging);
	reset_generation(data->tenured);
}

void factor_vm::init_data_heap(cell young_size, cell aging_size, cell tenured_size, bool secure_gc_)
{
	set_data_heap(new data_heap(this,young_size,aging_size,tenured_size));
	secure_gc = secure_gc_;
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

	a.add(tag_fixnum((nursery.end - nursery.here) >> 10));
	a.add(tag_fixnum((nursery.size) >> 10));

	a.add(tag_fixnum((data->aging->end - data->aging->here) >> 10));
	a.add(tag_fixnum((data->aging->size) >> 10));

	a.add(tag_fixnum((data->tenured->end - data->tenured->here) >> 10));
	a.add(tag_fixnum((data->tenured->size) >> 10));

	a.trim();
	dpush(a.elements.value());
}

/* Disables GC and activates next-object ( -- obj ) primitive */
void factor_vm::begin_scan()
{
	heap_scan_ptr = data->tenured->start;
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

	if(heap_scan_ptr >= data->tenured->here)
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

template<typename Iterator> void factor_vm::each_object(Iterator &iterator)
{
	begin_scan();
	cell obj;
	while((obj = next_object()) != F)
		iterator(tagged<object>(obj));
	end_scan();
}

struct word_counter {
	cell count;
	explicit word_counter() : count(0) {}
	void operator()(tagged<object> obj) { if(obj.type_p(WORD_TYPE)) count++; }
};

struct word_accumulator {
	growable_array words;
	explicit word_accumulator(int count,factor_vm *vm) : words(vm,count) {}
	void operator()(tagged<object> obj) { if(obj.type_p(WORD_TYPE)) words.add(obj.value()); }
};

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
