#include "master.hpp"

/* push a new tuple on the stack */
F_TUPLE *allot_tuple(CELL layout_)
{
	gc_root<F_TUPLE_LAYOUT> layout(layout_);
	gc_root<F_TUPLE> tuple(allot<F_TUPLE>(tuple_size(layout.untagged())));
	tuple->layout = layout.value();
	return tuple.untagged();
}

void primitive_tuple(void)
{
	gc_root<F_TUPLE_LAYOUT> layout(dpop());
	F_TUPLE *tuple = allot_tuple(layout.value());
	F_FIXNUM i;
	for(i = tuple_size(layout.untagged()) - 1; i >= 0; i--)
		put(AREF(tuple,i),F);

	dpush(tag<F_TUPLE>(tuple));
}

/* push a new tuple on the stack, filling its slots from the stack */
void primitive_tuple_boa(void)
{
	gc_root<F_TUPLE_LAYOUT> layout(dpop());
	gc_root<F_TUPLE> tuple(allot_tuple(layout.value()));
	CELL size = untag_fixnum(layout.untagged()->size) * CELLS;
	memcpy(tuple.untagged() + 1,(CELL *)(ds - (size - CELLS)),size);
	ds -= size;
	dpush(tuple.value());
}
