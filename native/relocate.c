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
	case DLL_TYPE:
		fixup_dll((DLL*)relocating);
		break;
	case ALIEN_TYPE:
		fixup_alien((ALIEN*)relocating);
		break;
	case DISPLACED_ALIEN_TYPE:
		fixup_displaced_alien((DISPLACED_ALIEN*)relocating);
		break;
	}
}

INLINE CELL relocate_data_next(CELL relocating)
{
	CELL size = CELLS;
	CELL cell = get(relocating);

	allot_barrier(relocating);

	if(headerp(cell))
	{
		size = untagged_object_size(relocating);
		relocate_object(relocating);
	}
	else if(cell != F)
		data_fixup((CELL*)relocating);

	return relocating + size;
}

void relocate_data()
{
	CELL relocating = tenured.base;

	data_fixup(&userenv[BOOT_ENV]);
	data_fixup(&userenv[GLOBAL_ENV]);
	data_fixup(&T);
	data_fixup(&bignum_zero);
	data_fixup(&bignum_pos_one);
	data_fixup(&bignum_neg_one);

	for(;;)
	{
		if(relocating >= tenured.here)
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

CELL get_rel_symbol(F_REL* rel)
{
	F_CONS* cons = untag_cons(get(rel->argument));
	F_STRING* symbol = untag_string(cons->car);
	DLL* dll = (cons->cdr == F ? NULL : untag_dll(cons->cdr));
	return (CELL)ffi_dlsym(dll,symbol);
}

void relocate_dlsym(F_REL* rel, bool relative)
{
	CELL addr = get_rel_symbol(rel);
	put(rel->offset,addr - (relative ? rel->offset + CELLS : 0));
}

/* PowerPC-specific relocations */
void relocate_primitive_16_16(F_REL* rel)
{
	reloc_set_16_16((CELL*)rel->offset,primitive_to_xt(rel->argument));
}

void relocate_dlsym_16_16(F_REL* rel)
{
	reloc_set_16_16((CELL*)rel->offset,get_rel_symbol(rel));
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
		critical_error("Wrong compiled header",relocating);

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
		case F_ABSOLUTE_DLSYM_16_16:
			code_fixup(&rel->argument);
			relocate_dlsym_16_16(rel);
			break;
		case F_ABSOLUTE_16_16:
			code_fixup_16_16((CELL*)rel->offset);
			break;
		default:
			critical_error("Unsupported rel",rel->type);
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
		if(relocating >= compiling.here)
			break;

		relocating = relocate_code_next(relocating);
	}
}
