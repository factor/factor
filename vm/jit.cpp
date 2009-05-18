#include "master.hpp"

namespace factor
{

/* Simple code generator used by:
- profiler (profiler.cpp),
- quotation compiler (quotations.cpp),
- megamorphic caches (dispatch.cpp),
- polymorphic inline caches (inline_cache.cpp) */

/* Allocates memory */
jit::jit(cell type_, cell owner_)
	: type(type_),
	  owner(owner_),
	  code(),
	  relocation(),
	  literals(),
	  computing_offset_p(false),
	  position(0),
	  offset(0)
{
	if(stack_traces_p()) literal(owner.value());
}

void jit::emit_relocation(cell code_template_)
{
	gc_root<array> code_template(code_template_);
	cell capacity = array_capacity(code_template.untagged());
	for(cell i = 1; i < capacity; i += 3)
	{
		cell rel_class = array_nth(code_template.untagged(),i);
		cell rel_type = array_nth(code_template.untagged(),i + 1);
		cell offset = array_nth(code_template.untagged(),i + 2);

		relocation_entry new_entry
			= (untag_fixnum(rel_type) << 28)
			| (untag_fixnum(rel_class) << 24)
			| ((code.count + untag_fixnum(offset)));
		relocation.append_bytes(&new_entry,sizeof(relocation_entry));
	}
}

/* Allocates memory */
void jit::emit(cell code_template_)
{
	gc_root<array> code_template(code_template_);

	emit_relocation(code_template.value());

	gc_root<byte_array> insns(array_nth(code_template.untagged(),0));

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

void jit::emit_with(cell code_template_, cell argument_) {
	gc_root<array> code_template(code_template_);
	gc_root<object> argument(argument_);
	literal(argument.value());
	emit(code_template.value());
}

void jit::emit_class_lookup(fixnum index, cell type)
{
	emit_with(userenv[PIC_LOAD],tag_fixnum(-index * sizeof(cell)));
	emit(userenv[type]);
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
	literals.trim();

	return add_code_block(
		type,
		code.elements.value(),
		F, /* no labels */
		relocation.elements.value(),
		literals.elements.value());
}

}
