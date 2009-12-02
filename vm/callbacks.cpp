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

void callback_heap::update(code_block *stub)
{
	tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);

	cell rel_class = untag_fixnum(array_nth(code_template.untagged(),1));
	cell rel_type = untag_fixnum(array_nth(code_template.untagged(),2));
	cell offset = untag_fixnum(array_nth(code_template.untagged(),3));

	relocation_entry rel(
		(relocation_type)rel_type,
		(relocation_class)rel_class,
		offset);

	instruction_operand op(rel,stub,0);
	op.store_value((cell)callback_xt(stub));

	stub->flush_icache();
}

code_block *callback_heap::add(cell owner)
{
	tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
	tagged<byte_array> insns(array_nth(code_template.untagged(),0));
	cell size = array_capacity(insns.untagged());

	cell bump = align(size + sizeof(code_block),data_alignment);
	if(here + bump > seg->end) fatal_error("Out of callback space",0);

	free_heap_block *free_block = (free_heap_block *)here;
	free_block->make_free(bump);
	here += bump;

	code_block *stub = (code_block *)free_block;
	stub->owner = owner;
	stub->literals = false_object;
	stub->relocation = false_object;

	memcpy(stub->xt(),insns->data<void>(),size);
	update(stub);

	return stub;
}

void factor_vm::primitive_callback()
{
	tagged<word> w(dpop());
	w.untag_check(this);
	box_alien(callbacks->add(w.value())->xt());
}

}
