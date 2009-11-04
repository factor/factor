#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *parent_) :
	collector<tenured_space,full_policy>(
		parent_,
		parent_->data->tenured,
		full_policy(parent_)) {}

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
		code_block *block = (code_block *)(root->value & -block_granularity);
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
		code_block *block = (code_block *)(root->value & -block_granularity);

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

struct code_block_marker {
	code_heap *code;
	full_collector *collector;

	explicit code_block_marker(code_heap *code_, full_collector *collector_) :
		code(code_), collector(collector_) {}

	code_block *operator()(code_block *compiled)
	{
		if(!code->marked_p(compiled))
		{
			code->set_marked_p(compiled);
			collector->trace_literal_references(compiled);
		}

		return compiled;
	}
};

void factor_vm::collect_mark_impl(bool trace_contexts_p)
{
	full_collector collector(this);

	code->clear_mark_bits();
	data->tenured->clear_mark_bits();
	data->tenured->clear_mark_stack();

	code_block_visitor<code_block_marker> code_marker(this,code_block_marker(code,&collector));

	collector.trace_roots();
        if(trace_contexts_p)
	{
		collector.trace_contexts();
		code_marker.visit_context_code_blocks();
		code_marker.visit_callback_code_blocks();
	}

	std::vector<object *> *mark_stack = &data->tenured->mark_stack;

	while(!mark_stack->empty())
	{
		object *obj = mark_stack->back();
		mark_stack->pop_back();
		collector.trace_object(obj);
		code_marker.visit_object_code_block(obj);
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
	update_code_roots_for_sweep();
	current_gc->event->ended_data_sweep();
}

void factor_vm::collect_full(bool trace_contexts_p)
{
	collect_mark_impl(trace_contexts_p);
	collect_sweep_impl();
	if(data->tenured->largest_free_block() <= data->nursery->size + data->aging->size)
		collect_compact_impl(trace_contexts_p);
	else
		update_code_heap_words_and_literals();
}

void factor_vm::collect_compact(bool trace_contexts_p)
{
	collect_mark_impl(trace_contexts_p);
	collect_compact_impl(trace_contexts_p);
}

void factor_vm::collect_growing_heap(cell requested_bytes, bool trace_contexts_p)
{
	/* Grow the data heap and copy all live objects to the new heap. */
	data_heap *old = data;
	set_data_heap(data->grow(requested_bytes));
	collect_mark_impl(trace_contexts_p);
	collect_compact_code_impl(trace_contexts_p);
	delete old;
}

}
