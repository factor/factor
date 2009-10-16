#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *myvm_) :
	copying_collector<tenured_space,full_policy>(
		myvm_,
		&myvm_->gc_stats.full_stats,
		myvm_->data->tenured,
		full_policy(myvm_)) {}

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
		scan = target->next_object_after(this->myvm,scan);
	}
}

/* After growing the heap, we have to perform a full relocation to update
references to card and deck arrays. */
struct after_growing_heap_updater {
	factor_vm *myvm;

	after_growing_heap_updater(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(heap_block *block)
	{
		myvm->relocate_code_block((code_block *)block);
	}
};

/* After a full GC that did not grow the heap, we have to update references
to literals and other words. */
struct after_full_updater {
	factor_vm *myvm;

	after_full_updater(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(heap_block *block)
	{
		myvm->update_code_block_for_full_gc((code_block *)block);
	}
};

void factor_vm::collect_full_impl(bool trace_contexts_p)
{
	full_collector collector(this);

	collector.trace_roots();
        if(trace_contexts_p)
	{
		collector.trace_contexts();
		collector.mark_active_blocks();
	}

	collector.cheneys_algorithm();

	reset_generation(data->aging);
	nursery.here = nursery.start;
}

void factor_vm::collect_growing_heap(cell requested_bytes, bool trace_contexts_p)
{
	/* Grow the data heap and copy all live objects to the new heap. */
	data_heap *old = data;
	set_data_heap(data->grow(requested_bytes));
	collect_full_impl(trace_contexts_p);
	delete old;

	after_growing_heap_updater updater(this);
	code->free_unmarked(updater);
	code->clear_remembered_set();
}

void factor_vm::collect_full(bool trace_contexts_p)
{
	/* Copy all live objects to the tenured semispace. */
	std::swap(data->tenured,data->tenured_semispace);
	reset_generation(data->tenured);
	collect_full_impl(trace_contexts_p);

	after_full_updater updater(this);
	code->free_unmarked(updater);
	code->clear_remembered_set();
}

}
