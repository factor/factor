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
	nursery_size_before = parent->nursery.occupied_space();
	aging_size_before = parent->data->aging->occupied_space();
	tenured_size_before = parent->data->tenured->occupied_space();
	tenured_free_block_count_before = parent->data->tenured->free_blocks.free_block_count;
	code_size_before = parent->code->allocator->occupied_space();
	code_free_block_count_before = parent->code->allocator->free_blocks.free_block_count;
	start_time = current_micros();
}

void gc_event::started_card_scan()
{
	card_scan_time = current_micros();
}

void gc_event::ended_card_scan(cell cards_scanned_, cell decks_scanned_)
{
	cards_scanned += cards_scanned_;
	decks_scanned += decks_scanned_;
	card_scan_time = (current_micros() - card_scan_time);
}

void gc_event::started_code_scan()
{
	code_scan_time = current_micros();
}

void gc_event::ended_code_scan(cell code_blocks_scanned_)
{
	code_blocks_scanned += code_blocks_scanned_;
	code_scan_time = (current_micros() - code_scan_time);
}

void gc_event::started_data_sweep()
{
	data_sweep_time = current_micros();
}

void gc_event::ended_data_sweep()
{
	data_sweep_time = (current_micros() - data_sweep_time);
}

void gc_event::started_code_sweep()
{
	code_sweep_time = current_micros();
}

void gc_event::ended_code_sweep()
{
	code_sweep_time = (current_micros() - code_sweep_time);
}

void gc_event::started_compaction()
{
	compaction_time = current_micros();
}

void gc_event::ended_compaction()
{
	compaction_time = (current_micros() - compaction_time);
}

void gc_event::ended_gc(factor_vm *parent)
{
	nursery_size_after = parent->nursery.occupied_space();
	aging_size_after = parent->data->aging->occupied_space();
	tenured_size_after = parent->data->tenured->occupied_space();
	tenured_free_block_count_after = parent->data->tenured->free_blocks.free_block_count;
	code_size_after = parent->code->allocator->occupied_space();
	code_free_block_count_after = parent->code->allocator->free_blocks.free_block_count;
	total_time = current_micros() - start_time;
}

