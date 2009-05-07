#include "master.hpp"

namespace factor
{

void flush_icache_for(code_block *block)
{
	flush_icache((cell)block,block->size);
}

static int number_of_parameters(relocation_type type)
{
	switch(type)
	{
	case RT_PRIMITIVE:
	case RT_XT:
	case RT_XT_PIC:
	case RT_XT_PIC_TAIL:
	case RT_IMMEDIATE:
	case RT_HERE:
	case RT_UNTAGGED:
		return 1;
	case RT_DLSYM:
		return 2;
	case RT_THIS:
	case RT_STACK_CHAIN:
	case RT_MEGAMORPHIC_CACHE_HITS:
		return 0;
	default:
		critical_error("Bad rel type",type);
		return -1; /* Can't happen */
	}
}

void *object_xt(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case WORD_TYPE:
		return untag<word>(obj)->xt;
	case QUOTATION_TYPE:
		return untag<quotation>(obj)->xt;
	default:
		critical_error("Expected word or quotation",obj);
		return NULL;
	}
}

static void *xt_pic(word *w, cell tagged_quot)
{
	if(tagged_quot == F || max_pic_size == 0)
		return w->xt;
	else
	{
		quotation *quot = untag<quotation>(tagged_quot);
		if(quot->compiledp == F)
			return w->xt;
		else
			return quot->xt;
	}
}

void *word_xt_pic(word *w)
{
	return xt_pic(w,w->pic_def);
}

void *word_xt_pic_tail(word *w)
{
	return xt_pic(w,w->pic_tail_def);
}

/* References to undefined symbols are patched up to call this function on
image load */
void undefined_symbol()
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

/* Look up an external library symbol referenced by a compiled code block */
void *get_rel_symbol(array *literals, cell index)
{
	cell symbol = array_nth(literals,index);
	cell library = array_nth(literals,index + 1);

	dll *d = (library == F ? NULL : untag<dll>(library));

	if(d != NULL && !d->dll)
		return (void *)undefined_symbol;

	switch(tagged<object>(symbol).type())
	{
	case BYTE_ARRAY_TYPE:
		{
			symbol_char *name = alien_offset(symbol);
			void *sym = ffi_dlsym(d,name);

			if(sym)
				return sym;
			else
			{
				return (void *)undefined_symbol;
			}
		}
	case ARRAY_TYPE:
		{
			cell i;
			array *names = untag<array>(symbol);
			for(i = 0; i < array_capacity(names); i++)
			{
				symbol_char *name = alien_offset(array_nth(names,i));
				void *sym = ffi_dlsym(d,name);

				if(sym)
					return sym;
			}
			return (void *)undefined_symbol;
		}
	default:
		critical_error("Bad symbol specifier",symbol);
		return (void *)undefined_symbol;
	}
}

cell compute_relocation(relocation_entry rel, cell index, code_block *compiled)
{
	array *literals = untag<array>(compiled->literals);
	cell offset = REL_OFFSET(rel) + (cell)compiled->xt();

#define ARG array_nth(literals,index)

	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		return (cell)primitives[untag_fixnum(ARG)];
	case RT_DLSYM:
		return (cell)get_rel_symbol(literals,index);
	case RT_IMMEDIATE:
		return ARG;
	case RT_XT:
		return (cell)object_xt(ARG);
	case RT_XT_PIC:
		return (cell)word_xt_pic(untag<word>(ARG));
	case RT_XT_PIC_TAIL:
		return (cell)word_xt_pic_tail(untag<word>(ARG));
	case RT_HERE:
		return offset + (short)untag_fixnum(ARG);
	case RT_THIS:
		return (cell)(compiled + 1);
	case RT_STACK_CHAIN:
		return (cell)&stack_chain;
	case RT_UNTAGGED:
		return untag_fixnum(ARG);
	case RT_MEGAMORPHIC_CACHE_HITS:
		return (cell)&megamorphic_cache_hits;
	default:
		critical_error("Bad rel type",rel);
		return 0; /* Can't happen */
	}

#undef ARG
}

