#include "master.hpp"

namespace factor
{

/* push a new tuple on the stack, filling its slots with f */
void factor_vm::primitive_tuple()
{
	gc_root<tuple_layout> layout(dpop(),this);
	tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
	t->layout = layout.value();

	memset_cell(t->data(),false_object,tuple_size(layout.untagged()) - sizeof(cell));

	dpush(t.value());
}

/* push a new tuple on the stack, filling its slots from the stack */
void factor_vm::primitive_tuple_boa()
{
	gc_root<tuple_layout> layout(dpop(),this);
	tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
	t->layout = layout.value();

	cell size = untag_fixnum(layout.untagged()->size) * sizeof(cell);
	memcpy(t->data(),(cell *)(ds - size + sizeof(cell)),size);
	ds -= size;

	dpush(t.value());
}

}
