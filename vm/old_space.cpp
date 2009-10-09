#include "master.hpp"

namespace factor
{

old_space::old_space(cell size_, cell start_) : zone(size_,start_)
{
	cell cards_size = size_ >> card_bits;
	allot_markers = new card[cards_size];
	allot_markers_end = allot_markers + cards_size;
}

old_space::~old_space()
{
	delete[] allot_markers;
}

card *old_space::addr_to_allot_marker(object *a)
{
	return (card *)((((cell)a - start) >> card_bits) + (cell)allot_markers);
}

/* we need to remember the first object allocated in the card */
void old_space::record_allocation(object *obj)
{
	card *ptr = addr_to_allot_marker(obj);
	if(*ptr == invalid_allot_marker)
		*ptr = ((cell)obj & addr_card_mask);
}

object *old_space::allot(cell size)
{
	if(here + size > end) return NULL;

	object *obj = zone::allot(size);
	record_allocation(obj);
	return obj;
}

void old_space::clear_allot_markers()
{
	memset(allot_markers,invalid_allot_marker,size >> card_bits);
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
