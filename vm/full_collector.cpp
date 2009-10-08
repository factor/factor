#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *myvm_) :
	copying_collector<tenured_space,full_policy>(myvm_,myvm_->data->tenured,full_policy(myvm_)) {}

struct stack_frame_marker {
	factor_vm *myvm;
	full_collector *collector;

	explicit stack_frame_marker(full_collector *collector_) :
		myvm(collector_->myvm), collector(collector_) {}

	void operator()(stack_frame *frame)
	{
		collector->mark_code_block(myvm->frame_code(frame));
	}
};

/* Mark code blocks executing in currently active stack frames. */
void full_collector::mark_active_blocks()
{
	context *stacks = this->myvm->stack_chain;

	while(stacks)
	{
		cell top = (cell)stacks->callstack_top;
		cell bottom = (cell)stacks->callstack_bottom;

		stack_frame_marker marker(this);
		myvm->iterate_callstack(top,bottom,marker);

		stacks = stacks->next;
	}
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
			myvm->iterate_callstack_object(stack,marker);
			break;
		}
	}
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
	myvm->check_code_address((cell)compiled);

	this->myvm->code->mark_block(compiled);
	trace_literal_references(compiled);
}

void full_collector::cheneys_algorithm()
{
	while(scan && scan < target->here)
	{
		object *obj = (object *)scan;
		this->trace_slots(obj);
		this->mark_object_code_block(obj);
		scan = target->next_object_after(this->myvm,scan);
	}
}

void factor_vm::collect_full(cell requested_bytes, bool trace_contexts_p)
{
	if(current_gc->growing_data_heap)
	{
		current_gc->old_data_heap = data;
		set_data_heap(grow_data_heap(current_gc->old_data_heap,requested_bytes));
	}
	else
	{
		std::swap(data->tenured,data->tenured_semispace);
		reset_generation(data->tenured);
	}

	full_collector collector(this);

	collector.trace_roots();
        if(trace_contexts_p)
	{
		collector.trace_contexts();
		collector.mark_active_blocks();
	}

	collector.cheneys_algorithm();
	free_unmarked_code_blocks();

	reset_generation(data->aging);
	nursery.here = nursery.start;

	if(current_gc->growing_data_heap)
		delete current_gc->old_data_heap;
}

}
