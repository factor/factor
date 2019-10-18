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

	FACTOR_ASSERT(seg->end - nursery->end <= deck_size);
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

bool data_heap::high_fragmentation_p()
{
	return (tenured->largest_free_block() <= high_water_mark());
}

bool data_heap::low_memory_p()
{
	return (tenured->free_space() <= high_water_mark());
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

/* Allocates memory */
void factor_vm::primitive_data_room()
{
	data_heap_room room = data_room();
	ctx->push(tag<byte_array>(byte_array_from_value(&room)));
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

/* Allocates memory */
cell factor_vm::instances(cell type)
{
	object_accumulator accum(type);
	each_object(accum);
	return std_vector_to_array(accum.objects);
}

/* Allocates memory */
void factor_vm::primitive_all_instances()
{
	primitive_full_gc();
	ctx->push(instances(TYPE_COUNT));
}

}
