DEFINE_UNTAG(F_ARRAY,ARRAY_TYPE,array)

INLINE CELL tag_array(F_ARRAY *array)
{
	return RETAG(array,ARRAY_TYPE);
}

F_ARRAY *allot_array(CELL capacity, CELL fill);

CELL allot_array_1(CELL obj);
CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

void primitive_array(void);
void primitive_resize_array(void);

struct growable_array {
	CELL count;
	gc_root<F_ARRAY> array;

	growable_array() : count(0), array(allot_array(2,F)) {}

	void add(CELL elt);
	void trim();
};
