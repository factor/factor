#include "factor.h"

void fixup(CELL* cell)
{
	if(TAG(*cell) != FIXNUM_TYPE)
		*cell += (active->base - relocation_base);
}

void relocate_object()
{
	CELL size;
	size = untagged_object_size(relocating);
	switch(untag_header(get(relocating)))
	{
	case ARRAY_TYPE:
		fixup_array((ARRAY*)relocating);
		break;
	case VECTOR_TYPE:
		fixup_vector((VECTOR*)relocating);
		break;
	case SBUF_TYPE:
		fixup_sbuf((SBUF*)relocating);
		break;
	}

	relocating += size;
}

void relocate_next()
{
	switch(TAG(get(relocating)))
	{
	case XT_TYPE:
		fixup_word((WORD*)relocating);
		relocating += sizeof(WORD);
		break;
	case HEADER_TYPE:
		relocate_object();
		break;
	default:
		fixup((CELL*)relocating);
		relocating += CELLS;
	}
}

void relocate(CELL r)
{
	relocation_base = r;

	fixup(&env.boot);
	fixup(&env.user[GLOBAL_ENV]);

	relocating = active->base;

	/* The first three objects in the image must always be
	   EMPTY, F, T */
	if(untag_header(get(relocating)) != EMPTY_TYPE)
		fatal_error("Not empty",get(relocating));
	empty = tag_object(relocating);
	relocate_next();

	if(untag_header(get(relocating)) != F_TYPE)
		fatal_error("Not F",get(relocating));
	F = tag_object(relocating);
	relocate_next();

	if(untag_header(get(relocating)) != T_TYPE)
		fatal_error("Not T",get(relocating));
	T = tag_object(relocating);
	relocate_next();

	for(;;)
	{
		if(relocating >= active->here)
			break;

		relocate_next();
	}
}
