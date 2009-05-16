namespace factor
{

byte_array *allot_byte_array(cell size);

PRIMITIVE(byte_array);
PRIMITIVE(uninitialized_byte_array);
PRIMITIVE(resize_byte_array);

struct growable_byte_array {
	cell count;
	gc_root<byte_array> elements;

	growable_byte_array(cell capacity = 40) : count(0), elements(allot_byte_array(capacity)) { }

	void append_bytes(void *elts, cell len);
	void append_byte_array(cell elts);

	void trim();
};

}
