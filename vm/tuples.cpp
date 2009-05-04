#include "master.hpp"

namespace factor
{

/* push a new tuple on the stack */
tuple *allot_tuple(cell layout_)
{
	gc_root<tuple_layout> layout(layout_);
	gc_root<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
	t->layout = layout.value();
	return t.untagged();
}

PRIMITIVE(tuple)
{
	gc_root<tuple_layout> layout(dpop());
	tuple *t = allot_tuple(layout.value());
	fixnum i;
	for(i = tuple_size(layout.untagged()) - 1; i >= 0; i--)
		t->data()[i] = F;

	dpush(tag<tuple>(t));
}

/* push a new tuple on the stack, filling its slots from the stack */
PRIMITIVE(tuple_boa)
{
	gc_root<tuple_layout> layout(dpop());
	gc_root<tuple> t(allot_tuple(layout.value()));
	cell size = untag_fixnum(layout.untagged()->size) * sizeof(cell);
	memcpy(t->data(),(cell *)(ds - (size - sizeof(cell))),size);
	ds -= size;
	dpush(t.value());
}

}
