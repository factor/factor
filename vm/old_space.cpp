#include "master.hpp"

namespace factor
{

old_space::old_space(cell size_, cell start_) : zone(size_,start_)
{
	object_start_offsets = new card[addr_to_card(size_)];
	object_start_offsets_end = object_start_offsets + addr_to_card(size_);
}

old_space::~old_space()
{
	delete[] object_start_offsets;
}

cell old_space::first_object_in_card(cell card_index)
{
	return object_start_offsets[card_index];
}

cell old_space::find_object_containing_card(cell card_index)
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
void old_space::record_object_start_offset(object *obj)
{
	cell idx = addr_to_card((cell)obj - start);
	if(object_start_offsets[idx] == card_starts_inside_object)
		object_start_offsets[idx] = ((cell)obj & addr_card_mask);
}

object *old_space::allot(cell size)
{
	if(here + size > end) return NULL;

	object *obj = zone::allot(size);
	record_object_start_offset(obj);
	return obj;
}

void old_space::clear_object_start_offsets()
{
	memset(object_start_offsets,card_starts_inside_object,addr_to_card(size));
}

cell old_space::next_object_after(factor_vm *parent, cell scan)
{
	cell size = parent->untagged_object_size((object *)scan);
	if(scan + size < here)
		return scan + size;
	else
		return 0;
}

}
