#include "master.hpp"

namespace factor
{

byte_array *factor_vm::allot_byte_array(cell size)
{
	byte_array *array = allot_uninitialized_array<byte_array>(size);
	memset(array + 1,0,size);
	return array;
}

void factor_vm::primitive_byte_array()
{
	cell size = unbox_array_size();
	dpush(tag<byte_array>(allot_byte_array(size)));
}

void factor_vm::primitive_uninitialized_byte_array()
{
	cell size = unbox_array_size();
	dpush(tag<byte_array>(allot_uninitialized_array<byte_array>(size)));
}

void factor_vm::primitive_resize_byte_array()
{
	data_root<byte_array> array(dpop(),this);
	array.untag_check(this);
	cell capacity = unbox_array_size();
	dpush(tag<byte_array>(reallot_array(array.untagged(),capacity)));
}

void growable_byte_array::append_bytes(void *elts, cell len)
{
	cell new_size = count + len;
	factor_vm *parent = elements.parent;
	if(new_size >= array_capacity(elements.untagged()))
		elements = parent->reallot_array(elements.untagged(),new_size * 2);

	memcpy(&elements->data<u8>()[count],elts,len);

	count += len;
}

void growable_byte_array::append_byte_array(cell byte_array_)
{
	data_root<byte_array> byte_array(byte_array_,elements.parent);

	cell len = array_capacity(byte_array.untagged());
	cell new_size = count + len;
	factor_vm *parent = elements.parent;
	if(new_size >= array_capacity(elements.untagged()))
		elements = parent->reallot_array(elements.untagged(),new_size * 2);

	memcpy(&elements->data<u8>()[count],byte_array->data<u8>(),len);

	count += len;
}

void growable_byte_array::trim()
{
	factor_vm *parent = elements.parent;
	elements = parent->reallot_array(elements.untagged(),count);
}

}
