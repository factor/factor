#include "master.h"

void flush_icache_for(F_CODE_BLOCK *block)
{
	flush_icache((CELL)block,block->block.size);
}

void iterate_relocations(F_CODE_BLOCK *compiled, RELOCATION_ITERATOR iter)
{
	if(compiled->relocation != F)
	{
		F_BYTE_ARRAY *relocation = untag_object(compiled->relocation);

		CELL index = stack_traces_p() ? 1 : 0;

		F_REL *rel = (F_REL *)(relocation + 1);
		F_REL *rel_end = (F_REL *)((char *)rel + byte_array_capacity(relocation));

		while(rel < rel_end)
		{
			iter(*rel,index,compiled);

			switch(REL_TYPE(*rel))
			{
			case RT_PRIMITIVE:
			case RT_XT:
			case RT_IMMEDIATE:
			case RT_HERE:
				index++;
				break;
			case RT_DLSYM:
				index += 2;
				break;
			case RT_THIS:
			case RT_STACK_CHAIN:
				break;
			default:
				critical_error("Bad rel type",*rel);
				return; /* Can't happen */
			}

			rel++;
		}
	}
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
INLINE void store_address_2_2(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}

/* Store a value into a bitfield of a PowerPC instruction */
INLINE void store_address_masked(CELL cell, F_FIXNUM value, CELL mask, F_FIXNUM shift)
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
void store_address_in_code_block(CELL class, CELL offset, F_FIXNUM absolute_value)
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
		store_address_2_2(offset,absolute_value);
		break;
	case RC_RELATIVE_PPC_2:
		store_address_masked(offset,relative_value,REL_RELATIVE_PPC_2_MASK,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_address_masked(offset,relative_value,REL_RELATIVE_PPC_3_MASK,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_address_masked(offset,relative_value - CELLS * 2,
			REL_RELATIVE_ARM_3_MASK,2);
		break;
	case RC_INDIRECT_ARM:
		store_address_masked(offset,relative_value - CELLS,
			REL_INDIRECT_ARM_MASK,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_address_masked(offset,relative_value - CELLS * 2,
			REL_INDIRECT_ARM_MASK,0);
		break;
	default:
		critical_error("Bad rel class",class);
		break;
	}
}

void update_literal_references_step(F_REL rel, CELL index, F_CODE_BLOCK *compiled)
{
	if(REL_TYPE(rel) == RT_IMMEDIATE)
	{
		CELL offset = REL_OFFSET(rel) + (CELL)(compiled + 1);
		F_ARRAY *literals = untag_object(compiled->literals);
		F_FIXNUM absolute_value = array_nth(literals,index);
		store_address_in_code_block(REL_CLASS(rel),offset,absolute_value);
	}
}

/* Update pointers to literals from compiled code. */
void update_literal_references(F_CODE_BLOCK *compiled)
{
	iterate_relocations(compiled,update_literal_references_step);
	flush_icache_for(compiled);
}

/* Copy all literals referenced from a code block to newspace. Only for
aging and nursery collections */
void copy_literal_references(F_CODE_BLOCK *compiled)
{
	if(collecting_gen >= compiled->block.last_scan)
	{
		if(collecting_accumulation_gen_p())
			compiled->block.last_scan = collecting_gen;
		else
			compiled->block.last_scan = collecting_gen + 1;

		/* initialize chase pointer */
		CELL scan = newspace->here;

		copy_handle(&compiled->literals);
		copy_handle(&compiled->relocation);

		/* do some tracing so that all reachable literals are now
		at their final address */
		copy_reachable_objects(scan,&newspace->here);

		update_literal_references(compiled);
	}
}

CELL object_xt(CELL obj)
{
	if(type_of(obj) == WORD_TYPE)
		return (CELL)untag_word(obj)->xt;
	else
		return (CELL)untag_quotation(obj)->xt;
}

void update_word_references_step(F_REL rel, CELL index, F_CODE_BLOCK *compiled)
{
	if(REL_TYPE(rel) == RT_XT)
	{
		CELL offset = REL_OFFSET(rel) + (CELL)(compiled + 1);
		F_ARRAY *literals = untag_object(compiled->literals);
		CELL xt = object_xt(array_nth(literals,index));
		store_address_in_code_block(REL_CLASS(rel),offset,xt);
	}
}

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void update_word_references(F_CODE_BLOCK *compiled)
{
	if(compiled->block.needs_fixup)
		relocate_code_block(compiled);
	else
	{
		iterate_relocations(compiled,update_word_references_step);
		flush_icache_for(compiled);
	}
}

/* Update references to words. This is done after a new code block
is added to the heap. */

/* Mark all literals referenced from a word XT. Only for tenured
collections */
void mark_code_block(F_CODE_BLOCK *compiled)
{
	mark_block(&compiled->block);

	copy_handle(&compiled->literals);
	copy_handle(&compiled->relocation);
}

void mark_stack_frame_step(F_STACK_FRAME *frame)
{
	mark_code_block(frame_code(frame));
}

/* Mark code blocks executing in currently active stack frames. */
void mark_active_blocks(F_CONTEXT *stacks)
{
	if(collecting_gen == TENURED)
	{
		CELL top = (CELL)stacks->callstack_top;
		CELL bottom = (CELL)stacks->callstack_bottom;

		iterate_callstack(top,bottom,mark_stack_frame_step);
	}
}

void mark_object_code_block(CELL scan)
{
	F_WORD *word;
	F_QUOTATION *quot;
	F_CALLSTACK *stack;

	switch(object_type(scan))
	{
	case WORD_TYPE:
		word = (F_WORD *)scan;
		if(word->code)
		  mark_code_block(word->code);
		if(word->profiling)
			mark_code_block(word->profiling);
		break;
	case QUOTATION_TYPE:
		quot = (F_QUOTATION *)scan;
		if(quot->compiledp != F)
			mark_code_block(quot->code);
		break;
	case CALLSTACK_TYPE:
		stack = (F_CALLSTACK *)scan;
		iterate_callstack_object(stack,mark_stack_frame_step);
		break;
	}
}

/* References to undefined symbols are patched up to call this function on
image load */
void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

/* Look up an external library symbol referenced by a compiled code block */
void *get_rel_symbol(F_ARRAY *literals, CELL index)
{
	CELL symbol = array_nth(literals,index);
	CELL library = array_nth(literals,index + 1);

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
void relocate_code_block_step(F_REL rel, CELL index, F_CODE_BLOCK *compiled)
{
	CELL offset = REL_OFFSET(rel) + (CELL)(compiled + 1);
	F_ARRAY *literals = untag_object(compiled->literals);
	F_FIXNUM absolute_value;

	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		absolute_value = (CELL)primitives[to_fixnum(array_nth(literals,index))];
		break;
	case RT_DLSYM:
		absolute_value = (CELL)get_rel_symbol(literals,index);
		break;
	case RT_IMMEDIATE:
		absolute_value = array_nth(literals,index);
		break;
	case RT_XT:
		absolute_value = object_xt(array_nth(literals,index));
		break;
	case RT_HERE:
		absolute_value = offset + (short)to_fixnum(array_nth(literals,index));
		break;
	case RT_THIS:
		absolute_value = (CELL)(compiled + 1);
		break;
	case RT_STACK_CHAIN:
		absolute_value = (CELL)&stack_chain;
		break;
	default:
		critical_error("Bad rel type",rel);
		return; /* Can't happen */
	}

	store_address_in_code_block(REL_CLASS(rel),offset,absolute_value);
}

/* Perform all fixups on a code block */
void relocate_code_block(F_CODE_BLOCK *compiled)
{
	compiled->block.last_scan = NURSERY;
	compiled->block.needs_fixup = false;
	iterate_relocations(compiled,relocate_code_block_step);
	flush_icache_for(compiled);
}

/* Fixup labels. This is done at compile time, not image load time */
void fixup_labels(F_ARRAY *labels, CELL code_format, F_CODE_BLOCK *compiled)
{
	CELL i;
	CELL size = array_capacity(labels);

	for(i = 0; i < size; i += 3)
	{
		CELL class = to_fixnum(array_nth(labels,i));
		CELL offset = to_fixnum(array_nth(labels,i + 1));
		CELL target = to_fixnum(array_nth(labels,i + 2));

		store_address_in_code_block(class,
			offset + (CELL)(compiled + 1),
			target + (CELL)(compiled + 1));
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
		else if(format == sizeof(CELL))
			*(CELL *)(here + format * i) = value;
		else
			critical_error("Bad format in deposit_integers()",format);
	}
}

CELL compiled_code_format(void)
{
	return untag_fixnum_fast(userenv[JIT_CODE_FORMAT]);
}

/* Might GC */
F_CODE_BLOCK *allot_code_block(CELL size)
{
	F_BLOCK *block = heap_allot(&code_heap,size + sizeof(F_CODE_BLOCK));

	/* If allocation failed, do a code GC */
	if(block == NULL)
	{
		gc();
		block = heap_allot(&code_heap,size + sizeof(F_CODE_BLOCK));

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
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

	return (F_CODE_BLOCK *)block;
}

/* Might GC */
F_CODE_BLOCK *add_code_block(
	CELL type,
	F_ARRAY *code,
	F_ARRAY *labels,
	CELL relocation,
	CELL literals)
{
	CELL code_format = compiled_code_format();
	CELL code_length = align8(array_capacity(code) * code_format);

	REGISTER_ROOT(literals);
	REGISTER_ROOT(relocation);
	REGISTER_UNTAGGED(code);
	REGISTER_UNTAGGED(labels);

	F_CODE_BLOCK *compiled = allot_code_block(code_length);

	UNREGISTER_UNTAGGED(labels);
	UNREGISTER_UNTAGGED(code);
	UNREGISTER_ROOT(relocation);
	UNREGISTER_ROOT(literals);

	/* slight space optimization */
	if(type_of(literals) == ARRAY_TYPE && array_capacity(untag_object(literals)) == 0)
		literals = F;

	/* compiled header */
	compiled->block.type = type;
	compiled->block.last_scan = NURSERY;
	compiled->block.needs_fixup = true;
	compiled->literals = literals;
	compiled->relocation = relocation;

	/* code */
	deposit_integers((CELL)(compiled + 1),code,code_format);

	/* fixup labels */
	if(labels) fixup_labels(labels,code_format,compiled);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	last_code_heap_scan = NURSERY;

	return compiled;
}
