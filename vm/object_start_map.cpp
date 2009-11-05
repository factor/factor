#include "master.hpp"

namespace factor
{

object_start_map::object_start_map(cell size_, cell start_) :
	size(size_), start(start_)
{
	object_start_offsets = new card[addr_to_card(size_)];
	object_start_offsets_end = object_start_offsets + addr_to_card(size_);
	clear_object_start_offsets();
}

object_start_map::~object_start_map()
{
	delete[] object_start_offsets;
}

cell object_start_map::first_object_in_card(cell card_index)
{
	return object_start_offsets[card_index];
}

cell object_start_map::find_object_containing_card(cell card_index)
{
	if(card_index == 0)
		return start;
	else
	{
		card_index--;

		while(first_object_in_card(card_index) == card_starts_inside_object)
		{
#ifdef FACTOR_DEBUG
			/* First card should start with an object */
			assert(card_index > 0);
#endif
			card_index--;
		}

		return start + (card_index << card_bits) + first_object_in_card(card_index);
	}
}

/* we need to remember the first object allocated in the card */
void object_start_map::record_object_start_offset(object *obj)
{
	cell idx = addr_to_card((cell)obj - start);
	card obj_start = ((cell)obj & addr_card_mask);
	object_start_offsets[idx] = std::min(object_start_offsets[idx],obj_start);
}

void object_start_map::clear_object_start_offsets()
{
	memset(object_start_offsets,card_starts_inside_object,addr_to_card(size));
}

void object_start_map::update_card_for_sweep(cell index, u16 mask)
{
	cell offset = object_start_offsets[index];
	if(offset != card_starts_inside_object)
	{
		mask >>= (offset / block_granularity);

		if(mask == 0)
		{
			/* The rest of the block after the old object start is free */
			object_start_offsets[index] = card_starts_inside_object;
		}
		else
		{
			/* Move the object start forward if necessary */
			object_start_offsets[index] = offset + (rightmost_set_bit(mask) * block_granularity);
		}
	}
}

void object_start_map::update_for_sweep(mark_bits<object> *state)
{
	for(cell index = 0; index < state->bits_size; index++)
	{
		u64 mask = state->marked[index];
		update_card_for_sweep(index * 4,      mask        & 0xffff);
		update_card_for_sweep(index * 4 + 1, (mask >> 16) & 0xffff);
		update_card_for_sweep(index * 4 + 2, (mask >> 32) & 0xffff);
		update_card_for_sweep(index * 4 + 3, (mask >> 48) & 0xffff);
	}
}

}
