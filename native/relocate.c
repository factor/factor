#include "factor.h"

void fixup(CELL* cell)
{
	if(TAG(*cell) != FIXNUM_TYPE && *cell != F)
		*cell += (active.base - relocation_base);
}

void relocate_object()
{
	switch(untag_header(get(relocating)))
	{
	case WORD_TYPE:
		fixup_word((WORD*)relocating);
		break;
	case ARRAY_TYPE:
		fixup_array((ARRAY*)relocating);
		break;
	case VECTOR_TYPE:
		fixup_vector((VECTOR*)relocating);
		break;
	case STRING_TYPE:
		hash_string((STRING*)relocating);
		break;
	case SBUF_TYPE:
		fixup_sbuf((SBUF*)relocating);
		break;
	case PORT_TYPE:
		fixup_port((PORT*)relocating);
		break;
	}

}

void relocate_next()
{
	CELL size = CELLS;

	switch(TAG(get(relocating)))
	{
	case HEADER_TYPE:
		size = untagged_object_size(relocating);
		relocate_object();
		break;
	case OBJECT_TYPE:
		if(get(relocating) == F)
			break;
		/* fall thru */
	default:
		fixup((CELL*)relocating);
		break;
	}
	relocating += size;
}

void init_object(CELL* handle, CELL type)
{
	if(untag_header(get(relocating)) != type)
		fatal_error("init_object() failed",get(relocating));
	*handle = tag_object((CELL*)relocating);
	relocate_next();
}

void relocate(CELL r)
{
	relocation_base = r;

	fixup(&userenv[BOOT_ENV]);
	fixup(&userenv[GLOBAL_ENV]);

	relocating = active.base;

	/* The first object in the image must always T */
	init_object(&T,T_TYPE);

	/* The next three must be bignum 0, 1, -1  */
	init_object(&bignum_zero,BIGNUM_TYPE);
	init_object(&bignum_pos_one,BIGNUM_TYPE);
	init_object(&bignum_neg_one,BIGNUM_TYPE);
	
	for(;;)
	{
		if(relocating >= active.here)
			break;

		relocate_next();
	}
}
