#include "master.hpp"

namespace factor
{

/* Allocates memory */
/* push a new tuple on the stack, filling its slots with f */
void factor_vm::primitive_tuple()
{
	data_root<tuple_layout> layout(ctx->pop(),this);
	tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
	t->layout = layout.value();

	memset_cell(t->data(),false_object,tuple_size(layout.untagged()) - sizeof(cell));

	ctx->push(t.value());
}

/* Allocates memory */
/* push a new tuple on the stack, filling its slots from the stack */
void factor_vm::primitive_tuple_boa()
{
	data_root<tuple_layout> layout(ctx->pop(),this);
	tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
	t->layout = layout.value();

	cell size = untag_fixnum(layout.untagged()->size) * sizeof(cell);
	memcpy(t->data(),(cell *)(ctx->datastack - size + sizeof(cell)),size);
	ctx->datastack -= size;

	ctx->push(t.value());
}

}
