namespace factor
{

struct growable_byte_array {
	cell count;
	gc_root<byte_array> elements;

	explicit growable_byte_array(factor_vm *parent,cell capacity = 40) : count(0), elements(parent->allot_byte_array(capacity),parent) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

}
