#include "master.hpp"

namespace factor
{

old_space::old_space(cell size_, cell start_) : zone(size_,start_)
{
	cell cards_size = size_ >> card_bits;
	object_start_offsets = new card[cards_size];
	object_start_offsets_end = object_start_offsets + cards_size;
}

old_space::~old_space()
{
	delete[] object_start_offsets;
}

/* we need to remember the first object allocated in the card */
void old_space::record_object_start_offset(object *obj)
{
	card *ptr = (card *)((((cell)obj - start) >> card_bits) + (cell)object_start_offsets);
	if(*ptr == card_starts_inside_object)
		*ptr = ((cell)obj & addr_card_mask);
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
	memset(object_start_offsets,card_starts_inside_object,size >> card_bits);
}

cell old_space::next_object_after(factor_vm *myvm, cell scan)
{
	cell size = myvm->untagged_object_size((object *)scan);
	if(scan + size < here)
		return scan + size;
	else
		return NULL;
}

}
