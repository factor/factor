#include "master.hpp"

namespace factor
{

cell factor_vm::compute_entry_point_address(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case WORD_TYPE:
		return (cell)untag<word>(obj)->entry_point;
	case QUOTATION_TYPE:
		return (cell)untag<quotation>(obj)->entry_point;
	default:
		critical_error("Expected word or quotation",obj);
		return 0;
	}
}

cell factor_vm::compute_entry_point_pic_address(word *w, cell tagged_quot)
{
	if(!to_boolean(tagged_quot) || max_pic_size == 0)
		return (cell)w->entry_point;
	else
	{
		quotation *quot = untag<quotation>(tagged_quot);
		if(quot_compiled_p(quot))
			return (cell)quot->entry_point;
		else
			return (cell)w->entry_point;
	}
}

cell factor_vm::compute_entry_point_pic_address(cell w_)
{
	tagged<word> w(w_);
	return compute_entry_point_pic_address(w.untagged(),w->pic_def);
}

cell factor_vm::compute_entry_point_pic_tail_address(cell w_)
{
	tagged<word> w(w_);
	return compute_entry_point_pic_address(w.untagged(),w->pic_tail_def);
}

cell factor_vm::code_block_owner(code_block *compiled)
{
	tagged<object> owner(compiled->owner);

	/* Cold generic word call sites point to quotations that call the
	inline-cache-miss and inline-cache-miss-tail primitives. */
	if(owner.type_p(QUOTATION_TYPE))
	{
		tagged<quotation> quot(owner.as<quotation>());
		tagged<array> elements(quot->array);
#ifdef FACTOR_DEBUG
		assert(array_capacity(elements.untagged()) == 5);
		assert(array_nth(elements.untagged(),4) == special_objects[PIC_MISS_WORD]
			|| array_nth(elements.untagged(),4) == special_objects[PIC_MISS_TAIL_WORD]);
#endif
		tagged<wrapper> word_wrapper(array_nth(elements.untagged(),0));
		return word_wrapper->object;
	}
	else
		return compiled->owner;
}

struct update_word_references_relocation_visitor {
	factor_vm *parent;
	bool reset_inline_caches;

	update_word_references_relocation_visitor(
		factor_vm *parent_,
		bool reset_inline_caches_) :
		parent(parent_),
		reset_inline_caches(reset_inline_caches_) {}

	void operator()(instruction_operand op)
	{
		switch(op.rel_type())
		{
		case RT_ENTRY_POINT:
			{
				code_block *compiled = op.load_code_block();
				cell owner = compiled->owner;
				if(to_boolean(owner))
					op.store_value(parent->compute_entry_point_address(owner));
				break;
			}
		case RT_ENTRY_POINT_PIC:
			{
				code_block *compiled = op.load_code_block();
				if(reset_inline_caches || !compiled->pic_p())
				{
					cell owner = parent->code_block_owner(compiled);
					if(to_boolean(owner))
						op.store_value(parent->compute_entry_point_pic_address(owner));
				}
				break;
			}
		case RT_ENTRY_POINT_PIC_TAIL:
			{
				code_block *compiled = op.load_code_block();
				if(reset_inline_caches || !compiled->pic_p())
				{
					cell owner = parent->code_block_owner(compiled);
					if(to_boolean(owner))
						op.store_value(parent->compute_entry_point_pic_tail_address(owner));
				}
				break;
			}
		default:
			break;
		}
	}
};

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void factor_vm::update_word_references(code_block *compiled, bool reset_inline_caches)
{
	if(code->uninitialized_p(compiled))
		initialize_code_block(compiled);
	/* update_word_references() is always applied to every block in
	   the code heap. Since it resets all call sites to point to
	   their canonical entry point (cold entry point for non-tail calls,
	   standard entry point for tail calls), it means that no PICs
	   are referenced after this is done. So instead of polluting
	   the code heap with dead PICs that will be freed on the next
	   GC, we add them to the free list immediately. */
	else if(reset_inline_caches && compiled->pic_p())
		code->free(compiled);
	else
	{
		update_word_references_relocation_visitor visitor(this,reset_inline_caches);
		compiled->each_instruction_operand(visitor);
		compiled->flush_icache();
	}
}

