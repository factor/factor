F_BYTE_ARRAY *allot_byte_array(CELL size);

void primitive_byte_array(void);
void primitive_uninitialized_byte_array(void);
void primitive_resize_byte_array(void);

/* Macros to simulate a byte vector in C */
struct growable_byte_array {
	CELL count;
	gc_root<F_BYTE_ARRAY> array;

	growable_byte_array() : count(0), array(allot_byte_array(2)) { }

	void append_bytes(void *elts, CELL len);
	void append_byte_array(CELL elts);

	void trim();
};
