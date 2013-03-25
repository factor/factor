#include "master.hpp"

namespace factor
{

gc_event::gc_event(gc_op op_, factor_vm *parent) :
	op(op_),
	cards_scanned(0),
	decks_scanned(0),
	code_blocks_scanned(0),
	start_time(nano_count()),
	card_scan_time(0),
	code_scan_time(0),
	data_sweep_time(0),
	code_sweep_time(0),
	compaction_time(0)
{
	data_heap_before = parent->data_room();
	code_heap_before = parent->code_room();
	start_time = nano_count();
}

void gc_event::started_card_scan()
{
	temp_time = nano_count();
}

void gc_event::ended_card_scan(cell cards_scanned_, cell decks_scanned_)
{
	cards_scanned += cards_scanned_;
	decks_scanned += decks_scanned_;
	card_scan_time = (cell)(nano_count() - temp_time);
}

void gc_event::started_code_scan()
{
	temp_time = nano_count();
}

void gc_event::ended_code_scan(cell code_blocks_scanned_)
{
	code_blocks_scanned += code_blocks_scanned_;
	code_scan_time = (cell)(nano_count() - temp_time);
}

void gc_event::started_data_sweep()
{
	temp_time = nano_count();
}

void gc_event::ended_data_sweep()
{
	data_sweep_time = (cell)(nano_count() - temp_time);
}

void gc_event::started_code_sweep()
{
	temp_time = nano_count();
}

void gc_event::ended_code_sweep()
{
	code_sweep_time = (cell)(nano_count() - temp_time);
}

void gc_event::started_compaction()
{
	temp_time = nano_count();
}

void gc_event::ended_compaction()
{
	compaction_time = (cell)(nano_count() - temp_time);
}

void gc_event::ended_gc(factor_vm *parent)
{
	data_heap_after = parent->data_room();
	code_heap_after = parent->code_room();
	total_time = (cell)(nano_count() - start_time);
}

gc_state::gc_state(gc_op op_, factor_vm *parent) : op(op_)
{
	if(parent->gc_events)
	{
		event = new gc_event(op,parent);
		start_time = nano_count();
	}
	else
		event = NULL;
}

gc_state::~gc_state()
{
	if(event)
	{
		delete event;
		event = NULL;
	}
}

void factor_vm::end_gc()
{
	if(gc_events)
	{
		current_gc->event->ended_gc(this);
		gc_events->push_back(*current_gc->event);
	}
}

void factor_vm::start_gc_again()
{
	end_gc();

	switch(current_gc->op)
	{
	case collect_nursery_op:
		/* Nursery collection can fail if aging does not have enough
		free space to fit all live objects from nursery. */
		current_gc->op = collect_aging_op;
		break;
	case collect_aging_op:
		/* Aging collection can fail if the aging semispace cannot fit
		all the live objects from the other aging semispace and the
		nursery. */
		current_gc->op = collect_to_tenured_op;
		break;
	default:
		/* Nothing else should fail mid-collection due to insufficient
		space in the target generation. */
		critical_error("Bad GC op",current_gc->op);
		break;
	}

	if(gc_events)
		current_gc->event = new gc_event(current_gc->op,this);
}

void factor_vm::set_current_gc_op(gc_op op)
{
	current_gc->op = op;
	if(gc_events) current_gc->event->op = op;
}

void factor_vm::gc(gc_op op, cell requested_size, bool trace_contexts_p)
{
	FACTOR_ASSERT(!gc_off);
	FACTOR_ASSERT(!current_gc);

	/* Important invariant: tenured space must have enough contiguous free
	space to fit the entire contents of the aging space and nursery. This is
	because when doing a full collection, objects from younger generations
	are promoted before any unreachable tenured objects are freed. */
	FACTOR_ASSERT(!data->high_fragmentation_p());

	current_gc = new gc_state(op,this);
	atomic::store(&current_gc_p, true);

	/* Keep trying to GC higher and higher generations until we don't run
	out of space in the target generation. */
	for(;;)
	{
		try
		{
			if(gc_events) current_gc->event->op = current_gc->op;

			switch(current_gc->op)
			{
			case collect_nursery_op:
				collect_nursery();
				break;
			case collect_aging_op:
				/* We end up here if the above fails. */
				collect_aging();
				if(data->high_fragmentation_p())
				{
					/* Change GC op so that if we fail again,
					we crash. */
					set_current_gc_op(collect_full_op);
					collect_full(trace_contexts_p);
				}
				break;
			case collect_to_tenured_op:
				/* We end up here if the above fails. */
				collect_to_tenured();
				if(data->high_fragmentation_p())
				{
					/* Change GC op so that if we fail again,
					we crash. */
					set_current_gc_op(collect_full_op);
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
				collect_growing_heap(requested_size,trace_contexts_p);
				break;
			default:
				critical_error("Bad GC op",current_gc->op);
				break;
			}

			break;
		}
		catch(const must_start_gc_again &)
		{
			/* We come back here if the target generation is full. */
			start_gc_again();
			continue;
		}
	}

	end_gc();

	atomic::store(&current_gc_p, false);
	delete current_gc;
	current_gc = NULL;

	/* Check the invariant again, just in case. */
	FACTOR_ASSERT(!data->high_fragmentation_p());
}

/* primitive_minor_gc() is invoked by inline GC checks, and it needs to fill in
uninitialized stack locations before actually calling the GC. See the comment
in compiler.cfg.stacks.uninitialized for details. */

struct call_frame_scrubber {
	factor_vm *parent;
	context *ctx;

	explicit call_frame_scrubber(factor_vm *parent_, context *ctx_) :
		parent(parent_), ctx(ctx_) {}

	void operator()(void *frame_top, cell frame_size, code_block *owner, void *addr)
	{
		cell return_address = owner->offset(addr);

		gc_info *info = owner->block_gc_info();

		FACTOR_ASSERT(return_address < owner->size());
		cell index = info->return_address_index(return_address);
		if(index != (cell)-1)
			ctx->scrub_stacks(info,index);
	}
};

void factor_vm::scrub_context(context *ctx)
{
	call_frame_scrubber scrubber(this,ctx);
	iterate_callstack(ctx,scrubber);
}

void factor_vm::scrub_contexts()
{
	std::set<context *>::const_iterator begin = active_contexts.begin();
	std::set<context *>::const_iterator end = active_contexts.end();
	while(begin != end)
	{
		scrub_context(*begin);
		begin++;
	}
}

void factor_vm::primitive_minor_gc()
{
	scrub_contexts();

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

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
/* Allocates memory */
object *factor_vm::allot_large_object(cell type, cell size)
{
	/* If tenured space does not have enough room, collect and compact */
	cell requested_size = size + data->high_water_mark();
	if(!data->tenured->can_allot_p(requested_size))
	{
		primitive_compact_gc();

		/* If it still won't fit, grow the heap */
		if(!data->tenured->can_allot_p(requested_size))
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

/* Allocates memory */
void factor_vm::primitive_disable_gc_events()
{
	if(gc_events)
	{
		growable_array result(this);

		std::vector<gc_event> *gc_events = this->gc_events;
		this->gc_events = NULL;

		std::vector<gc_event>::const_iterator iter = gc_events->begin();
		std::vector<gc_event>::const_iterator end = gc_events->end();

		for(; iter != end; iter++)
		{
			gc_event event = *iter;
			byte_array *obj = byte_array_from_value(&event);
			result.add(tag<byte_array>(obj));
		}

		result.trim();
		ctx->push(result.elements.value());

		delete this->gc_events;
	}
	else
		ctx->push(false_object);
}

}
