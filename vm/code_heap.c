#include "master.h"

/* References to undefined symbols are patched up to call this function on
image load */
void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

#define CREF(array,i) ((CELL)(array) + CELLS * (i))

INLINE CELL get_literal(CELL literals_start, CELL num)
{
	return get(CREF(literals_start,num));
}

/* Look up an external library symbol referenced by a compiled code block */
void *get_rel_symbol(F_REL *rel, CELL literals_start)
{
	CELL arg = REL_ARGUMENT(rel);
	F_SYMBOL *symbol = alien_offset(get_literal(literals_start,arg));
	CELL library = get_literal(literals_start,arg + 1);
	F_DLL *dll = (library == F ? NULL : untag_dll(library));

	if(dll != NULL && !dll->dll)
		return undefined_symbol;

	if(!symbol)
		return undefined_symbol;

	void *sym = ffi_dlsym(dll,symbol);

	if(sym)
		return sym;
	else
		return undefined_symbol;
}

/* Compute an address to store at a relocation */
INLINE CELL compute_code_rel(F_REL *rel,
	CELL code_start, CELL literals_start, CELL words_start)
{
	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		return (CELL)primitives[REL_ARGUMENT(rel)];
	case RT_DLSYM:
		return (CELL)get_rel_symbol(rel,literals_start);
	case RT_LITERAL:
		return CREF(literals_start,REL_ARGUMENT(rel));
	case RT_DISPATCH:
		return CREF(words_start,REL_ARGUMENT(rel));
	case RT_XT:
		return get(CREF(words_start,REL_ARGUMENT(rel)));
	case RT_LABEL:
		return code_start + REL_ARGUMENT(rel);
	default:
		critical_error("Bad rel type",rel->type);
		return -1;
	}
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
INLINE void reloc_set_2_2(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}

/* Store a value into a bitfield of a PowerPC instruction */
INLINE void reloc_set_masked(CELL cell, F_FIXNUM value, CELL mask, F_FIXNUM shift)
{
	u32 original = *(u32*)cell;
	original &= ~mask;
	*(u32*)cell = (original | ((value >> shift) & mask));
}

/* Perform a fixup on a code block */
void apply_relocation(CELL class, CELL offset, F_FIXNUM absolute_value)
{
	F_FIXNUM relative_value = absolute_value - offset;

	switch(class)
	{
	case RC_ABSOLUTE_CELL:
		put(offset,absolute_value);
		break;
	case RC_ABSOLUTE:
		*(u32*)offset = absolute_value;
		break;
	case RC_RELATIVE:
		*(u32*)offset = relative_value - sizeof(u32);
		break;
	case RC_ABSOLUTE_PPC_2_2:
		reloc_set_2_2(offset,absolute_value);
		break;
	case RC_RELATIVE_PPC_2:
		reloc_set_masked(offset,relative_value,REL_RELATIVE_PPC_2_MASK,0);
		break;
	case RC_RELATIVE_PPC_3:
		reloc_set_masked(offset,relative_value,REL_RELATIVE_PPC_3_MASK,0);
		break;
	case RC_RELATIVE_ARM_3:
		reloc_set_masked(offset,relative_value - CELLS * 2,
			REL_RELATIVE_ARM_3_MASK,2);
		break;
	case RC_INDIRECT_ARM:
		reloc_set_masked(offset,relative_value - CELLS,
			REL_INDIRECT_ARM_MASK,0);
		break;
	case RC_INDIRECT_ARM_PC:
		reloc_set_masked(offset,relative_value - CELLS * 2,
			REL_INDIRECT_ARM_MASK,0);
		break;
	default:
		critical_error("Bad rel class",class);
		break;
	}
}

/* Perform all fixups on a code block */
void relocate_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end)
{
	F_REL *rel = (F_REL *)reloc_start;
	F_REL *rel_end = (F_REL *)literals_start;

	while(rel < rel_end)
	{
		CELL offset = rel->offset + code_start;

		F_FIXNUM absolute_value = compute_code_rel(rel,
			code_start,literals_start,words_start);

		apply_relocation(REL_CLASS(rel),offset,absolute_value);

		rel++;
	}
}

/* Fixup labels. This is done at compile time, not image load time */
void fixup_labels(F_ARRAY *labels, CELL code_format, CELL code_start)
{
	CELL i;
	CELL size = array_capacity(labels);

	for(i = 0; i < size; i += 3)
	{
		CELL class = to_fixnum(array_nth(labels,i));
		CELL offset = to_fixnum(array_nth(labels,i + 1));
		CELL target = to_fixnum(array_nth(labels,i + 2));

		apply_relocation(class,
			offset + code_start,
			target + code_start);
	}
}

/* After compiling a batch of words, we replace all mutual word references with
direct XT references, and perform fixups */
void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end)
{
	CELL scan;

	if(relocating->finalized != false)
		critical_error("Finalizing a finalized block",(CELL)relocating);

	for(scan = words_start; scan < words_end; scan += CELLS)
		put(scan,(CELL)(untag_word(get(scan))->xt));

	relocating->finalized = true;

	relocate_code_block(relocating,code_start,reloc_start,
		literals_start,words_start,words_end);

	flush_icache(code_start,reloc_start - code_start);
}

