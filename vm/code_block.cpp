#include "master.hpp"

namespace factor
{

relocation_type factor_vm::relocation_type_of(relocation_entry r)
{
	return (relocation_type)((r & 0xf0000000) >> 28);
}

relocation_class factor_vm::relocation_class_of(relocation_entry r)
{
	return (relocation_class)((r & 0x0f000000) >> 24);
}

cell factor_vm::relocation_offset_of(relocation_entry r)
{
	return (r & 0x00ffffff);
}

void factor_vm::flush_icache_for(code_block *block)
{
	flush_icache((cell)block,block->size());
}

int factor_vm::number_of_parameters(relocation_type type)
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
	case RT_VM:
		return 1;
	case RT_DLSYM:
		return 2;
	case RT_THIS:
	case RT_CONTEXT:
	case RT_MEGAMORPHIC_CACHE_HITS:
	case RT_CARDS_OFFSET:
	case RT_DECKS_OFFSET:
		return 0;
	default:
		critical_error("Bad rel type",type);
		return -1; /* Can't happen */
	}
}

void *factor_vm::object_xt(cell obj)
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

void *factor_vm::xt_pic(word *w, cell tagged_quot)
{
	if(tagged_quot == F || max_pic_size == 0)
		return w->xt;
	else
	{
		quotation *quot = untag<quotation>(tagged_quot);
		if(quot->code)
			return quot->xt;
		else
			return w->xt;
	}
}

void *factor_vm::word_xt_pic(word *w)
{
	return xt_pic(w,w->pic_def);
}

void *factor_vm::word_xt_pic_tail(word *w)
{
	return xt_pic(w,w->pic_tail_def);
}

/* References to undefined symbols are patched up to call this function on
image load */
void factor_vm::undefined_symbol()
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

void undefined_symbol()
{
	return tls_vm()->undefined_symbol();
}

/* Look up an external library symbol referenced by a compiled code block */
void *factor_vm::get_rel_symbol(array *literals, cell index)
{
	cell symbol = array_nth(literals,index);
	cell library = array_nth(literals,index + 1);

	dll *d = (library == F ? NULL : untag<dll>(library));

	if(d != NULL && !d->dll)
		return (void *)factor::undefined_symbol;

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
				return (void *)factor::undefined_symbol;
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
			return (void *)factor::undefined_symbol;
		}
	default:
		critical_error("Bad symbol specifier",symbol);
		return (void *)factor::undefined_symbol;
	}
}

cell factor_vm::compute_relocation(relocation_entry rel, cell index, code_block *compiled)
{
	array *literals = (compiled->literals == F
		? NULL : untag<array>(compiled->literals));
	cell offset = relocation_offset_of(rel) + (cell)compiled->xt();

#define ARG array_nth(literals,index)

	switch(relocation_type_of(rel))
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
	{
		fixnum arg = untag_fixnum(ARG);
		return (arg >= 0 ? offset + arg : (cell)(compiled + 1) - arg);
	}
	case RT_THIS:
		return (cell)(compiled + 1);
	case RT_CONTEXT:
		return (cell)&ctx;
	case RT_UNTAGGED:
		return untag_fixnum(ARG);
	case RT_MEGAMORPHIC_CACHE_HITS:
		return (cell)&megamorphic_cache_hits;
	case RT_VM:
		return (cell)this + untag_fixnum(ARG);
	case RT_CARDS_OFFSET:
		return cards_offset;
	case RT_DECKS_OFFSET:
		return decks_offset;
	default:
		critical_error("Bad rel type",rel);
		return 0; /* Can't happen */
	}

#undef ARG
}