/* References to undefined symbols are patched up to call this function on
image load */
void factor_vm::undefined_symbol()
{
	general_error(ERROR_UNDEFINED_SYMBOL,false_object,false_object);
}

void undefined_symbol()
{
	return current_vm()->undefined_symbol();
}

/* Look up an external library symbol referenced by a compiled code block */
cell factor_vm::compute_dlsym_address(array *literals, cell index)
{
	cell symbol = array_nth(literals,index);
	cell library = array_nth(literals,index + 1);

	dll *d = (to_boolean(library) ? untag<dll>(library) : NULL);

	if(d != NULL && !d->handle)
		return (cell)factor::undefined_symbol;

	switch(tagged<object>(symbol).type())
	{
	case BYTE_ARRAY_TYPE:
		{
			symbol_char *name = alien_offset(symbol);
			void *sym = ffi_dlsym(d,name);

			if(sym)
				return (cell)sym;
			else
				return (cell)factor::undefined_symbol;
		}
	case ARRAY_TYPE:
		{
			array *names = untag<array>(symbol);
			for(cell i = 0; i < array_capacity(names); i++)
			{
				symbol_char *name = alien_offset(array_nth(names,i));
				void *sym = ffi_dlsym(d,name);

				if(sym)
					return (cell)sym;
			}
			return (cell)factor::undefined_symbol;
		}
	default:
		critical_error("Bad symbol specifier",symbol);
		return (cell)factor::undefined_symbol;
	}
}

cell factor_vm::compute_vm_address(cell arg)
{
	return (cell)this + untag_fixnum(arg);
}

void factor_vm::store_external_address(instruction_operand op)
{
	code_block *compiled = op.parent_code_block();
	array *parameters = (to_boolean(compiled->parameters) ? untag<array>(compiled->parameters) : NULL);
	cell index = op.parameter_index();

	switch(op.rel_type())
	{
	case RT_DLSYM:
		op.store_value(compute_dlsym_address(parameters,index));
		break;
	case RT_THIS:
		op.store_value((cell)compiled->entry_point());
		break;
	case RT_MEGAMORPHIC_CACHE_HITS:
		op.store_value((cell)&dispatch_stats.megamorphic_cache_hits);
		break;
	case RT_VM:
		op.store_value(compute_vm_address(array_nth(parameters,index)));
		break;
	case RT_CARDS_OFFSET:
		op.store_value(cards_offset);
		break;
	case RT_DECKS_OFFSET:
		op.store_value(decks_offset);
		break;
#ifdef WINDOWS
	case RT_EXCEPTION_HANDLER:
		op.store_value((cell)&factor::exception_handler);
		break;
#endif
	default:
		critical_error("Bad rel type",op.rel_type());
		break;
	}
}

cell factor_vm::compute_here_address(cell arg, cell offset, code_block *compiled)
{
	fixnum n = untag_fixnum(arg);
	if(n >= 0)
		return (cell)compiled->entry_point() + offset + n;
	else
		return (cell)compiled->entry_point() - n;
}

struct initial_code_block_visitor {
	factor_vm *parent;
	cell literals;
	cell literal_index;

	explicit initial_code_block_visitor(factor_vm *parent_, cell literals_)
		: parent(parent_), literals(literals_), literal_index(0) {}

	cell next_literal()
	{
		return array_nth(untag<array>(literals),literal_index++);
	}

	void operator()(instruction_operand op)
	{
		switch(op.rel_type())
		{
		case RT_LITERAL:
			op.store_value(next_literal());
			break;
		case RT_FLOAT:
			op.store_float(next_literal());
			break;
		case RT_ENTRY_POINT:
			op.store_value(parent->compute_entry_point_address(next_literal()));
			break;
		case RT_ENTRY_POINT_PIC:
			op.store_value(parent->compute_entry_point_pic_address(next_literal()));
			break;
		case RT_ENTRY_POINT_PIC_TAIL:
			op.store_value(parent->compute_entry_point_pic_tail_address(next_literal()));
			break;
		case RT_HERE:
			op.store_value(parent->compute_here_address(next_literal(),op.rel_offset(),op.parent_code_block()));
			break;
		case RT_UNTAGGED:
			op.store_value(untag_fixnum(next_literal()));
			break;
		default:
			parent->store_external_address(op);
			break;
		}
	}
};