/* Write a sequence of integers to memory, with 'format' bytes per integer */
void deposit_integers(CELL here, F_ARRAY *array, CELL format)
{
	CELL count = array_capacity(array);
	CELL i;

	for(i = 0; i < count; i++)
	{
		F_FIXNUM value = to_fixnum(array_nth(array,i));
		if(format == 1)
			cput(here + i,value);
		else if(format == sizeof(unsigned int))
			*(unsigned int *)(here + format * i) = value;
		else if(format == CELLS)
			put(CREF(here,i),value);
		else
			critical_error("Bad format in deposit_integers()",format);
	}
}

/* Write a sequence of tagged pointers to memory */
void deposit_objects(CELL here, F_ARRAY *array)
{
	memcpy((void*)here,array + 1,array_capacity(array) * CELLS);
}

CELL compiled_code_format(void)
{
	return untag_fixnum_fast(userenv[JIT_CODE_FORMAT]);
}

CELL allot_code_block(CELL size)
{
	CELL start = heap_allot(&code_heap,size);

	/* If allocation failed, do a code GC */
	if(start == 0)
	{
		code_gc();
		start = heap_allot(&code_heap,size);

		/* Insufficient room even after code GC, give up */
		if(start == 0)
			critical_error("Out of memory in add-compiled-block",0);
	}

	return start;
}

XT add_compiled_block(
	CELL type,
	F_ARRAY *code,
	F_ARRAY *labels,
	F_ARRAY *rel,
	F_ARRAY *words,
	F_ARRAY *literals)
{
	CELL code_format = compiled_code_format();

	CELL code_length = align8(array_capacity(code) * code_format);
	CELL rel_length = (rel ? array_capacity(rel) * sizeof(unsigned int) : 0);
	CELL words_length = (words ? array_capacity(words) * CELLS : 0);
	CELL literals_length = (literals ? array_capacity(literals) * CELLS : 0);

	REGISTER_UNTAGGED(code);
	REGISTER_UNTAGGED(labels);
	REGISTER_UNTAGGED(rel);
	REGISTER_UNTAGGED(words);
	REGISTER_UNTAGGED(literals);

	CELL start = allot_code_block(sizeof(F_COMPILED) + code_length
		+ rel_length + literals_length + words_length);

	UNREGISTER_UNTAGGED(literals);
	UNREGISTER_UNTAGGED(words);
	UNREGISTER_UNTAGGED(rel);
	UNREGISTER_UNTAGGED(labels);
	UNREGISTER_UNTAGGED(code);

	/* begin depositing the code block's contents */
	CELL here = start;

	/* compiled header */
	F_COMPILED *header = (void *)here;
	header->type = type;
	header->code_length = code_length;
	header->reloc_length = rel_length;
	header->literals_length = literals_length;
	header->words_length = words_length;
	header->finalized = false;

	here += sizeof(F_COMPILED);

	/* code */
	deposit_integers(here,code,code_format);
	here += code_length;

	/* relation info */
	if(rel)
	{
		deposit_integers(here,rel,sizeof(unsigned int));
		here += rel_length;
	}

	/* literals */
	if(literals)
	{
		deposit_objects(here,literals);
		here += literals_length;
	}

	/* words */
	if(words)
	{
		deposit_objects(here,words);
		here += words_length;
	}

	/* compute the XT */
	XT xt = (XT)(start + sizeof(F_COMPILED));

	/* fixup labels */
	if(labels)
		fixup_labels(labels,code_format,(CELL)xt);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	last_code_heap_scan = NURSERY;

	return xt;
}

DEFINE_PRIMITIVE(add_compiled_block)
{
	F_ARRAY *code = untag_array(dpop());
	F_ARRAY *labels = untag_array(dpop());
	F_ARRAY *rel = untag_array(dpop());
	F_ARRAY *words = untag_array(dpop());
	F_ARRAY *literals = untag_array(dpop());

	XT xt = add_compiled_block(WORD_TYPE,code,labels,rel,words,literals);

	/* push the XT of the new word on the stack */
	F_WORD *word = allot_word(F,F);
	word->xt = xt;
	word->compiledp = T;
	dpush(tag_object(word));
}

/* After batch compiling a bunch of words, perform various fixups to make them
executable */
DEFINE_PRIMITIVE(finalize_compile)
{
	F_ARRAY *array = untag_array(dpop());

	/* set word XT's */
	CELL count = untag_fixnum_fast(array->capacity);
	CELL i;
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(array_nth(array,i));
		F_WORD *word = untag_word(array_nth(pair,0));
		XT xt = untag_word(array_nth(pair,1))->xt;
		F_BLOCK *block = xt_to_block(xt);
		if(block->status != B_ALLOCATED)
			critical_error("bad XT",(CELL)xt);

		word->xt = xt;
		word->compiledp = T;
	}

	/* perform relocation */
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(array_nth(array,i));
		F_WORD *word = untag_word(array_nth(pair,0));
		XT xt = word->xt;
		iterate_code_heap_step(xt_to_compiled(xt),finalize_code_block);
	}
}
