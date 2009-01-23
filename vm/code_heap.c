#include "master.h"

/* References to undefined symbols are patched up to call this function on
image load */
void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

INLINE CELL get_literal(CELL literals_start, CELL num)
{
	return get(CREF(literals_start,num));
}

/* Look up an external library symbol referenced by a compiled code block */
void *get_rel_symbol(F_REL *rel, CELL literals_start)
{
	CELL arg = REL_ARGUMENT(rel);
	CELL symbol = get_literal(literals_start,arg);
	CELL library = get_literal(literals_start,arg + 1);

	F_DLL *dll = (library == F ? NULL : untag_dll(library));

	if(dll != NULL && !dll->dll)
		return undefined_symbol;

	if(type_of(symbol) == BYTE_ARRAY_TYPE)
	{
		F_SYMBOL *name = alien_offset(symbol);
		void *sym = ffi_dlsym(dll,name);

		if(sym)
			return sym;
	}
	else if(type_of(symbol) == ARRAY_TYPE)
	{
		CELL i;
		F_ARRAY *names = untag_object(symbol);
		for(i = 0; i < array_capacity(names); i++)
		{
			F_SYMBOL *name = alien_offset(array_nth(names,i));
			void *sym = ffi_dlsym(dll,name);

			if(sym)
				return sym;
		}
	}

	return undefined_symbol;
}

