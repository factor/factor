#include "factor.h"

void iterate_code_heap(CELL start, CELL end, CODE_HEAP_ITERATOR iter)
{
	while(start < end)
	{
		F_COMPILED *compiled = (F_COMPILED *)start;

		CELL code_start = start + sizeof(F_COMPILED);
		CELL reloc_start = code_start + compiled->code_length;
		CELL literal_start = reloc_start + compiled->reloc_length;
		CELL literal_end = literal_start + compiled->literal_length;

		iter(compiled,code_start,reloc_start,literal_start,literal_end);

		start = literal_end;
	}
}

void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,true);
}

#define LITERAL_REF(literal_start,num) ((literal_start) + CELLS * (num))

INLINE CELL get_literal(CELL literal_start, CELL num)
{
	if(!literal_start)
		critical_error("Only RT_LABEL relocations can appear in the label-relocation-table",0);

	return get(LITERAL_REF(literal_start,num));
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

CELL get_rel_word(F_REL *rel, CELL literal_start)
{
	CELL arg = REL_ARGUMENT(rel);
	F_WORD *word = untag_word(get_literal(literal_start,arg));
	return (CELL)word->xt;
}

INLINE CELL compute_code_rel(F_REL *rel,
	CELL code_start, CELL literal_start,
	F_VECTOR *labels)
{
	CELL offset = rel->offset + code_start;
	F_ARRAY *array;

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
		return LITERAL_REF(literal_start,REL_ARGUMENT(rel));
	case RT_WORD:
		return get_rel_word(rel,literal_start);
	case RT_LABEL:
		if(labels == NULL)
			critical_error("RT_LABEL can only appear in label-relocation-table",0);

		array = untag_array_fast(labels->array);
		return to_cell(get(AREF(array,REL_ARGUMENT(rel))))
			+ code_start;
	default:
		critical_error("Unsupported rel type",rel->type);
		return -1;
	}
}

INLINE void reloc_set_2_2(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}

void apply_relocation(F_REL *rel, CELL code_start, CELL literal_start,
	F_VECTOR *labels)
{
	CELL original;
	CELL absolute_value;
	CELL relative_value;
	CELL offset = rel->offset + code_start;

	/* to_c_string can fill up the heap */
	maybe_gc(0);
	absolute_value = compute_code_rel(rel,code_start,literal_start,labels);
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
		original = *(u32*)offset;
		original &= ~REL_RELATIVE_2_MASK;
		*(u32*)offset = (original | relative_value);
		break;
	case REL_RELATIVE_3:
		original = *(u32*)offset;
		original &= ~REL_RELATIVE_3_MASK;
		*(u32*)offset = (original | relative_value);
		break;
	default:
		critical_error("Unsupported rel class",REL_CLASS(rel));
		return;
	}
}

void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL literal_end)
{
	F_REL *rel = (F_REL *)reloc_start;
	F_REL *rel_end = (F_REL *)literal_start;

	/* apply relocations */
	while(rel < rel_end)
		apply_relocation(rel++,code_start,literal_start,NULL);
}

void collect_literals_step(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL literal_end)
{
	CELL scan;
	
	for(scan = literal_start; scan < literal_end; scan += CELLS)
		copy_handle((CELL*)scan);
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

void deposit_vector(F_VECTOR *vector, CELL format)
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
		CELL dest = compiling.here;

		for(i = 0; i < count; i++)
		{
			put(dest,to_fixnum(get(AREF(array,i))));
			dest += CELLS;
		}
	}
	else
		fatal_error("Bad format param to deposit_vector()",format);
	
	compiling.here += count * format;
}

void fixup_labels(F_VECTOR *label_rel, CELL code_start, CELL literal_start,
	F_VECTOR *labels)
{
	F_ARRAY *array = untag_array_fast(label_rel->array);
	CELL length = untag_fixnum_fast(label_rel->top);
	CELL i;
	
	for(i = 0; i < length; i += 2)
	{
		F_REL rel;
		rel.type = to_cell(get(AREF(array,i)));
		rel.offset = to_cell(get(AREF(array,i + 1)));
		apply_relocation(&rel,code_start,literal_start,labels);
	}
}

void add_compiled_block(CELL code_format, F_VECTOR *code, F_VECTOR *label_rel,
	F_VECTOR *labels, F_VECTOR *literals, F_VECTOR *rel)
{
	CELL start = compiling.here;
	CELL code_length = untag_fixnum_fast(code->top) * code_format;
	CELL rel_length = untag_fixnum_fast(rel->top) * CELLS;
	CELL literal_length = untag_fixnum_fast(literals->top) * CELLS;

	/* compiled header */
	F_COMPILED header;
	header.code_length = align8(code_length);
	header.reloc_length = rel_length;
	header.literal_length = literal_length;
	memcpy((void*)compiling.here,&header,sizeof(F_COMPILED));
	compiling.here += sizeof(F_COMPILED);
	
	/* code */
	deposit_vector(code,code_format);
	compiling.here = align8(compiling.here);

	/* relation info */
	deposit_vector(rel,CELLS);

	/* literals */
	deposit_vector(literals,CELLS);

	/* labels */
	fixup_labels(label_rel,start + sizeof(F_COMPILED),0,labels);

	/* push the XT of the new word on the stack */
	box_unsigned_cell(start + sizeof(F_COMPILED));
}

void primitive_add_compiled_block(void)
{
	CELL code_format = to_cell(dpop());
	F_VECTOR *code = untag_vector(dpop());
	F_VECTOR *label_rel = untag_vector(dpop());
	F_VECTOR *labels = untag_vector(dpop());
	F_VECTOR *literals = untag_vector(dpop());
	F_VECTOR *rel = untag_vector(dpop());

	add_compiled_block(code_format,code,label_rel,labels,literals,rel);
}

void primitive_finalize_compile(void)
{
	flush_icache((void*)last_flush,compiling.here - last_flush);
	iterate_code_heap(last_flush,compiling.here,finalize_code_block);
	last_flush = compiling.here;
}
