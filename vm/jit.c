#include "master.h"

/* Simple code generator used by:
- profiler (profiler.c),
- quotation compiler (quotations.c),
- megamorphic caches (dispatch.c),
- polymorphic inline caches (inline_cache.c) */

/* Allocates memory */
void jit_init(F_JIT *jit, CELL jit_type, CELL owner)
{
	jit->owner = owner;
	REGISTER_ROOT(jit->owner);

	jit->type = jit_type;

	jit->code = make_growable_byte_array();
	REGISTER_ROOT(jit->code.array);
	jit->relocation = make_growable_byte_array();
	REGISTER_ROOT(jit->relocation.array);
	jit->literals = make_growable_array();
	REGISTER_ROOT(jit->literals.array);

	if(stack_traces_p())
		growable_array_add(&jit->literals,jit->owner);

	jit->computing_offset_p = false;
}

/* Facility to convert compiled code offsets to quotation offsets.
Call jit_compute_offset() with the compiled code offset, then emit
code, and at the end jit->position is the quotation position. */
void jit_compute_position(F_JIT *jit, CELL offset)
{
	jit->computing_offset_p = true;
	jit->position = 0;
	jit->offset = offset;
}

/* Allocates memory */
F_CODE_BLOCK *jit_make_code_block(F_JIT *jit)
{
	growable_byte_array_trim(&jit->code);
	growable_byte_array_trim(&jit->relocation);
	growable_array_trim(&jit->literals);

	F_CODE_BLOCK *code = add_code_block(
		jit->type,
		untag_object(jit->code.array),
		NULL, /* no labels */
		jit->relocation.array,
		jit->literals.array);

	return code;
}

void jit_dispose(F_JIT *jit)
{
	UNREGISTER_ROOT(jit->literals.array);
	UNREGISTER_ROOT(jit->relocation.array);
	UNREGISTER_ROOT(jit->code.array);
	UNREGISTER_ROOT(jit->owner);
}

static F_REL rel_to_emit(F_JIT *jit, CELL template, bool *rel_p)
{
	F_ARRAY *quadruple = untag_object(template);
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
			| ((jit->code.count + untag_fixnum_fast(offset)));
	}
}

/* Allocates memory */
void jit_emit(F_JIT *jit, CELL template)
{
	REGISTER_ROOT(template);

	bool rel_p;
	F_REL rel = rel_to_emit(jit,template,&rel_p);
	if(rel_p) growable_byte_array_append(&jit->relocation,&rel,sizeof(F_REL));

	F_BYTE_ARRAY *code = code_to_emit(template);

	if(jit->computing_offset_p)
	{
		CELL size = array_capacity(code);

		if(jit->offset == 0)
		{
			jit->position--;
			jit->computing_offset_p = false;
		}
		else if(jit->offset < size)
		{
			jit->position++;
			jit->computing_offset_p = false;
		}
		else
			jit->offset -= size;
	}

	growable_byte_array_append(&jit->code,code + 1,array_capacity(code));

	UNREGISTER_ROOT(template);
}

