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

}
