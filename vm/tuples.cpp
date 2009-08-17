#include "master.hpp"

namespace factor
{

/* push a new tuple on the stack */
tuple *factorvm::allot_tuple(cell layout_)
{
	gc_root<tuple_layout> layout(layout_,this);
	gc_root<tuple> t(allot<tuple>(tuple_size(layout.untagged())),this);
	t->layout = layout.value();
	return t.untagged();
}

tuple *allot_tuple(cell layout_)
{
	return vm->allot_tuple(layout_);
}

inline void factorvm::vmprim_tuple()
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
	PRIMITIVE_GETVM()->vmprim_tuple();
}

/* push a new tuple on the stack, filling its slots from the stack */
inline void factorvm::vmprim_tuple_boa()
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
	PRIMITIVE_GETVM()->vmprim_tuple_boa();
}

}
