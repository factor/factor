namespace factor
{

struct growable_byte_array {
	cell count;
	data_root<byte_array> elements;

	explicit growable_byte_array(factor_vm *parent,cell capacity = 40) : count(0), elements(parent->allot_byte_array(capacity),parent) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

template<typename Type> byte_array *factor_vm::byte_array_from_value(Type *value)
{
	return byte_array_from_values(value,1);
}

template<typename Type> byte_array *factor_vm::byte_array_from_values(Type *values, cell len)
{
	cell size = sizeof(Type) * len;
	byte_array *data = allot_uninitialized_array<byte_array>(size);
	memcpy(data->data<char>(),values,size);
	return data;
}

}