/* Compute an address to store at a relocation */
INLINE CELL compute_code_rel(F_REL *rel,
	CELL code_start, CELL literals_start)
{
	CELL obj;

	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		return (CELL)primitives[REL_ARGUMENT(rel)];
	case RT_DLSYM:
		return (CELL)get_rel_symbol(rel,literals_start);
	case RT_IMMEDIATE:
		return get(CREF(literals_start,REL_ARGUMENT(rel)));
	case RT_XT:
		obj = get(CREF(literals_start,REL_ARGUMENT(rel)));
		if(type_of(obj) == WORD_TYPE)
			return (CELL)untag_word(obj)->xt;
		else
			return (CELL)untag_quotation(obj)->xt;
	case RT_HERE:
		return rel->offset + code_start + (short)REL_ARGUMENT(rel);
	case RT_LABEL:
		return code_start + REL_ARGUMENT(rel);
	case RT_STACK_CHAIN:
		return (CELL)&stack_chain;
	default:
		critical_error("Bad rel type",rel->type);
		return -1; /* Can't happen */
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
	/* This is unaccurate but good enough */
	F_FIXNUM test = (F_FIXNUM)mask >> 1;
	if(value <= -test || value >= test)
		critical_error("Value does not fit inside relocation",0);

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
void relocate_code_block(F_COMPILED *compiled, CELL code_start, CELL literals_start)
{
	compiled->last_scan = NURSERY;

	if(compiled->relocation != F)
	{
		F_BYTE_ARRAY *relocation = untag_object(compiled->relocation);

		F_REL *rel = (F_REL *)(relocation + 1);
		F_REL *rel_end = (F_REL *)((char *)rel + byte_array_capacity(relocation));

		while(rel < rel_end)
		{
			CELL offset = rel->offset + code_start;

			F_FIXNUM absolute_value = compute_code_rel(
				rel,code_start,literals_start);

			apply_relocation(REL_CLASS(rel),offset,absolute_value);

			rel++;
		}
	}

	flush_icache(code_start,literals_start - code_start);
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

/* Write a sequence of integers to memory, with 'format' bytes per integer */
void deposit_integers(CELL here, F_ARRAY *array, CELL format)
{
	CELL count = array_capacity(array);
	CELL i;

	for(i = 0; i < count; i++)
	{
		F_FIXNUM value = to_fixnum(array_nth(array,i));
		if(format == 1)
			bput(here + i,value);
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

bool stack_traces_p(void)
{
	return to_boolean(userenv[STACK_TRACES_ENV]);
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
		gc();
		start = heap_allot(&code_heap,size);

		/* Insufficient room even after code GC, give up */
		if(start == 0)
		{
			CELL used, total_free, max_free;
			heap_usage(&code_heap,&used,&total_free,&max_free);

			print_string("Code heap stats:\n");
			print_string("Used: "); print_cell(used); nl();
			print_string("Total free space: "); print_cell(total_free); nl();
			print_string("Largest free block: "); print_cell(max_free); nl();
			fatal_error("Out of memory in add-compiled-block",0);
		}
	}

	return start;
}

/* Might GC */
F_COMPILED *add_compiled_block(
	CELL type,
	F_ARRAY *code,
	F_ARRAY *labels,
	CELL relocation,
	F_ARRAY *literals)
{
	CELL code_format = compiled_code_format();

	CELL code_length = align8(array_capacity(code) * code_format);
	CELL literals_length = array_capacity(literals) * CELLS;

	REGISTER_ROOT(relocation);
	REGISTER_UNTAGGED(code);
	REGISTER_UNTAGGED(labels);
	REGISTER_UNTAGGED(literals);

	CELL here = allot_code_block(sizeof(F_COMPILED) + code_length + literals_length);

	UNREGISTER_UNTAGGED(literals);
	UNREGISTER_UNTAGGED(labels);
	UNREGISTER_UNTAGGED(code);
	UNREGISTER_ROOT(relocation);

	/* compiled header */
	F_COMPILED *header = (void *)here;
	header->type = type;
	header->last_scan = NURSERY;
	header->code_length = code_length;
	header->literals_length = literals_length;
	header->relocation = relocation;

	here += sizeof(F_COMPILED);

	CELL code_start = here;

	/* code */
	deposit_integers(here,code,code_format);
	here += code_length;

	/* literals */
	deposit_objects(here,literals);
	here += literals_length;

	/* fixup labels */
	if(labels)
		fixup_labels(labels,code_format,code_start);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	last_code_heap_scan = NURSERY;

	return header;
}

void set_word_code(F_WORD *word, F_COMPILED *compiled)
{
	if(compiled->type != WORD_TYPE)
		critical_error("bad param to set_word_xt",(CELL)compiled);

	word->code = compiled;
	word->optimizedp = T;
}

/* Allocates memory */
void default_word_code(F_WORD *word, bool relocate)
{
	REGISTER_UNTAGGED(word);
	jit_compile(word->def,relocate);
	UNREGISTER_UNTAGGED(word);

	word->code = untag_quotation(word->def)->code;
	word->optimizedp = F;
}

void primitive_modify_code_heap(void)
{
	bool rescan_code_heap = to_boolean(dpop());
	F_ARRAY *alist = untag_array(dpop());

	CELL count = untag_fixnum_fast(alist->capacity);
	CELL i;
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(array_nth(alist,i));

		F_WORD *word = untag_word(array_nth(pair,0));

		CELL data = array_nth(pair,1);

		if(data == F)
		{
			REGISTER_UNTAGGED(alist);
			REGISTER_UNTAGGED(word);
			default_word_code(word,false);
			UNREGISTER_UNTAGGED(word);
			UNREGISTER_UNTAGGED(alist);
		}
		else
		{
			F_ARRAY *compiled_code = untag_array(data);

			F_ARRAY *literals = untag_array(array_nth(compiled_code,0));
			CELL relocation = array_nth(compiled_code,1);
			F_ARRAY *labels = untag_array(array_nth(compiled_code,2));
			F_ARRAY *code = untag_array(array_nth(compiled_code,3));

			REGISTER_UNTAGGED(alist);
			REGISTER_UNTAGGED(word);

			F_COMPILED *compiled = add_compiled_block(
				WORD_TYPE,
				code,
				labels,
				relocation,
				literals);

			UNREGISTER_UNTAGGED(word);
			UNREGISTER_UNTAGGED(alist);

			set_word_code(word,compiled);
		}

		REGISTER_UNTAGGED(alist);
		update_word_xt(word);
		UNREGISTER_UNTAGGED(alist);
	}

	/* If there were any interned words in the set, we relocate all XT
	references in the entire code heap. But if all the words are
	uninterned, it is impossible that other words reference them, so we
	only have to relocate the new words. This makes compile-call much
	more efficient */
	if(rescan_code_heap)
		iterate_code_heap(relocate_code_block);
	else
	{
		for(i = 0; i < count; i++)
		{
			F_ARRAY *pair = untag_array(array_nth(alist,i));
			F_WORD *word = untag_word(array_nth(pair,0));

			iterate_code_heap_step(word->code,relocate_code_block);
		}
	}
}
