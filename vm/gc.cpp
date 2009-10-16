#include "master.hpp"

namespace factor
{

gc_state::gc_state(gc_op op_) : op(op_), start_time(current_micros()) {}

gc_state::~gc_state() {}

void factor_vm::update_code_heap_for_minor_gc(std::set<code_block *> *remembered_set)
{
	/* The youngest generation that any code block can now reference */
	std::set<code_block *>::const_iterator iter = remembered_set->begin();
	std::set<code_block *>::const_iterator end = remembered_set->end();

	for(; iter != end; iter++) update_literal_references(*iter);
}

void factor_vm::record_gc_stats(generation_statistics *stats)
{
	cell gc_elapsed = (current_micros() - current_gc->start_time);
	stats->collections++;
	stats->gc_time += gc_elapsed;
	if(stats->max_gc_time < gc_elapsed)
		stats->max_gc_time = gc_elapsed;
}

void factor_vm::gc(gc_op op,
	cell requested_bytes,
	bool trace_contexts_p,
	bool compact_code_heap_p)
{
	assert(!gc_off);
	assert(!current_gc);

	save_stacks();

	current_gc = new gc_state(op);

	/* Keep trying to GC higher and higher generations until we don't run out
	of space */
	if(setjmp(current_gc->gc_unwind))
	{
		/* We come back here if a generation is full */
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
			/* Since we start tracing again, any previously
			marked code blocks must be re-marked and re-traced */
			code->clear_mark_bits();
			current_gc->op = collect_growing_heap_op;
			break;
		default:
			critical_error("Bad GC op\n",op);
			break;
		}
	}

	switch(current_gc->op)
	{
	case collect_nursery_op:
		collect_nursery();
		record_gc_stats(&gc_stats.nursery_stats);
		break;
	case collect_aging_op:
		collect_aging();
		record_gc_stats(&gc_stats.aging_stats);
		break;
	case collect_to_tenured_op:
		collect_to_tenured();
		record_gc_stats(&gc_stats.aging_stats);
		break;
	case collect_full_op:
		collect_full(trace_contexts_p,compact_code_heap_p);
		record_gc_stats(&gc_stats.full_stats);
		break;
	case collect_growing_heap_op:
		collect_growing_heap(requested_bytes,trace_contexts_p,compact_code_heap_p);
		record_gc_stats(&gc_stats.full_stats);
		break;
	default:
		critical_error("Bad GC op\n",op);
		break;
	}

	delete current_gc;
	current_gc = NULL;
}

void factor_vm::primitive_minor_gc()
{
	gc(collect_nursery_op,
		0, /* requested size */
		true, /* trace contexts? */
		false /* compact code heap? */);
}

void factor_vm::primitive_full_gc()
{
	gc(collect_full_op,
		0, /* requested size */
		true, /* trace contexts? */
		false /* compact code heap? */);
}

void factor_vm::primitive_compact_gc()
{
	gc(collect_full_op,
		0, /* requested size */
		true, /* trace contexts? */
		true /* compact code heap? */);
}

void factor_vm::add_gc_stats(generation_statistics *stats, growable_array *result)
{
	result->add(allot_cell(stats->collections));
	result->add(tag<bignum>(long_long_to_bignum(stats->gc_time)));
	result->add(tag<bignum>(long_long_to_bignum(stats->max_gc_time)));
	result->add(allot_cell(stats->collections == 0 ? 0 : stats->gc_time / stats->collections));
	result->add(allot_cell(stats->object_count));
	result->add(tag<bignum>(long_long_to_bignum(stats->bytes_copied)));
}

void factor_vm::primitive_gc_stats()
{
	growable_array result(this);

	add_gc_stats(&gc_stats.nursery_stats,&result);
	add_gc_stats(&gc_stats.aging_stats,&result);
	add_gc_stats(&gc_stats.full_stats,&result);

	u64 total_gc_time =
		gc_stats.nursery_stats.gc_time +
		gc_stats.aging_stats.gc_time +
		gc_stats.full_stats.gc_time;

	result.add(tag<bignum>(ulong_long_to_bignum(total_gc_time)));
	result.add(tag<bignum>(ulong_long_to_bignum(gc_stats.cards_scanned)));
	result.add(tag<bignum>(ulong_long_to_bignum(gc_stats.decks_scanned)));
	result.add(tag<bignum>(ulong_long_to_bignum(gc_stats.card_scan_time)));
	result.add(allot_cell(gc_stats.code_blocks_scanned));

	result.trim();
	dpush(result.elements.value());
}

void factor_vm::clear_gc_stats()
{
	memset(&gc_stats,0,sizeof(gc_statistics));
}

void factor_vm::primitive_clear_gc_stats()
{
	clear_gc_stats();
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

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm)
{
	myvm->inline_gc(gc_roots_base,gc_roots_size);
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
	if(nursery.size > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + size > nursery.end)
			primitive_minor_gc();

		obj = nursery.allot(size);
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		/* If tenured space does not have enough room, collect */
		if(data->tenured->here + size > data->tenured->end)
			primitive_full_gc();

		/* If it still won't fit, grow the heap */
		if(data->tenured->here + size > data->tenured->end)
		{
			gc(collect_growing_heap_op,
				size, /* requested size */
				true, /* trace contexts? */
				false /* compact code heap? */);
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