template<typename Iterator> void factor_vm::iterate_relocations(code_block *compiled, Iterator &iter)
{
	if(compiled->relocation != F)
	{
		byte_array *relocation = untag<byte_array>(compiled->relocation);

		cell index = 0;
		cell length = array_capacity(relocation) / sizeof(relocation_entry);

		for(cell i = 0; i < length; i++)
		{
			relocation_entry rel = relocation->data<relocation_entry>()[i];
			iter(rel,index,compiled);
			index += number_of_parameters(relocation_type_of(rel));			
		}
	}
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
void factor_vm::store_address_2_2(cell *ptr, cell value)
{
	ptr[-1] = ((ptr[-1] & ~0xffff) | ((value >> 16) & 0xffff));
	ptr[ 0] = ((ptr[ 0] & ~0xffff) | (value & 0xffff));
}

/* Store a value into a bitfield of a PowerPC instruction */
void factor_vm::store_address_masked(cell *ptr, fixnum value, cell mask, fixnum shift)
{
	/* This is unaccurate but good enough */
	fixnum test = (fixnum)mask >> 1;
	if(value <= -test || value >= test)
		critical_error("Value does not fit inside relocation",0);

	*ptr = ((*ptr & ~mask) | ((value >> shift) & mask));
}

/* Perform a fixup on a code block */
void factor_vm::store_address_in_code_block(cell klass, cell offset, fixnum absolute_value)
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
		store_address_masked((cell *)offset,absolute_value,rel_absolute_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_2:
		store_address_masked((cell *)offset,relative_value,rel_relative_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_address_masked((cell *)offset,relative_value,rel_relative_ppc_3_mask,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			rel_relative_arm_3_mask,2);
		break;
	case RC_INDIRECT_ARM:
		store_address_masked((cell *)offset,relative_value - sizeof(cell),
			rel_indirect_arm_mask,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			rel_indirect_arm_mask,0);
		break;
	default:
		critical_error("Bad rel class",klass);
		break;
	}
}

struct literal_references_updater {
	factor_vm *myvm;

	explicit literal_references_updater(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		if(myvm->relocation_type_of(rel) == RT_IMMEDIATE)
		{
			cell offset = myvm->relocation_offset_of(rel) + (cell)(compiled + 1);
			array *literals = myvm->untag<array>(compiled->literals);
			fixnum absolute_value = array_nth(literals,index);
			myvm->store_address_in_code_block(myvm->relocation_class_of(rel),offset,absolute_value);
		}
	}
};

/* Update pointers to literals from compiled code. */
void factor_vm::update_literal_references(code_block *compiled)
{
	if(!code->needs_fixup_p(compiled))
	{
		literal_references_updater updater(this);
		iterate_relocations(compiled,updater);
		flush_icache_for(compiled);
	}
}

/* Compute an address to store at a relocation */
void factor_vm::relocate_code_block_step(relocation_entry rel, cell index, code_block *compiled)
{
#ifdef FACTOR_DEBUG
	if(compiled->literals != F)
		tagged<array>(compiled->literals).untag_check(this);
	if(compiled->relocation != F)
		tagged<byte_array>(compiled->relocation).untag_check(this);
#endif

	store_address_in_code_block(relocation_class_of(rel),
		relocation_offset_of(rel) + (cell)compiled->xt(),
		compute_relocation(rel,index,compiled));
}

struct word_references_updater {
	factor_vm *myvm;

	explicit word_references_updater(factor_vm *myvm_) : myvm(myvm_) {}
	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		relocation_type type = myvm->relocation_type_of(rel);
		if(type == RT_XT || type == RT_XT_PIC || type == RT_XT_PIC_TAIL)
			myvm->relocate_code_block_step(rel,index,compiled);
	}
};

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void factor_vm::update_word_references(code_block *compiled)
{
	if(code->needs_fixup_p(compiled))
		relocate_code_block(compiled);
	/* update_word_references() is always applied to every block in
	   the code heap. Since it resets all call sites to point to
	   their canonical XT (cold entry point for non-tail calls,
	   standard entry point for tail calls), it means that no PICs
	   are referenced after this is done. So instead of polluting
	   the code heap with dead PICs that will be freed on the next
	   GC, we add them to the free list immediately. */
	else if(compiled->type() == PIC_TYPE)
		code->code_heap_free(compiled);
	else
	{
		word_references_updater updater(this);
		iterate_relocations(compiled,updater);
		flush_icache_for(compiled);
	}
}

/* This runs after a full collection */
struct literal_and_word_references_updater {
	factor_vm *myvm;

	explicit literal_and_word_references_updater(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		relocation_type type = myvm->relocation_type_of(rel);
		switch(type)
		{
		case RT_IMMEDIATE:
		case RT_XT:
		case RT_XT_PIC:
		case RT_XT_PIC_TAIL:
			myvm->relocate_code_block_step(rel,index,compiled);
			break;
		default:
			break;
		}
	}
};

void factor_vm::update_code_block_for_full_gc(code_block *compiled)
{
	if(code->needs_fixup_p(compiled))
		relocate_code_block(compiled);
	else
	{
		literal_and_word_references_updater updater(this);
		iterate_relocations(compiled,updater);
		flush_icache_for(compiled);
	}
}

void factor_vm::check_code_address(cell address)
{
#ifdef FACTOR_DEBUG
	assert(address >= code->seg->start && address < code->seg->end);
#endif
}

struct code_block_relocator {
	factor_vm *myvm;

	explicit code_block_relocator(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		myvm->relocate_code_block_step(rel,index,compiled);
	}
};

/* Perform all fixups on a code block */
void factor_vm::relocate_code_block(code_block *compiled)
{
	code->needs_fixup.erase(compiled);
	code_block_relocator relocator(this);
	iterate_relocations(compiled,relocator);
	flush_icache_for(compiled);
}

/* Fixup labels. This is done at compile time, not image load time */
void factor_vm::fixup_labels(array *labels, code_block *compiled)
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
code_block *factor_vm::allot_code_block(cell size, cell type)
{
	heap_block *block = code->heap_allot(size + sizeof(code_block),type);

	/* If allocation failed, do a full GC and compact the code heap.
	A full GC that occurs as a result of the data heap filling up does not
	trigger a compaction. This setup ensures that most GCs do not compact
	the code heap, but if the code fills up, it probably means it will be
	fragmented after GC anyway, so its best to compact. */
	if(block == NULL)
	{
		primitive_compact_gc();
		block = code->heap_allot(size + sizeof(code_block),type);

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
		{
			cell used, total_free, max_free;
			code->heap_usage(&used,&total_free,&max_free);

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
code_block *factor_vm::add_code_block(cell type, cell code_, cell labels_, cell owner_, cell relocation_, cell literals_)
{
	gc_root<byte_array> code(code_,this);
	gc_root<object> labels(labels_,this);
	gc_root<object> owner(owner_,this);
	gc_root<byte_array> relocation(relocation_,this);
	gc_root<array> literals(literals_,this);

	cell code_length = align8(array_capacity(code.untagged()));
	code_block *compiled = allot_code_block(code_length,type);

	compiled->owner = owner.value();

	/* slight space optimization */
	if(relocation.type() == BYTE_ARRAY_TYPE && array_capacity(relocation.untagged()) == 0)
		compiled->relocation = F;
	else
		compiled->relocation = relocation.value();

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
	this->code->write_barrier(compiled);
	this->code->needs_fixup.insert(compiled);

	return compiled;
}

}
