#include "master.hpp"

namespace factor
{

full_collector::full_collector(factor_vm *parent_) :
	collector<tenured_space,full_policy>(
		parent_,
		parent_->data->tenured,
		full_policy(parent_)) {}

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

struct object_start_map_updater {
	object_start_map *starts;

	explicit object_start_map_updater(object_start_map *starts_) : starts(starts_) {}

	void operator()(object *obj, cell size)
	{
		starts->record_object_start_offset(obj);
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
		collector.trace_slots(obj);
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
	data->tenured->starts.clear_object_start_offsets();
	object_start_map_updater updater(&data->tenured->starts);
	data->tenured->sweep(updater);
	current_gc->event->ended_data_sweep();
}

void factor_vm::collect_growing_heap(cell requested_bytes, bool trace_contexts_p)
{
	/* Grow the data heap and copy all live objects to the new heap. */
	data_heap *old = data;
	set_data_heap(data->grow(requested_bytes));
	collect_mark_impl(trace_contexts_p);
	collect_compact_impl(trace_contexts_p);
	delete old;
}

}
