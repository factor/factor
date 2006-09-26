#include "factor.h"

void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,true);
}

#define CREF(array,i) ((CELL)(array) + CELLS * (i))

INLINE CELL get_literal(CELL literal_start, CELL num)
{
	return get(CREF(literal_start,num));
}

CELL get_rel_symbol(F_REL *rel, CELL literal_start)
{
	CELL arg = REL_ARGUMENT(rel);
	F_ARRAY *pair = untag_array(get_literal(literal_start,arg));
	F_STRING *symbol = untag_string(get(AREF(pair,0)));
	CELL library = get(AREF(pair,1));
	DLL *dll = (library == F ? NULL : untag_dll(library));

	if(dll != NULL && !dll->dll)
		return (CELL)undefined_symbol;

	CELL sym = (CELL)ffi_dlsym(dll,symbol,false);

	if(!sym)
		return (CELL)undefined_symbol;

	return sym;
}

INLINE CELL compute_code_rel(F_REL *rel,
	CELL code_start, CELL literal_start, CELL words_start)
{
	CELL offset = code_start + rel->offset;

	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		return primitive_to_xt(REL_ARGUMENT(rel));
	case RT_DLSYM:
		return get_rel_symbol(rel,literal_start);
	case RT_HERE:
		return offset;
	case RT_CARDS:
		return cards_offset;
	case RT_LITERAL:
		return CREF(literal_start,REL_ARGUMENT(rel));
	case RT_XT:
		return get(CREF(words_start,REL_ARGUMENT(rel)));
	case RT_LABEL:
		return code_start + REL_ARGUMENT(rel);
	default:
		critical_error("Bad rel type",rel->type);
		return -1;
	}
}

INLINE void reloc_set_2_2(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}

INLINE void reloc_set_masked(CELL cell, CELL value, CELL mask)
{
	u32 original = *(u32*)cell;
	original &= ~mask;
	*(u32*)cell = (original | (value & mask));
}

void apply_relocation(F_REL *rel,
	CELL code_start, CELL literal_start, CELL words_start)
{
	CELL absolute_value;
	CELL relative_value;
	CELL offset = rel->offset + code_start;

	absolute_value = compute_code_rel(rel,
		code_start,literal_start,words_start);
	relative_value = absolute_value - offset;

	switch(REL_CLASS(rel))
	{
	case REL_ABSOLUTE_CELL:
		put(offset,absolute_value);
		break;
	case REL_ABSOLUTE:
		*(u32*)offset = absolute_value;
		break;
	case REL_RELATIVE:
		*(u32*)offset = relative_value - sizeof(u32);
		break;
	case REL_ABSOLUTE_2_2:
		reloc_set_2_2(offset,absolute_value);
		break;
	case REL_RELATIVE_2_2:
		reloc_set_2_2(offset,relative_value);
		break;
	case REL_RELATIVE_2:
		reloc_set_masked(offset,relative_value,REL_RELATIVE_2_MASK);
		break;
	case REL_RELATIVE_3:
		reloc_set_masked(offset,relative_value,REL_RELATIVE_3_MASK);
		break;
	default:
		critical_error("Bad rel class",REL_CLASS(rel));
		return;
	}
}

void relocate_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	F_REL *rel = (F_REL *)reloc_start;
	F_REL *rel_end = (F_REL *)literal_start;

	/* apply relocations */
	while(rel < rel_end)
		apply_relocation(rel++,code_start,literal_start,words_start);
}

void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	CELL scan;

	for(scan = words_start; scan < words_end; scan += CELLS)
		put(scan,untag_word(get(scan))->xt);

	relocating->finalized = true;

	relocate_code_block(relocating,code_start,reloc_start,
		literal_start,words_start,words_end);

	flush_icache(code_start,reloc_start - code_start);
}

void deposit_integers(CELL here, F_VECTOR *vector, CELL format)
{
	CELL count = untag_fixnum_fast(vector->top);
	F_ARRAY *array = untag_array_fast(vector->array);
	CELL i;

	if(format == 1)
	{
		for(i = 0; i < count; i++)
			cput(here + i,to_fixnum(get(AREF(array,i))));
	}
	else if(format == CELLS)
	{
		for(i = 0; i < count; i++)
			put(CREF(here,i),to_fixnum(get(AREF(array,i))));
	}
	else
		critical_error("Bad format param to deposit_vector()",format);
}

void deposit_objects(CELL here, F_VECTOR *vector, CELL literal_length)
{
	F_ARRAY *array = untag_array_fast(vector->array);
	memcpy((void*)here,array + 1,literal_length);
}

CELL add_compiled_block(CELL code_format, F_VECTOR *code,
	F_VECTOR *literals, F_VECTOR *words, F_VECTOR *rel)
{
	CELL code_length = align8(untag_fixnum_fast(code->top) * code_format);
	CELL rel_length = untag_fixnum_fast(rel->top) * CELLS;
	CELL literal_length = untag_fixnum_fast(literals->top) * CELLS;
	CELL words_length = untag_fixnum_fast(words->top) * CELLS;

	CELL total_length = sizeof(F_COMPILED) + code_length + rel_length
		+ literal_length + words_length;

	CELL start = heap_allot(&compiling,total_length);
	CELL here = start;

	/* compiled header */
	F_COMPILED header;
	header.code_length = code_length;
	header.reloc_length = rel_length;
	header.literal_length = literal_length;
	header.words_length = words_length;
	header.finalized = false;

	memcpy((void*)here,&header,sizeof(F_COMPILED));
	here += sizeof(F_COMPILED);

	/* code */
	deposit_integers(here,code,code_format);
	here += code_length;

	/* relation info */
	deposit_integers(here,rel,CELLS);
	here += rel_length;

	/* literals */
	deposit_objects(here,literals,literal_length);
	here += literal_length;

	/* words */
	deposit_objects(here,words,words_length);
	here += words_length;

	return start + sizeof(F_COMPILED);
}

void primitive_add_compiled_block(void)
{
	CELL code_format = to_cell(dpop());
	F_VECTOR *code = untag_vector(dpop());
	F_VECTOR *words = untag_vector(dpop());
	F_VECTOR *literals = untag_vector(dpop());
	F_VECTOR *rel = untag_vector(dpop());

	/* push the XT of the new word on the stack */
	box_unsigned_cell(add_compiled_block(code_format,code,literals,words,rel));
}

void primitive_finalize_compile(void)
{
	F_ARRAY *array = untag_array(dpop());

	/* set word XT's */
	CELL count = untag_fixnum_fast(array->capacity);
	CELL i;
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(get(AREF(array,i)));
		F_WORD *word = untag_word(get(AREF(pair,0)));
		word->xt = to_cell(get(AREF(pair,1)));
	}

	/* perform relocation */
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(get(AREF(array,i)));
		CELL xt = to_cell(get(AREF(pair,1)));
		iterate_code_heap_step(xt_to_compiled(xt),finalize_code_block);
	}
}
