#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *parent_) :
	copying_collector<tenured_space,full_policy>(
		parent_,
		&parent_->gc_stats.full_stats,
		parent_->data->tenured,
		full_policy(parent_)) {}

struct stack_frame_marker {
	factor_vm *parent;
	full_collector *collector;

	explicit stack_frame_marker(full_collector *collector_) :
		parent(collector_->parent), collector(collector_) {}

	void operator()(stack_frame *frame)
	{
		collector->mark_code_block(parent->frame_code(frame));
	}
};

/* Mark code blocks executing in currently active stack frames. */
void full_collector::mark_active_blocks()
{
	stack_frame_marker marker(this);
	parent->iterate_active_frames(marker);
}

void full_collector::mark_object_code_block(object *obj)
{
	switch(obj->h.hi_tag())
	{
	case WORD_TYPE:
		{
			word *w = (word *)obj;
			if(w->code)
				mark_code_block(w->code);
			if(w->profiling)
				mark_code_block(w->profiling);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)obj;
			if(q->code)
				mark_code_block(q->code);
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)obj;
			stack_frame_marker marker(this);
			parent->iterate_callstack_object(stack,marker);
			break;
		}
	}
}

struct callback_tracer {
	full_collector *collector;

	callback_tracer(full_collector *collector_) : collector(collector_) {}
	
	void operator()(callback *stub)
	{
		collector->mark_code_block(stub->compiled);
	}
};

void full_collector::trace_callbacks()
{
	callback_tracer tracer(this);
	parent->callbacks->iterate(tracer);
}

/* Trace all literals referenced from a code block. Only for aging and nursery collections */
void full_collector::trace_literal_references(code_block *compiled)
{
	this->trace_handle(&compiled->owner);
	this->trace_handle(&compiled->literals);
	this->trace_handle(&compiled->relocation);
}

/* Mark all literals referenced from a word XT. Only for tenured
collections */
void full_collector::mark_code_block(code_block *compiled)
{
	this->code->mark_block(compiled);
	trace_literal_references(compiled);
}

void full_collector::cheneys_algorithm()
{
	while(scan && scan < target->here)
	{
		object *obj = (object *)scan;
		this->trace_slots(obj);
		this->mark_object_code_block(obj);
		scan = target->next_object_after(scan);
	}
}

void factor_vm::collect_full_impl(bool trace_contexts_p)
{
	full_collector collector(this);

	code->state->clear_mark_bits();

	collector.trace_roots();
        if(trace_contexts_p)
	{
		collector.trace_contexts();
		collector.mark_active_blocks();
		collector.trace_callbacks();
	}

	collector.cheneys_algorithm();

	data->reset_generation(data->aging);
	nursery.here = nursery.start;
}

void factor_vm::collect_growing_heap(cell requested_bytes,
	bool trace_contexts_p,
	bool compact_code_heap_p)
{
	/* Grow the data heap and copy all live objects to the new heap. */
	data_heap *old = data;
	set_data_heap(data->grow(requested_bytes));
	collect_full_impl(trace_contexts_p);
	delete old;

	if(compact_code_heap_p)
		compact_code_heap(trace_contexts_p);
	else
		relocate_code_heap();

	code->clear_remembered_set();
}

void factor_vm::collect_full(bool trace_contexts_p, bool compact_code_heap_p)
{
	/* Copy all live objects to the tenured semispace. */
	std::swap(data->tenured,data->tenured_semispace);
	data->reset_generation(data->tenured);
	collect_full_impl(trace_contexts_p);

	if(compact_code_heap_p)
		compact_code_heap(trace_contexts_p);
	else
		update_code_heap_words_and_literals();

	code->clear_remembered_set();
}

}
