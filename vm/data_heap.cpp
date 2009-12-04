#include "master.hpp"

namespace factor
{

void factor_vm::init_card_decks()
{
	cards_offset = (cell)data->cards - addr_to_card(data->start);
	decks_offset = (cell)data->decks - addr_to_deck(data->start);
}

data_heap::data_heap(cell young_size_,
	cell aging_size_,
	cell tenured_size_)
{
	young_size_ = align(young_size_,deck_size);
	aging_size_ = align(aging_size_,deck_size);
	tenured_size_ = align(tenured_size_,deck_size);

	young_size = young_size_;
	aging_size = aging_size_;
	tenured_size = tenured_size_;

	cell total_size = young_size + 2 * aging_size + tenured_size + deck_size;
	seg = new segment(total_size,false);

	cell cards_size = addr_to_card(total_size);
	cards = new card[cards_size];
	cards_end = cards + cards_size;
	memset(cards,0,cards_size);

	cell decks_size = addr_to_deck(total_size);
	decks = new card_deck[decks_size];
	decks_end = decks + decks_size;
	memset(decks,0,decks_size);

	start = align(seg->start,deck_size);

	tenured = new tenured_space(tenured_size,start);

	aging = new aging_space(aging_size,tenured->end);
	aging_semispace = new aging_space(aging_size,aging->end);

	nursery = new nursery_space(young_size,aging_semispace->end);

	assert(seg->end - nursery->end <= deck_size);
}

data_heap::~data_heap()
{
	delete seg;
	delete nursery;
	delete aging;
	delete aging_semispace;
	delete tenured;
	delete[] cards;
	delete[] decks;
}

data_heap *data_heap::grow(cell requested_bytes)
{
	cell new_tenured_size = (tenured_size * 2) + requested_bytes;
	return new data_heap(young_size,
		aging_size,
		new_tenured_size);
}

template<typename Generation> void data_heap::clear_cards(Generation *gen)
{
	cell first_card = addr_to_card(gen->start - start);
	cell last_card = addr_to_card(gen->end - start);
	memset(&cards[first_card],0,last_card - first_card);
}

template<typename Generation> void data_heap::clear_decks(Generation *gen)
{
	cell first_deck = addr_to_deck(gen->start - start);
	cell last_deck = addr_to_deck(gen->end - start);
	memset(&decks[first_deck],0,last_deck - first_deck);
}

void data_heap::reset_generation(nursery_space *gen)
{
	gen->here = gen->start;
}

void data_heap::reset_generation(aging_space *gen)
{
	gen->here = gen->start;
	clear_cards(gen);
	clear_decks(gen);
	gen->starts.clear_object_start_offsets();
}

void data_heap::reset_generation(tenured_space *gen)
{
	clear_cards(gen);
	clear_decks(gen);
}

bool data_heap::low_memory_p()
{
	return (tenured->largest_free_block() <= nursery->size + aging->size);
}

void data_heap::mark_all_cards()
{
	memset(cards,-1,cards_end - cards);
	memset(decks,-1,decks_end - decks);
}

void factor_vm::set_data_heap(data_heap *data_)
{
	data = data_;
	nursery = *data->nursery;
	init_card_decks();
}

void factor_vm::init_data_heap(cell young_size, cell aging_size, cell tenured_size)
{
	set_data_heap(new data_heap(young_size,aging_size,tenured_size));
}

/* Size of the object pointed to by an untagged pointer */
cell object::size() const
{
	if(free_p()) return ((free_heap_block *)this)->size();

	switch(type())
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

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
cell object::binary_payload_start() const
{
	if(free_p()) return 0;

	switch(type())
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
		return array_size<array>(array_capacity((array*)this));
	case TUPLE_TYPE:
		return tuple_size(untag<tuple_layout>(((tuple *)this)->layout));
	case WRAPPER_TYPE:
		return sizeof(wrapper);
	default:
		critical_error("Invalid header",(cell)this);
                return 0; /* can't happen */
	}
}

data_heap_room factor_vm::data_room()
{
	data_heap_room room;

	room.nursery_size             = nursery.size;
	room.nursery_occupied         = nursery.occupied_space();
	room.nursery_free             = nursery.free_space();
	room.aging_size               = data->aging->size;
	room.aging_occupied           = data->aging->occupied_space();
	room.aging_free               = data->aging->free_space();
	room.tenured_size             = data->tenured->size;
	room.tenured_occupied         = data->tenured->occupied_space();
	room.tenured_total_free       = data->tenured->free_space();
	room.tenured_contiguous_free  = data->tenured->largest_free_block();
	room.tenured_free_block_count = data->tenured->free_block_count();
	room.cards                    = data->cards_end - data->cards;
	room.decks                    = data->decks_end - data->decks;
	room.mark_stack               = mark_stack.capacity() * sizeof(cell);

	return room;
}

void factor_vm::primitive_data_room()
{
	data_heap_room room = data_room();
	dpush(tag<byte_array>(byte_array_from_value(&room)));
}

struct object_accumulator {
	cell type;
	std::vector<cell> objects;

	explicit object_accumulator(cell type_) : type(type_) {}

	void operator()(object *obj)
	{
		if(type == TYPE_COUNT || obj->type() == type)
			objects.push_back(tag_dynamic(obj));
	}
};

cell factor_vm::instances(cell type)
{
	object_accumulator accum(type);
	each_object(accum);
	cell object_count = accum.objects.size();

	data_roots.push_back(data_root_range(&accum.objects[0],object_count));

	array *objects = allot_array(object_count,false_object);
	memcpy(objects->data(),&accum.objects[0],object_count * sizeof(cell));

	data_roots.pop_back();

	return tag<array>(objects);
}

void factor_vm::primitive_all_instances()
{
	primitive_full_gc();
	dpush(instances(TYPE_COUNT));
}

cell factor_vm::find_all_words()
{
	return instances(WORD_TYPE);
}

}
