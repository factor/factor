#include "master.h"

/* push a new tuple on the stack */
F_TUPLE *allot_tuple(F_TUPLE_LAYOUT *layout)
{
	REGISTER_UNTAGGED(layout);
	F_TUPLE *tuple = allot_object(TUPLE_TYPE,tuple_size(layout));
	UNREGISTER_UNTAGGED(layout);
	tuple->layout = tag_array((F_ARRAY *)layout);
	return tuple;
}

void primitive_tuple(void)
{
	F_TUPLE_LAYOUT *layout = untag_object(dpop());
	F_FIXNUM size = untag_fixnum_fast(layout->size);

	F_TUPLE *tuple = allot_tuple(layout);
	F_FIXNUM i;
	for(i = size - 1; i >= 0; i--)
		put(AREF(tuple,i),F);

	dpush(tag_tuple(tuple));
}

/* push a new tuple on the stack, filling its slots from the stack */
void primitive_tuple_boa(void)
{
	F_TUPLE_LAYOUT *layout = untag_object(dpop());
	F_FIXNUM size = untag_fixnum_fast(layout->size);
	F_TUPLE *tuple = allot_tuple(layout);
	memcpy(tuple + 1,(CELL *)(ds - CELLS * (size - 1)),CELLS * size);
	ds -= CELLS * size;
	dpush(tag_tuple(tuple));
}
