#include "master.hpp"

namespace factor
{

inline static code_block_visitor<code_workhorse> make_code_visitor(factor_vm *parent)
{
	return code_block_visitor<code_workhorse>(parent,code_workhorse(parent));
}

full_collector::full_collector(factor_vm *parent_) :
	collector<tenured_space,full_policy>(
		parent_,
		parent_->data->tenured,
		full_policy(parent_)),
	code_visitor(make_code_visitor(parent_)) {}

void full_collector::trace_code_block(code_block *compiled)
{
	data_visitor.visit_code_block_objects(compiled);
	data_visitor.visit_embedded_literals(compiled);
	code_visitor.visit_embedded_code_pointers(compiled);
}

void full_collector::trace_context_code_blocks()
{
	code_visitor.visit_context_code_blocks();
}

void full_collector::trace_object_code_block(object *obj)
{
	code_visitor.visit_object_code_block(obj);
}

/* After a sweep, invalidate any code heap roots which are not marked,
so that if a block makes a tail call to a generic word, and the PIC
compiler triggers a GC, and the caller block gets gets GCd as a result,
the PIC code won't try to overwrite the call site */
void factor_vm::update_code_roots_for_sweep()
{
	std::vector<code_root *>::const_iterator iter = code_roots.begin();
	std::vector<code_root *>::const_iterator end = code_roots.end();

	mark_bits<code_block> *state = &code->allocator->state;

	for(; iter < end; iter++)
	{
		code_root *root = *iter;
		code_block *block = (code_block *)(root->value & -data_alignment);
		if(root->valid && !state->marked_p(block))
			root->valid = false;
	}
}

/* After a compaction, invalidate any code heap roots which are not
marked as above, and also slide the valid roots up so that call sites
can be updated correctly. */
void factor_vm::update_code_roots_for_compaction()
{
	std::vector<code_root *>::const_iterator iter = code_roots.begin();
	std::vector<code_root *>::const_iterator end = code_roots.end();

	mark_bits<code_block> *state = &code->allocator->state;

	for(; iter < end; iter++)
	{
		code_root *root = *iter;
		code_block *block = (code_block *)(root->value & -data_alignment);

		/* Offset of return address within 16-byte allocation line */
		cell offset = root->value - (cell)block;

		if(root->valid && state->marked_p((code_block *)root->value))
		{
			block = state->forward_block(block);
			root->value = (cell)block + offset;
		}
		else
			root->valid = false;
	}
}

void factor_vm::collect_mark_impl(bool trace_contexts_p)
{
	full_collector collector(this);

	mark_stack.clear();

	code->clear_mark_bits();
	data->tenured->clear_mark_bits();

	collector.trace_roots();
        if(trace_contexts_p)
	{
		collector.trace_contexts();
		collector.trace_context_code_blocks();
	}

	while(!mark_stack.empty())
	{
		cell ptr = mark_stack.back();
		mark_stack.pop_back();

		if(ptr & 1)
		{
			code_block *compiled = (code_block *)(ptr - 1);
			collector.trace_code_block(compiled);
		}
		else
		{
			object *obj = (object *)ptr;
			collector.trace_object(obj);
			collector.trace_object_code_block(obj);
		}
	}

	data->reset_generation(data->tenured);
	data->reset_generation(data->aging);
	data->reset_generation(&nursery);
	code->clear_remembered_set();
}

void factor_vm::collect_sweep_impl()
{
	current_gc->event->started_data_sweep();
	data->tenured->sweep();
	current_gc->event->ended_data_sweep();

	update_code_roots_for_sweep();

	current_gc->event->started_code_sweep();
	code->allocator->sweep();
	current_gc->event->ended_code_sweep();
}

void factor_vm::collect_full(bool trace_contexts_p)
{
	collect_mark_impl(trace_contexts_p);
	collect_sweep_impl();
	if(data->low_memory_p())
	{
		current_gc->op = collect_compact_op;
		current_gc->event->op = collect_compact_op;
		collect_compact_impl(trace_contexts_p);
	}
	code->flush_icache();
}

}
