#include "master.hpp"

namespace factor
{

callback_heap::callback_heap(cell size, factor_vm *parent_) :
	seg(new segment(size,true)),
	here(seg->start),
	parent(parent_) {}

callback_heap::~callback_heap()
{
	delete seg;
	seg = NULL;
}

void factor_vm::init_callbacks(cell size)
{
	callbacks = new callback_heap(size,this);
}

void callback_heap::update(callback *stub)
{
	tagged<array> code_template(parent->userenv[CALLBACK_STUB]);

	cell rel_class = untag_fixnum(array_nth(code_template.untagged(),1));
	cell offset = untag_fixnum(array_nth(code_template.untagged(),3));

	parent->store_address_in_code_block(rel_class,
		(cell)(stub + 1) + offset,
		(cell)(stub->compiled + 1));

	flush_icache((cell)stub,stub->size);
}

callback *callback_heap::add(code_block *compiled)
{
	tagged<array> code_template(parent->userenv[CALLBACK_STUB]);
	tagged<byte_array> insns(array_nth(code_template.untagged(),0));
	cell size = array_capacity(insns.untagged());

	cell bump = align(size,sizeof(cell)) + sizeof(callback);
	if(here + bump > seg->end) fatal_error("Out of callback space",0);

	callback *stub = (callback *)here;
	stub->compiled = compiled;
	memcpy(stub + 1,insns->data<void>(),size);

	stub->size = align(size,sizeof(cell));
	here += bump;

	update(stub);

	return stub;
}

void factor_vm::primitive_callback()
{
	tagged<word> w(dpop());
	w.untag_check(this);

	callback *stub = callbacks->add(w->code);
	box_alien(stub + 1);
}

}
