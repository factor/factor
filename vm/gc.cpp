#include "master.hpp"

namespace factor
{

gc_event::gc_event(gc_op op_, factor_vm *parent) :
	op(op_),
	cards_scanned(0),
	decks_scanned(0),
	code_blocks_scanned(0),
	start_time(current_micros()),
	card_scan_time(0),
	code_scan_time(0),
	data_sweep_time(0),
	code_sweep_time(0),
	compaction_time(0)
{
	data_heap_before = parent->data_room();
	code_heap_before = parent->code_room();
	start_time = current_micros();
}

void gc_event::started_card_scan()
{
	temp_time = current_micros();
}

void gc_event::ended_card_scan(cell cards_scanned_, cell decks_scanned_)
{
	cards_scanned += cards_scanned_;
	decks_scanned += decks_scanned_;
	card_scan_time = (current_micros() - temp_time);
}

void gc_event::started_code_scan()
{
	temp_time = current_micros();
}

void gc_event::ended_code_scan(cell code_blocks_scanned_)
{
	code_blocks_scanned += code_blocks_scanned_;
	code_scan_time = (current_micros() - temp_time);
}

void gc_event::started_data_sweep()
{
	temp_time = current_micros();
}

void gc_event::ended_data_sweep()
{
	data_sweep_time = (current_micros() - temp_time);
}

void gc_event::started_code_sweep()
{
	temp_time = current_micros();
}

void gc_event::ended_code_sweep()
{
	code_sweep_time = (current_micros() - temp_time);
}

void gc_event::started_compaction()
{
	temp_time = current_micros();
}

void gc_event::ended_compaction()
{
	compaction_time = (current_micros() - temp_time);
}

void gc_event::ended_gc(factor_vm *parent)
{
	data_heap_after = parent->data_room();
	code_heap_after = parent->code_room();
	total_time = current_micros() - start_time;
}

gc_state::gc_state(gc_op op_, factor_vm *parent) : op(op_), start_time(current_micros())
{
	event = new gc_event(op,parent);
}

gc_state::~gc_state()
{
	delete event;
	event = NULL;
}

void factor_vm::end_gc()
{
	current_gc->event->ended_gc(this);
	if(gc_events) gc_events->push_back(*current_gc->event);
	delete current_gc->event;
	current_gc->event = NULL;
}

void factor_vm::start_gc_again()
{
	end_gc();

	switch(current_gc->op)
	{
	case collect_nursery_op:
		current_gc->op = collect_aging_op;
		break;
	case collect_aging_op:
		current_gc->op = collect_to_tenured_op;
		break;
	case collect_to_tenured_op:
		current_gc->op = collect_full_op;
		break;
	case collect_full_op:
	case collect_compact_op:
		current_gc->op = collect_growing_heap_op;
		break;
	default:
		critical_error("Bad GC op",current_gc->op);
		break;
	}

	current_gc->event = new gc_event(current_gc->op,this);
}

void factor_vm::update_code_heap_for_minor_gc(std::set<code_block *> *remembered_set)
{
	/* The youngest generation that any code block can now reference */
	std::set<code_block *>::const_iterator iter = remembered_set->begin();
	std::set<code_block *>::const_iterator end = remembered_set->end();

	for(; iter != end; iter++) update_literal_references(*iter);
}

void factor_vm::gc(gc_op op, cell requested_bytes, bool trace_contexts_p)
{
	assert(!gc_off);
	assert(!current_gc);

	save_stacks();

	current_gc = new gc_state(op,this);

	/* Keep trying to GC higher and higher generations until we don't run out
	of space */
	if(setjmp(current_gc->gc_unwind))
	{
		/* We come back here if a generation is full */
		start_gc_again();
	}

	current_gc->event->op = current_gc->op;

	switch(current_gc->op)
	{
	case collect_nursery_op:
		collect_nursery();
		break;
	case collect_aging_op:
		collect_aging();
		if(data->low_memory_p())
		{
			current_gc->op = collect_full_op;
			current_gc->event->op = collect_full_op;
			collect_full(trace_contexts_p);
		}
		break;
	case collect_to_tenured_op:
		collect_to_tenured();
		if(data->low_memory_p())
		{
			current_gc->op = collect_full_op;
			current_gc->event->op = collect_full_op;
			collect_full(trace_contexts_p);
		}
		break;
	case collect_full_op:
		collect_full(trace_contexts_p);
		break;
	case collect_compact_op:
		collect_compact(trace_contexts_p);
		break;
	case collect_growing_heap_op:
		collect_growing_heap(requested_bytes,trace_contexts_p);
		break;
	default:
		critical_error("Bad GC op",current_gc->op);
		break;
	}

	end_gc();

	delete current_gc;
	current_gc = NULL;
}

void factor_vm::primitive_minor_gc()
{
	gc(collect_nursery_op,
		0, /* requested size */
		true /* trace contexts? */);
}

void factor_vm::primitive_full_gc()
{
	gc(collect_full_op,
		0, /* requested size */
		true /* trace contexts? */);
}

void factor_vm::primitive_compact_gc()
{
	gc(collect_compact_op,
		0, /* requested size */
		true /* trace contexts? */);
}

void factor_vm::inline_gc(cell *data_roots_base, cell data_roots_size)
{
	data_roots.push_back(data_root_range(data_roots_base,data_roots_size));
	primitive_minor_gc();
	data_roots.pop_back();
}

VM_C_API void inline_gc(cell *data_roots_base, cell data_roots_size, factor_vm *parent)
{
	parent->inline_gc(data_roots_base,data_roots_size);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
object *factor_vm::allot_large_object(cell type, cell size)
{
	/* If tenured space does not have enough room, collect and compact */
	if(!data->tenured->can_allot_p(size))
	{
		primitive_compact_gc();

		/* If it still won't fit, grow the heap */
		if(!data->tenured->can_allot_p(size))
		{
			gc(collect_growing_heap_op,
				size, /* requested size */
				true /* trace contexts? */);
		}
	}

	object *obj = data->tenured->allot(size);

	/* Allows initialization code to store old->new pointers
	without hitting the write barrier in the common case of
	a nursery allocation */
	write_barrier(obj,size);

	obj->initialize(type);
	return obj;
}

void factor_vm::primitive_enable_gc_events()
{
	gc_events = new std::vector<gc_event>();
}

void factor_vm::primitive_disable_gc_events()
{
	if(gc_events)
	{
		byte_array *data = byte_array_from_values(&gc_events->front(),gc_events->size());
		dpush(tag<byte_array>(data));

		delete gc_events;
		gc_events = NULL;
	}
	else
		dpush(false_object);
}

}
