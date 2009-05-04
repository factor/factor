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

relocation_entry jit::rel_to_emit(cell code_template, bool *rel_p)
{
	array *quadruple = untag<array>(code_template);
	cell rel_class = array_nth(quadruple,1);
	cell rel_type = array_nth(quadruple,2);
	cell offset = array_nth(quadruple,3);

	if(rel_class == F)
	{
		*rel_p = false;
		return 0;
	}
	else
	{
		*rel_p = true;
		return (untag_fixnum(rel_type) << 28)
			| (untag_fixnum(rel_class) << 24)
			| ((code.count + untag_fixnum(offset)));
	}
}

/* Allocates memory */
void jit::emit(cell code_template_)
{
	gc_root<array> code_template(code_template_);

	bool rel_p;
	relocation_entry rel = rel_to_emit(code_template.value(),&rel_p);
	if(rel_p) relocation.append_bytes(&rel,sizeof(relocation_entry));

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