void iterate_relocations(code_block *compiled, relocation_iterator iter)
{
	if(compiled->relocation != F)
	{
		byte_array *relocation = untag<byte_array>(compiled->relocation);

		cell index = stack_traces_p() ? 1 : 0;

		cell length = array_capacity(relocation) / sizeof(relocation_entry);
		for(cell i = 0; i < length; i++)
		{
			relocation_entry rel = relocation->data<relocation_entry>()[i];
			iter(rel,index,compiled);
			index += number_of_parameters(REL_TYPE(rel));			
		}
	}
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
static void store_address_2_2(cell *ptr, cell value)
{
	ptr[-1] = ((ptr[-1] & ~0xffff) | ((value >> 16) & 0xffff));
	ptr[ 0] = ((ptr[ 0] & ~0xffff) | (value & 0xffff));
}

/* Store a value into a bitfield of a PowerPC instruction */
static void store_address_masked(cell *ptr, fixnum value, cell mask, fixnum shift)
{
	/* This is unaccurate but good enough */
	fixnum test = (fixnum)mask >> 1;
	if(value <= -test || value >= test)
		critical_error("Value does not fit inside relocation",0);

	*ptr = ((*ptr & ~mask) | ((value >> shift) & mask));
}

/* Perform a fixup on a code block */
void store_address_in_code_block(cell klass, cell offset, fixnum absolute_value)
{
	fixnum relative_value = absolute_value - offset;

	switch(klass)
	{
	case RC_ABSOLUTE_CELL:
		*(cell *)offset = absolute_value;
		break;
	case RC_ABSOLUTE:
		*(u32*)offset = absolute_value;
		break;
	case RC_RELATIVE:
		*(u32*)offset = relative_value - sizeof(u32);
		break;
	case RC_ABSOLUTE_PPC_2_2:
		store_address_2_2((cell *)offset,absolute_value);
		break;
	case RC_ABSOLUTE_PPC_2:
		store_address_masked((cell *)offset,absolute_value,REL_ABSOLUTE_PPC_2_MASK,0);
		break;
	case RC_RELATIVE_PPC_2:
		store_address_masked((cell *)offset,relative_value,REL_RELATIVE_PPC_2_MASK,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_address_masked((cell *)offset,relative_value,REL_RELATIVE_PPC_3_MASK,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			REL_RELATIVE_ARM_3_MASK,2);
		break;
	case RC_INDIRECT_ARM:
		store_address_masked((cell *)offset,relative_value - sizeof(cell),
			REL_INDIRECT_ARM_MASK,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			REL_INDIRECT_ARM_MASK,0);
		break;
	default:
		critical_error("Bad rel class",klass);
		break;
	}
}

void update_literal_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	if(REL_TYPE(rel) == RT_IMMEDIATE)
	{
		cell offset = REL_OFFSET(rel) + (cell)(compiled + 1);
		array *literals = untag<array>(compiled->literals);
		fixnum absolute_value = array_nth(literals,index);
		store_address_in_code_block(REL_CLASS(rel),offset,absolute_value);
	}
}

/* Update pointers to literals from compiled code. */
void update_literal_references(code_block *compiled)
{
	if(!compiled->needs_fixup)
	{
		iterate_relocations(compiled,update_literal_references_step);
		flush_icache_for(compiled);
	}
}

/* Copy all literals referenced from a code block to newspace. Only for
aging and nursery collections */
void copy_literal_references(code_block *compiled)
{
	if(collecting_gen >= compiled->last_scan)
	{
		if(collecting_accumulation_gen_p())
			compiled->last_scan = collecting_gen;
		else
			compiled->last_scan = collecting_gen + 1;

		/* initialize chase pointer */
		cell scan = newspace->here;

		copy_handle(&compiled->literals);
		copy_handle(&compiled->relocation);

		/* do some tracing so that all reachable literals are now
		at their final address */
		copy_reachable_objects(scan,&newspace->here);

		update_literal_references(compiled);
	}
}

/* Compute an address to store at a relocation */
void relocate_code_block_step(relocation_entry rel, cell index, code_block *compiled)
{
#ifdef FACTOR_DEBUG
	tagged<array>(compiled->literals).untag_check();
	tagged<byte_array>(compiled->relocation).untag_check();
#endif

	store_address_in_code_block(REL_CLASS(rel),
				    REL_OFFSET(rel) + (cell)compiled->xt(),
				    compute_relocation(rel,index,compiled));
}

void update_word_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	relocation_type type = REL_TYPE(rel);
	if(type == RT_XT || type == RT_XT_PIC || type == RT_XT_PIC_TAIL)
		relocate_code_block_step(rel,index,compiled);
}

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void update_word_references(code_block *compiled)
{
	if(compiled->needs_fixup)
		relocate_code_block(compiled);
	/* update_word_references() is always applied to every block in
	   the code heap. Since it resets all call sites to point to
	   their canonical XT (cold entry point for non-tail calls,
	   standard entry point for tail calls), it means that no PICs
	   are referenced after this is done. So instead of polluting
	   the code heap with dead PICs that will be freed on the next
	   GC, we add them to the free list immediately. */
	else if(compiled->type == PIC_TYPE)
		heap_free(&code,compiled);
	else
	{
		iterate_relocations(compiled,update_word_references_step);
		flush_icache_for(compiled);
	}
}

