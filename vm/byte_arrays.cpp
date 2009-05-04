#include "master.hpp"

namespace factor
{

byte_array *allot_byte_array(cell size)
{
	byte_array *array = allot_array_internal<byte_array>(size);
	memset(array + 1,0,size);
	return array;
}

PRIMITIVE(byte_array)
{
	cell size = unbox_array_size();
	dpush(tag<byte_array>(allot_byte_array(size)));
}

PRIMITIVE(uninitialized_byte_array)
{
	cell size = unbox_array_size();
	dpush(tag<byte_array>(allot_array_internal<byte_array>(size)));
}

PRIMITIVE(resize_byte_array)
{
	byte_array *array = untag_check<byte_array>(dpop());
	cell capacity = unbox_array_size();
	dpush(tag<byte_array>(reallot_array(array,capacity)));
}

void growable_byte_array::append_bytes(void *elts, cell len)
{
	cell new_size = count + len;

	if(new_size >= array_capacity(elements.untagged()))
		elements = reallot_array(elements.untagged(),new_size * 2);

	memcpy(&elements->data<u8>()[count],elts,len);

	count += len;
}

void growable_byte_array::append_byte_array(cell byte_array_)
{
	gc_root<byte_array> byte_array(byte_array_);

	cell len = array_capacity(byte_array.untagged());
	cell new_size = count + len;

	if(new_size >= array_capacity(elements.untagged()))
		elements = reallot_array(elements.untagged(),new_size * 2);

	memcpy(&elements->data<u8>()[count],byte_array->data<u8>(),len);

	count += len;
}

void growable_byte_array::trim()
{
	elements = reallot_array(elements.untagged(),count);
}

}