/* Perform all fixups on a code block */
void factor_vm::initialize_code_block(code_block *compiled, cell literals)
{
	initial_code_block_visitor visitor(this,literals);
	compiled->each_instruction_operand(visitor);
	compiled->flush_icache();

	/* next time we do a minor GC, we have to trace this code block, since
	the newly-installed instruction operands might point to literals in
	nursery or aging */
	code->write_barrier(compiled);
}

void factor_vm::initialize_code_block(code_block *compiled)
{
	std::map<code_block *,cell>::iterator iter = code->uninitialized_blocks.find(compiled);
	initialize_code_block(compiled,iter->second);
	code->uninitialized_blocks.erase(iter);
}

/* Fixup labels. This is done at compile time, not image load time */
void factor_vm::fixup_labels(array *labels, code_block *compiled)
{
	cell size = array_capacity(labels);

	for(cell i = 0; i < size; i += 3)
	{
		relocation_class rel_class = (relocation_class)untag_fixnum(array_nth(labels,i));
		cell offset = untag_fixnum(array_nth(labels,i + 1));
		cell target = untag_fixnum(array_nth(labels,i + 2));

		relocation_entry new_entry(RT_HERE,rel_class,offset);

		instruction_operand op(new_entry,compiled,0);
		op.store_value(target + (cell)compiled->entry_point());
	}
}

/* Might GC */
code_block *factor_vm::allot_code_block(cell size, code_block_type type)
{
	code_block *block = code->allocator->allot(size + sizeof(code_block));

	/* If allocation failed, do a full GC and compact the code heap.
	A full GC that occurs as a result of the data heap filling up does not
	trigger a compaction. This setup ensures that most GCs do not compact
	the code heap, but if the code fills up, it probably means it will be
	fragmented after GC anyway, so its best to compact. */
	if(block == NULL)
	{
		primitive_compact_gc();
		block = code->allocator->allot(size + sizeof(code_block));

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
		{
			std::cout << "Code heap used: " << code->allocator->occupied_space() << "\n";
			std::cout << "Code heap free: " << code->allocator->free_space() << "\n";
			fatal_error("Out of memory in add-compiled-block",0);
		}
	}

	block->set_type(type);
	return block;
}

/* Might GC */
code_block *factor_vm::add_code_block(code_block_type type, cell code_, cell labels_, cell owner_, cell relocation_, cell parameters_, cell literals_)
{
	data_root<byte_array> code(code_,this);
	data_root<object> labels(labels_,this);
	data_root<object> owner(owner_,this);
	data_root<byte_array> relocation(relocation_,this);
	data_root<array> parameters(parameters_,this);
	data_root<array> literals(literals_,this);

	cell code_length = array_capacity(code.untagged());
	code_block *compiled = allot_code_block(code_length,type);

	compiled->owner = owner.value();

	/* slight space optimization */
	if(relocation.type() == BYTE_ARRAY_TYPE && array_capacity(relocation.untagged()) == 0)
		compiled->relocation = false_object;
	else
		compiled->relocation = relocation.value();

	if(parameters.type() == ARRAY_TYPE && array_capacity(parameters.untagged()) == 0)
		compiled->parameters = false_object;
	else
		compiled->parameters = parameters.value();

	/* code */
	memcpy(compiled + 1,code.untagged() + 1,code_length);

	/* fixup labels */
	if(to_boolean(labels.value()))
		fixup_labels(labels.as<array>().untagged(),compiled);

	/* Once we are ready, fill in literal and word references in this code
	block's instruction operands. In most cases this is done right after this
	method returns, except when compiling words with the non-optimizing
	compiler at the beginning of bootstrap */
	this->code->uninitialized_blocks.insert(std::make_pair(compiled,literals.value()));

	/* next time we do a minor GC, we have to trace this code block, since
	the fields of the code_block struct might point into nursery or aging */
	this->code->write_barrier(compiled);

	return compiled;
}

}