void update_literal_and_word_references(code_block *compiled)
{
	update_literal_references(compiled);
	update_word_references(compiled);
}

static void check_code_address(cell address)
{
#ifdef FACTOR_DEBUG
	assert(address >= code.seg->start && address < code.seg->end);
#endif
}

/* Update references to words. This is done after a new code block
is added to the heap. */

/* Mark all literals referenced from a word XT. Only for tenured
collections */
void mark_code_block(code_block *compiled)
{
	check_code_address((cell)compiled);

	mark_block(compiled);

	copy_handle(&compiled->literals);
	copy_handle(&compiled->relocation);
}

void mark_stack_frame_step(stack_frame *frame)
{
	mark_code_block(frame_code(frame));
}

/* Mark code blocks executing in currently active stack frames. */
void mark_active_blocks(context *stacks)
{
	if(collecting_gen == TENURED)
	{
		cell top = (cell)stacks->callstack_top;
		cell bottom = (cell)stacks->callstack_bottom;

		iterate_callstack(top,bottom,mark_stack_frame_step);
	}
}

void mark_object_code_block(object *object)
{
	switch(object->h.hi_tag())
	{
	case WORD_TYPE:
		{
			word *w = (word *)object;
			if(w->code)
				mark_code_block(w->code);
			if(w->profiling)
				mark_code_block(w->profiling);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)object;
			if(q->compiledp != F)
				mark_code_block(q->code);
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)object;
			iterate_callstack_object(stack,mark_stack_frame_step);
			break;
		}
	}
}

/* Perform all fixups on a code block */
void relocate_code_block(code_block *compiled)
{
	compiled->last_scan = NURSERY;
	compiled->needs_fixup = false;
	iterate_relocations(compiled,relocate_code_block_step);
	flush_icache_for(compiled);
}

/* Fixup labels. This is done at compile time, not image load time */
void fixup_labels(array *labels, code_block *compiled)
{
	cell i;
	cell size = array_capacity(labels);

	for(i = 0; i < size; i += 3)
	{
		cell klass = untag_fixnum(array_nth(labels,i));
		cell offset = untag_fixnum(array_nth(labels,i + 1));
		cell target = untag_fixnum(array_nth(labels,i + 2));

		store_address_in_code_block(klass,
			offset + (cell)(compiled + 1),
			target + (cell)(compiled + 1));
	}
}

/* Might GC */
code_block *allot_code_block(cell size)
{
	heap_block *block = heap_allot(&code,size + sizeof(code_block));

	/* If allocation failed, do a code GC */
	if(block == NULL)
	{
		gc();
		block = heap_allot(&code,size + sizeof(code_block));

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
		{
			cell used, total_free, max_free;
			heap_usage(&code,&used,&total_free,&max_free);

			print_string("Code heap stats:\n");
			print_string("Used: "); print_cell(used); nl();
			print_string("Total free space: "); print_cell(total_free); nl();
			print_string("Largest free block: "); print_cell(max_free); nl();
			fatal_error("Out of memory in add-compiled-block",0);
		}
	}

	return (code_block *)block;
}

/* Might GC */
code_block *add_code_block(
	cell type,
	cell code_,
	cell labels_,
	cell relocation_,
	cell literals_)
{
	gc_root<byte_array> code(code_);
	gc_root<object> labels(labels_);
	gc_root<byte_array> relocation(relocation_);
	gc_root<array> literals(literals_);

	cell code_length = align8(array_capacity(code.untagged()));
	code_block *compiled = allot_code_block(code_length);

	/* compiled header */
	compiled->type = type;
	compiled->last_scan = NURSERY;
	compiled->needs_fixup = true;
	compiled->relocation = relocation.value();

	/* slight space optimization */
	if(literals.type() == ARRAY_TYPE && array_capacity(literals.untagged()) == 0)
		compiled->literals = F;
	else
		compiled->literals = literals.value();

	/* code */
	memcpy(compiled + 1,code.untagged() + 1,code_length);

	/* fixup labels */
	if(labels.value() != F)
		fixup_labels(labels.as<array>().untagged(),compiled);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	last_code_heap_scan = NURSERY;

	return compiled;
}

}
