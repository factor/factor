#include "master.hpp"

F_BYTE_ARRAY *allot_byte_array(CELL size)
{
	F_BYTE_ARRAY *array = allot_array_internal<F_BYTE_ARRAY>(size);
	memset(array + 1,0,size);
	return array;
}

PRIMITIVE(byte_array)
{
	CELL size = unbox_array_size();
	dpush(tag<F_BYTE_ARRAY>(allot_byte_array(size)));
}

PRIMITIVE(uninitialized_byte_array)
{
	CELL size = unbox_array_size();
	dpush(tag<F_BYTE_ARRAY>(allot_array_internal<F_BYTE_ARRAY>(size)));
}

PRIMITIVE(resize_byte_array)
{
	F_BYTE_ARRAY *array = untag_check<F_BYTE_ARRAY>(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag<F_BYTE_ARRAY>(reallot_array(array,capacity)));
}

void growable_byte_array::append_bytes(void *elts, CELL len)
{
	CELL new_size = count + len;

	if(new_size >= array_capacity(array.untagged()))
		array = reallot_array(array.untagged(),new_size * 2);

	memcpy(&array->data<u8>()[count],elts,len);

	count += len;
}

void growable_byte_array::append_byte_array(CELL byte_array_)
{
	gc_root<F_BYTE_ARRAY> byte_array(byte_array_);

	CELL len = array_capacity(byte_array.untagged());
	CELL new_size = count + len;

	if(new_size >= array_capacity(array.untagged()))
		array = reallot_array(array.untagged(),new_size * 2);

	memcpy(&array->data<u8>()[count],byte_array->data<u8>(),len);

	count += len;
}

void growable_byte_array::trim()
{
	array = reallot_array(array.untagged(),count);
}
