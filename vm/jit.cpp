#include "master.hpp"

/* Simple code generator used by:
- profiler (profiler.cpp),
- quotation compiler (quotations.cpp),
- megamorphic caches (dispatch.cpp),
- polymorphic inline caches (inline_cache.cpp) */

/* Allocates memory */
jit::jit(CELL type_, CELL owner_)
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

F_REL jit::rel_to_emit(CELL code_template, bool *rel_p)
{
	F_ARRAY *quadruple = untag_array_fast(code_template);
	CELL rel_class = array_nth(quadruple,1);
	CELL rel_type = array_nth(quadruple,2);
	CELL offset = array_nth(quadruple,3);

	if(rel_class == F)
	{
		*rel_p = false;
		return 0;
	}
	else
	{
		*rel_p = true;
		return (untag_fixnum_fast(rel_type) << 28)
			| (untag_fixnum_fast(rel_class) << 24)
			| ((code.count + untag_fixnum_fast(offset)));
	}
}

/* Allocates memory */
void jit::emit(CELL code_template_)
{
	gc_root<F_ARRAY> code_template(code_template_);

	bool rel_p;
	F_REL rel = rel_to_emit(code_template.value(),&rel_p);
	if(rel_p) relocation.append_bytes(&rel,sizeof(F_REL));

	gc_root<F_BYTE_ARRAY> insns(array_nth(code_template.untagged(),0));

	if(computing_offset_p)
	{
		CELL size = array_capacity(insns.untagged());

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

void jit::emit_with(CELL code_template_, CELL argument_) {
	gc_root<F_ARRAY> code_template(code_template_);
	gc_root<F_OBJECT> argument(argument_);
	literal(argument.value());
	emit(code_template.value());
}

void jit::emit_class_lookup(F_FIXNUM index, CELL type)
{
	emit_with(userenv[PIC_LOAD],tag_fixnum(-index * CELLS));
	emit(userenv[type]);
}

/* Facility to convert compiled code offsets to quotation offsets.
Call jit_compute_offset() with the compiled code offset, then emit
code, and at the end jit->position is the quotation position. */
void jit::compute_position(CELL offset_)
{
	computing_offset_p = true;
	position = 0;
	offset = offset_;
}

/* Allocates memory */
F_CODE_BLOCK *jit::code_block()
{
	code.trim();
	relocation.trim();
	literals.trim();

	return add_code_block(
		type,
		code.array.value(),
		F, /* no labels */
		relocation.array.value(),
		literals.array.value());
}


