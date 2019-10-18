#include "factor.h"

void iterate_code_heap(CELL start, CELL end, CODE_HEAP_ITERATOR iter)
{
	while(start < end)
	{
		F_COMPILED *compiled = (F_COMPILED *)start;

		CELL code_start = start + sizeof(F_COMPILED);
		CELL reloc_start = code_start + compiled->code_length;
		CELL literal_start = reloc_start + compiled->reloc_length;
		CELL words_start = literal_start + compiled->literal_length;
		CELL words_end = words_start + compiled->words_length;

		iter(compiled,
			code_start,reloc_start,
			literal_start,words_start);

		start = words_end;
	}
}

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

void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start)
{
	CELL words_end = words_start + relocating->words_length;

	F_REL *rel = (F_REL *)reloc_start;
	F_REL *rel_end = (F_REL *)literal_start;

	if(!relocating->finalized)
	{
		/* first time (ie, we just compiled, and are not simply loading
		an image from disk). figure out word XTs. */
		CELL scan;
		
		for(scan = words_start; scan < words_end; scan += CELLS)
			put(scan,untag_word(get(scan))->xt);

		relocating->finalized = true;
	}

	/* apply relocations */
	while(rel < rel_end)
		apply_relocation(rel++,code_start,literal_start,words_start);
}

void collect_literals_step(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start)
{
	CELL scan;
	
	CELL literal_end = literal_start + relocating->literal_length;
	CELL words_end = words_start + relocating->words_length;
	
	for(scan = literal_start; scan < literal_end; scan += CELLS)
		copy_handle((CELL*)scan);

	for(scan = words_start; scan < words_end; scan += CELLS)
	{
		if(!relocating->finalized)
			copy_handle((CELL*)scan);
	}
}

void collect_literals(void)
{
	iterate_code_heap(compiling.base,compiling.here,collect_literals_step);
}

void init_compiler(CELL size)
{
	compiling.base = compiling.here
		= (CELL)(alloc_bounded_block(size)->start);
	if(compiling.base == 0)
		fatal_error("Cannot allocate code heap",size);
	compiling.limit = compiling.base + size;
	last_flush = compiling.base;
}

void deposit_integers(F_VECTOR *vector, CELL format)
{
	CELL count = untag_fixnum_fast(vector->top);
	F_ARRAY *array = untag_array_fast(vector->array);
	CELL i;

	if(format == 1)
	{
		for(i = 0; i < count; i++)
			cput(compiling.here + i,to_fixnum(get(AREF(array,i))));
	}
	else if(format == CELLS)
	{
		for(i = 0; i < count; i++)
			put(CREF(compiling.here,i),to_fixnum(get(AREF(array,i))));
	}
	else
		critical_error("Bad format param to deposit_vector()",format);
}

void deposit_objects(F_VECTOR *vector, CELL literal_length)
{
	F_ARRAY *array = untag_array_fast(vector->array);
	memcpy((void*)compiling.here,array + 1,literal_length);
}

CELL add_compiled_block(CELL code_format, F_VECTOR *code,
	F_VECTOR *literals, F_VECTOR *words, F_VECTOR *rel)
{
	CELL start = compiling.here;

	CELL code_length = align8(untag_fixnum_fast(code->top) * code_format);
	CELL rel_length = untag_fixnum_fast(rel->top) * CELLS;
	CELL literal_length = untag_fixnum_fast(literals->top) * CELLS;
	CELL words_length = untag_fixnum_fast(words->top) * CELLS;

	/* compiled header */
	F_COMPILED header;
	header.code_length = code_length;
	header.reloc_length = rel_length;
	header.literal_length = literal_length;
	header.words_length = words_length;
	header.finalized = false;

	memcpy((void*)compiling.here,&header,sizeof(F_COMPILED));
	compiling.here += sizeof(F_COMPILED);
	
	/* code */
	deposit_integers(code,code_format);
	compiling.here += code_length;

	/* relation info */
	deposit_integers(rel,CELLS);
	compiling.here += rel_length;

	/* literals */
	deposit_objects(literals,literal_length);
	compiling.here += literal_length;

	/* words */
	deposit_objects(words,words_length);
	compiling.here += words_length;

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
	CELL count = untag_fixnum_fast(array->capacity);
	CELL i;
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(get(AREF(array,i)));
		F_WORD *word = untag_word(get(AREF(pair,0)));
		word->xt = to_cell(get(AREF(pair,1)));
	}
	
	flush_icache((void*)last_flush,compiling.here - last_flush);
	iterate_code_heap(last_flush,compiling.here,finalize_code_block);
	last_flush = compiling.here;
}
