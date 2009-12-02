#include "master.hpp"

namespace factor
{

/* Simple code generator used by:
- profiler (profiler.cpp),
- quotation compiler (quotations.cpp),
- megamorphic caches (dispatch.cpp),
- polymorphic inline caches (inline_cache.cpp) */

/* Allocates memory */
jit::jit(code_block_type type_, cell owner_, factor_vm *vm)
	: type(type_),
	  owner(owner_,vm),
	  code(vm),
	  relocation(vm),
	  parameters(vm),
	  literals(vm),
	  computing_offset_p(false),
	  position(0),
	  offset(0),
	  parent(vm)
{}

void jit::emit_relocation(cell code_template_)
{
	data_root<array> code_template(code_template_,parent);
	cell capacity = array_capacity(code_template.untagged());
	for(cell i = 1; i < capacity; i += 3)
	{
		relocation_class rel_class = (relocation_class)untag_fixnum(array_nth(code_template.untagged(),i));
		relocation_type rel_type = (relocation_type)untag_fixnum(array_nth(code_template.untagged(),i + 1));
		cell offset = array_nth(code_template.untagged(),i + 2);

		relocation_entry new_entry(rel_type,rel_class,code.count + untag_fixnum(offset));
		relocation.append_bytes(&new_entry,sizeof(relocation_entry));
	}
}

/* Allocates memory */
void jit::emit(cell code_template_)
{
	data_root<array> code_template(code_template_,parent);

	emit_relocation(code_template.value());

	data_root<byte_array> insns(array_nth(code_template.untagged(),0),parent);

	if(computing_offset_p)
	{
		cell size = array_capacity(insns.untagged());

		if(offset == 0)
		{
			position--;
			computing_offset_p = false;
		}
		else if(offset < size)
		{
			position++;
			computing_offset_p = false;
		}
		else
			offset -= size;
	}

	code.append_byte_array(insns.value());
}

void jit::emit_with_literal(cell code_template_, cell argument_) {
	data_root<array> code_template(code_template_,parent);
	data_root<object> argument(argument_,parent);
	literal(argument.value());
	emit(code_template.value());
}

void jit::emit_with_parameter(cell code_template_, cell argument_) {
	data_root<array> code_template(code_template_,parent);
	data_root<object> argument(argument_,parent);
	parameter(argument.value());
	emit(code_template.value());
}

void jit::emit_class_lookup(fixnum index, cell type)
{
	emit_with_literal(parent->special_objects[PIC_LOAD],tag_fixnum(-index * sizeof(cell)));
	emit(parent->special_objects[type]);
}

/* Facility to convert compiled code offsets to quotation offsets.
Call jit_compute_offset() with the compiled code offset, then emit
code, and at the end jit->position is the quotation position. */
void jit::compute_position(cell offset_)
{
	computing_offset_p = true;
	position = 0;
	offset = offset_;
}

/* Allocates memory */
code_block *jit::to_code_block()
{
	code.trim();
	relocation.trim();
	parameters.trim();
	literals.trim();

	return parent->add_code_block(
		type,
		code.elements.value(),
		false_object, /* no labels */
		owner.value(),
		relocation.elements.value(),
		parameters.elements.value(),
		literals.elements.value());
}

}
