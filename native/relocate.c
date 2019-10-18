#include "factor.h"

void relocate_object(CELL relocating)
{
	switch(untag_header(get(relocating)))
	{
	case WORD_TYPE:
		fixup_word((F_WORD*)relocating);
		break;
	case ARRAY_TYPE:
	case TUPLE_TYPE:
		fixup_array((F_ARRAY*)relocating);
		break;
	case HASHTABLE_TYPE:
		fixup_hashtable((F_HASHTABLE*)relocating);
		break;
	case VECTOR_TYPE:
		fixup_vector((F_VECTOR*)relocating);
		break;
	case STRING_TYPE:
		rehash_string((F_STRING*)relocating);
		break;
	case SBUF_TYPE:
		fixup_sbuf((F_SBUF*)relocating);
		break;
	case PORT_TYPE:
		fixup_port((F_PORT*)relocating);
		break;
	case DLL_TYPE:
		fixup_dll((DLL*)relocating);
		break;
	case ALIEN_TYPE:
		fixup_alien((ALIEN*)relocating);
		break;
	}
}

INLINE CELL relocate_data_next(CELL relocating)
{
	CELL size = CELLS;
	CELL cell = get(relocating);

	if(headerp(cell))
	{
		size = untagged_object_size(relocating);
		relocate_object(relocating);
	}
	else if(cell != F)
		data_fixup((CELL*)relocating);

	return relocating + size;
}

INLINE CELL init_object(CELL relocating, CELL* handle, CELL type)
{
	if(untag_header(get(relocating)) != type)
		fatal_error("init_object() failed",get(relocating));
	*handle = tag_object((CELL*)relocating);
	return relocate_data_next(relocating);
}

void relocate_data()
{
	CELL relocating = active.base;

	data_fixup(&userenv[BOOT_ENV]);
	data_fixup(&userenv[GLOBAL_ENV]);

	/* The first object in the image must always T */
	relocating = init_object(relocating,&T,T_TYPE);

	/* The next three must be bignum 0, 1, -1  */
	relocating = init_object(relocating,&bignum_zero,BIGNUM_TYPE);
	relocating = init_object(relocating,&bignum_pos_one,BIGNUM_TYPE);
	relocating = init_object(relocating,&bignum_neg_one,BIGNUM_TYPE);

	for(;;)
	{
		if(relocating >= active.here)
			break;

		relocating = relocate_data_next(relocating);
	}

	relocating = compiling.base;

	for(;;)
	{
		if(relocating >= literal_top)
			break;

		relocating = relocate_data_next(relocating);
	}
}

void relocate_primitive(F_REL* rel, bool relative)
{
	/* this is intended for x86, so the address is relative to after
	the insn, ie offset + CELLS. */
	put(rel->offset,primitive_to_xt(rel->argument)
		- (relative ? rel->offset + CELLS : 0));
}

void relocate_dlsym(F_REL* rel, bool relative)
{
	F_CONS* cons = untag_cons(get(rel->argument));
	F_STRING* symbol = untag_string(cons->car);
	DLL* dll = (cons->cdr == F ? NULL : untag_dll(cons->cdr));
	put(rel->offset,(CELL)ffi_dlsym(dll,symbol)
		- (relative ? rel->offset + CELLS : 0));
}

void relocate_primitive_16_16(F_REL* rel)
{
	reloc_set_16_16((CELL*)rel->offset,primitive_to_xt(rel->argument));
}

INLINE void code_fixup_16_16(CELL* cell)
{
	CELL difference = (compiling.base - code_relocation_base);
	reloc_set_16_16(cell,reloc_get_16_16(cell) + difference);
}

INLINE CELL relocate_code_next(CELL relocating)
{
	F_COMPILED* compiled = (F_COMPILED*)relocating;

	F_REL* rel = (F_REL*)(
		relocating + sizeof(F_COMPILED)
		+ compiled->code_length);

	F_REL* rel_end = (F_REL*)(
		relocating + sizeof(F_COMPILED)
		+ compiled->code_length
		+ compiled->reloc_length);

	if(compiled->header != COMPILED_HEADER)
		fatal_error("Wrong compiled header",relocating);

	while(rel < rel_end)
	{
		/* to_c_string can fill up the heap */
		maybe_garbage_collection();

		code_fixup(&rel->offset);

		switch(rel->type)
		{
		case F_RELATIVE_PRIMITIVE:
			relocate_primitive(rel,true);
			break;
		case F_ABSOLUTE_PRIMITIVE:
			relocate_primitive(rel,false);
			break;
		case F_RELATIVE_DLSYM:
			code_fixup(&rel->argument);
			relocate_dlsym(rel,true);
			break;
		case F_ABSOLUTE_DLSYM:
			code_fixup(&rel->argument);
			relocate_dlsym(rel,false);
			break;
		case F_ABSOLUTE:
			code_fixup((CELL*)rel->offset);
			break;
		case F_ABSOLUTE_PRIMITIVE_16_16:
			relocate_primitive_16_16(rel);
			break;
		case F_ABSOLUTE_16_16:
			code_fixup_16_16((CELL*)rel->offset);
			break;
		default:
			fatal_error("Unsupported rel",rel->type);
			break;
		}

		rel++;
	}

	return (CELL)rel_end;
}

void relocate_code()
{
	/* start relocating from the end of the space reserved for literals */
	CELL relocating = literal_max;

	for(;;)
	{
		/* fprintf(stderr,"relocation %d %d\n",relocating,compiling.here); */
		if(relocating >= compiling.here)
			break;

		relocating = relocate_code_next(relocating);
	}
}
