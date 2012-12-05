namespace factor
{

struct growable_byte_array {
	cell count;
	data_root<byte_array> elements;

	explicit growable_byte_array(factor_vm *parent,cell capacity = 40) : count(0), elements(parent->allot_byte_array(capacity),parent) { }

	void grow_bytes(cell len);
	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

template<typename Type> byte_array *factor_vm::byte_array_from_value(Type *value)
{
	byte_array *data = allot_uninitialized_array<byte_array>(sizeof(Type));
	memcpy(data->data<char>(),value,sizeof(Type));
	return data;
}

}