std::ostream &operator<<(std::ostream &out, const gc_event *event)
{
	out << "<event\n"
	    << " op                              = '" << event->op                              << "'\n"
	    << " nursery_size_before             = '" << event->nursery_size_before             << "'\n"
	    << " aging_size_before               = '" << event->aging_size_before               << "'\n"
	    << " tenured_size_before             = '" << event->tenured_size_before             << "'\n"
	    << " tenured_free_block_count_before = '" << event->tenured_free_block_count_before << "'\n"
	    << " code_size_before                = '" << event->code_size_before                << "'\n"
	    << " code_free_block_count_before    = '" << event->code_free_block_count_before    << "'\n"
	    << " nursery_size_after              = '" << event->nursery_size_after              << "'\n"
	    << " aging_size_after                = '" << event->aging_size_after                << "'\n"
	    << " tenured_size_after              = '" << event->tenured_size_after              << "'\n"
	    << " tenured_free_block_count_after  = '" << event->tenured_free_block_count_after  << "'\n"
	    << " code_size_after                 = '" << event->code_size_after                 << "'\n"
	    << " code_free_block_count_after     = '" << event->code_free_block_count_after     << "'\n"
	    << " cards_scanned                   = '" << event->cards_scanned                   << "'\n"
	    << " decks_scanned                   = '" << event->decks_scanned                   << "'\n"
	    << " code_blocks_scanned             = '" << event->code_blocks_scanned             << "'\n"
	    << " start_time                      = '" << event->start_time                      << "'\n"
	    << " total_time                      = '" << event->total_time                      << "'\n"
	    << " card_scan_time                  = '" << event->card_scan_time                  << "'\n"
	    << " code_scan_time                  = '" << event->code_scan_time                  << "'\n"
	    << " data_sweep_time                 = '" << event->data_sweep_time                 << "'\n"
	    << " code_sweep_time                 = '" << event->code_sweep_time                 << "'\n"
	    << " compaction_time                 = '" << event->compaction_time                 << "' />";
	return out;
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

void gc_state::start_again(gc_op op_, factor_vm *parent)
{
	event->ended_gc(parent);
	if(parent->verbose_gc) std::cout << event << std::endl;
	delete event;
	event = new gc_event(op_,parent);
	op = op_;
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
		switch(current_gc->op)
		{
		case collect_nursery_op:
			current_gc->start_again(collect_aging_op,this);
			break;
		case collect_aging_op:
			current_gc->start_again(collect_to_tenured_op,this);
			break;
		case collect_to_tenured_op:
			current_gc->start_again(collect_full_op,this);
			break;
		case collect_full_op:
		case collect_compact_op:
			current_gc->start_again(collect_growing_heap_op,this);
			break;
		default:
			critical_error("Bad GC op",current_gc->op);
			break;
		}
	}

	switch(current_gc->op)
	{
	case collect_nursery_op:
		collect_nursery();
		break;
	case collect_aging_op:
		collect_aging();
		break;
	case collect_to_tenured_op:
		collect_to_tenured();
		break;
	case collect_full_op:
		collect_mark_impl(trace_contexts_p);
		collect_sweep_impl();
		update_code_heap_words_and_literals();
		break;
	case collect_compact_op:
		collect_mark_impl(trace_contexts_p);
		collect_compact_impl(trace_contexts_p);
		break;
	case collect_growing_heap_op:
		collect_growing_heap(requested_bytes,trace_contexts_p);
		break;
	default:
		critical_error("Bad GC op\n",current_gc->op);
		break;
	}

	current_gc->event->ended_gc(this);

	if(verbose_gc) std::cout << current_gc->event << std::endl;

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

/* classes.tuple uses this to reshape tuples; tools.deploy.shaker uses this
   to coalesce equal but distinct quotations and wrappers. */
void factor_vm::primitive_become()
{
	array *new_objects = untag_check<array>(dpop());
	array *old_objects = untag_check<array>(dpop());

	cell capacity = array_capacity(new_objects);
	if(capacity != array_capacity(old_objects))
		critical_error("bad parameters to become",0);

	cell i;

	for(i = 0; i < capacity; i++)
	{
		tagged<object> old_obj(array_nth(old_objects,i));
		tagged<object> new_obj(array_nth(new_objects,i));

		if(old_obj != new_obj)
			old_obj->h.forward_to(new_obj.untagged());
	}

	primitive_full_gc();

	/* If a word's definition quotation was in old_objects and the
	   quotation in new_objects is not compiled, we might leak memory
	   by referencing the old quotation unless we recompile all
	   unoptimized words. */
	compile_all_words();
}

void factor_vm::inline_gc(cell *gc_roots_base, cell gc_roots_size)
{
	for(cell i = 0; i < gc_roots_size; i++)
		gc_locals.push_back((cell)&gc_roots_base[i]);

	primitive_minor_gc();

	for(cell i = 0; i < gc_roots_size; i++)
		gc_locals.pop_back();
}

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *parent)
{
	parent->inline_gc(gc_roots_base,gc_roots_size);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
object *factor_vm::allot_object(header header, cell size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		primitive_full_gc();
#endif

	object *obj;

	/* If the object is smaller than the nursery, allocate it in the nursery,
	after a GC if needed */
	if(size < nursery.size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + size > nursery.end)
			primitive_minor_gc();

		obj = nursery.allot(size);
	}
	else
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

		obj = data->tenured->allot(size);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		char *start = (char *)obj;
		for(cell offset = 0; offset < size; offset += card_size)
			write_barrier((cell *)(start + offset));
	}

	obj->h = header;
	return obj;
}

}
