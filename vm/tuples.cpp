#include "master.hpp"

namespace factor
{

/* push a new tuple on the stack */
F_TUPLE *allot_tuple(CELL layout_)
{
	gc_root<F_TUPLE_LAYOUT> layout(layout_);
	gc_root<F_TUPLE> tuple(allot<F_TUPLE>(tuple_size(layout.untagged())));
	tuple->layout = layout.value();
	return tuple.untagged();
}

PRIMITIVE(tuple)
{
	gc_root<F_TUPLE_LAYOUT> layout(dpop());
	F_TUPLE *tuple = allot_tuple(layout.value());
	F_FIXNUM i;
	for(i = tuple_size(layout.untagged()) - 1; i >= 0; i--)
		tuple->data()[i] = F;

	dpush(tag<F_TUPLE>(tuple));
}

/* push a new tuple on the stack, filling its slots from the stack */
PRIMITIVE(tuple_boa)
{
	gc_root<F_TUPLE_LAYOUT> layout(dpop());
	gc_root<F_TUPLE> tuple(allot_tuple(layout.value()));
	CELL size = untag_fixnum(layout.untagged()->size) * CELLS;
	memcpy(tuple->data(),(CELL *)(ds - (size - CELLS)),size);
	ds -= size;
	dpush(tuple.value());
}

}
