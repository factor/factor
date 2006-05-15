#include "factor.h"

void relocate_object(CELL relocating)
{
	switch(untag_header(get(relocating)))
	{
	case RATIO_TYPE:
		fixup_ratio((F_RATIO*)relocating);
		break;
	case COMPLEX_TYPE:
		fixup_complex((F_COMPLEX*)relocating);
		break;
	case WORD_TYPE:
		fixup_word((F_WORD*)relocating);
		break;
	case ARRAY_TYPE:
	case TUPLE_TYPE:
	case QUOTATION_TYPE:
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
	case WRAPPER_TYPE:
		fixup_wrapper((F_WRAPPER*)relocating);
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

		allot_barrier(relocating);
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

void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,true);
}

CELL get_rel_symbol(F_REL* rel)
{
	CELL arg = REL_ARGUMENT(rel);
	F_ARRAY *pair = untag_array(get(compiling.base + arg * sizeof(CELL)));
	F_STRING *symbol = untag_string(AREF(pair,0));
	DLL* dll = (AREF(pair,1) == F ? NULL : untag_dll(AREF(pair,1)));
	CELL sym;

	if(dll != NULL && !dll->dll)
		return (CELL)undefined_symbol;

	sym = (CELL)ffi_dlsym(dll,symbol,false);

	if(!sym)
		return (CELL)undefined_symbol;

	return sym;
}

INLINE CELL compute_code_rel(F_REL *rel, CELL original)
{
	switch(REL_TYPE(rel))
	{
	case F_PRIMITIVE:
		return primitive_to_xt(REL_ARGUMENT(rel));
	case F_DLSYM:
		return get_rel_symbol(rel);
	case F_ABSOLUTE:
		return original + (compiling.base - code_relocation_base);
	case F_USERENV:
		return (CELL)&userenv[REL_ARGUMENT(rel)];
	case F_CARDS:
		return cards_offset;
	default:
		critical_error("Unsupported rel type",rel->type);
		return -1;
	}
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
		CELL original;
		CELL new_value;

		code_fixup(&rel->offset);
		
		switch(REL_CLASS(rel))
		{
		case REL_ABSOLUTE_CELL:
			original = get(rel->offset);
			break;
		case REL_ABSOLUTE:
			original = *(u32*)rel->offset;
			break;
		case REL_RELATIVE:
			original = *(u32*)rel->offset - (rel->offset + sizeof(u32));
			break;
		case REL_2_2:
			original = reloc_get_2_2(rel->offset);
			break;
		default:
			critical_error("Unsupported rel class",REL_CLASS(rel));
			return -1;
		}

		/* to_c_string can fill up the heap */
		maybe_gc(0);
		new_value = compute_code_rel(rel,original);

		switch(REL_CLASS(rel))
		{
		case REL_ABSOLUTE_CELL:
			put(rel->offset,new_value);
			break;
		case REL_ABSOLUTE:
			*(u32*)rel->offset = new_value;
			break;
		case REL_RELATIVE:
			*(u32*)rel->offset = new_value - (rel->offset + CELLS);
			break;
		case REL_2_2:
			reloc_set_2_2(rel->offset,new_value);
			break;
		default:
			critical_error("Unsupported rel class",REL_CLASS(rel));
			return -1;
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
