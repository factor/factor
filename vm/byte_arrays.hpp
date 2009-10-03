namespace factor
{

struct growable_byte_array {
	cell count;
	gc_root<byte_array> elements;

	explicit growable_byte_array(factor_vm *myvm,cell capacity = 40) : count(0), elements(myvm->allot_byte_array(capacity),myvm) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

}
