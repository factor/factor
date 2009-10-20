#include "master.hpp"

namespace factor
{

void factor_vm::init_card_decks()
{
	cards_offset = (cell)data->cards - addr_to_card(data->start);
	decks_offset = (cell)data->decks - addr_to_deck(data->start);
}

data_heap::data_heap(cell young_size_, cell aging_size_, cell tenured_size_)
{
	young_size_ = align(young_size_,deck_size);
	aging_size_ = align(aging_size_,deck_size);
	tenured_size_ = align(tenured_size_,deck_size);

	young_size = young_size_;
	aging_size = aging_size_;
	tenured_size = tenured_size_;

	cell total_size = young_size + 2 * aging_size + 2 * tenured_size;

	total_size += deck_size;

	seg = new segment(total_size,false);

	cell cards_size = addr_to_card(total_size);

	cards = new card[cards_size];
	cards_end = cards + cards_size;

	cell decks_size = addr_to_deck(total_size);
	decks = new card_deck[decks_size];
	decks_end = decks + decks_size;

	start = align(seg->start,deck_size);

	tenured = new tenured_space(tenured_size,start);
	tenured_semispace = new tenured_space(tenured_size,tenured->end);

	aging = new aging_space(aging_size,tenured_semispace->end);
	aging_semispace = new aging_space(aging_size,aging->end);

	nursery = new bump_allocator(young_size,aging_semispace->end);

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

data_heap *data_heap::grow(cell requested_bytes)
{
	cell new_tenured_size = (tenured_size * 2) + requested_bytes;
	return new data_heap(young_size,aging_size,new_tenured_size);
}

void factor_vm::set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = *data->nursery;
	nursery.here = nursery.start;
	init_card_decks();
	data->reset_generation(data->aging);
	data->reset_generation(data->tenured);
}

void factor_vm::init_data_heap(cell young_size, cell aging_size, cell tenured_size)
{
	set_data_heap(new data_heap(young_size,aging_size,tenured_size));
}

/* Size of the object pointed to by a tagged pointer */
cell factor_vm::object_size(cell tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untag<object>(tagged)->size();
}

/* Size of the object pointed to by an untagged pointer */
cell object::size()
{
	if(free_p()) return ((free_heap_block *)this)->size();

	switch(h.hi_tag())
	{
	case ARRAY_TYPE:
		return align(array_size((array*)this),data_alignment);
	case BIGNUM_TYPE:
		return align(array_size((bignum*)this),data_alignment);
	case BYTE_ARRAY_TYPE:
		return align(array_size((byte_array*)this),data_alignment);
	case STRING_TYPE:
		return align(string_size(string_capacity((string*)this)),data_alignment);
	case TUPLE_TYPE:
		{
			tuple_layout *layout = (tuple_layout *)UNTAG(((tuple *)this)->layout);
			return align(tuple_size(layout),data_alignment);
		}
	case QUOTATION_TYPE:
		return align(sizeof(quotation),data_alignment);
	case WORD_TYPE:
		return align(sizeof(word),data_alignment);
	case FLOAT_TYPE:
		return align(sizeof(boxed_float),data_alignment);
	case DLL_TYPE:
		return align(sizeof(dll),data_alignment);
	case ALIEN_TYPE:
		return align(sizeof(alien),data_alignment);
	case WRAPPER_TYPE:
		return align(sizeof(wrapper),data_alignment);
	case CALLSTACK_TYPE:
		return align(callstack_size(untag_fixnum(((callstack *)this)->length)),data_alignment);
	default:
		critical_error("Invalid header",(cell)this);
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
		general_error(ERROR_HEAP_SCAN,false_object,false_object,NULL);

	if(heap_scan_ptr >= data->tenured->here)
		return false_object;

	object *obj = (object *)heap_scan_ptr;
	heap_scan_ptr += obj->size();
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
	while(to_boolean(obj = next_object()))
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
