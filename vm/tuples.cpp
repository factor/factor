#include "master.hpp"

namespace factor
{

/* push a new tuple on the stack */
tuple *factor_vm::allot_tuple(cell layout_)
{
	gc_root<tuple_layout> layout(layout_,this);
	gc_root<tuple> t(allot<tuple>(tuple_size(layout.untagged())),this);
	t->layout = layout.value();
	return t.untagged();
}

inline void factor_vm::primitive_tuple()
{
	gc_root<tuple_layout> layout(dpop(),this);
	tuple *t = allot_tuple(layout.value());
	fixnum i;
	for(i = tuple_size(layout.untagged()) - 1; i >= 0; i--)
		t->data()[i] = F;

	dpush(tag<tuple>(t));
}

PRIMITIVE(tuple)
{
	PRIMITIVE_GETVM()->primitive_tuple();
}

/* push a new tuple on the stack, filling its slots from the stack */
inline void factor_vm::primitive_tuple_boa()
{
	gc_root<tuple_layout> layout(dpop(),this);
	gc_root<tuple> t(allot_tuple(layout.value()),this);
	cell size = untag_fixnum(layout.untagged()->size) * sizeof(cell);
	memcpy(t->data(),(cell *)(ds - (size - sizeof(cell))),size);
	ds -= size;
	dpush(t.value());
}

PRIMITIVE(tuple_boa)
{
	PRIMITIVE_GETVM()->primitive_tuple_boa();
}

}
