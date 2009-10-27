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

void factor_vm::gc(gc_op op, cell requested_bytes, bool trace_contexts_p)
{
	assert(!gc_off);
	assert(!current_gc);

	save_stacks();

	current_gc = new gc_state(op);

	if(verbose_gc)
		std::cout << "GC requested, op=" << op << std::endl;

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
		case collect_compact_op:
			current_gc->op = collect_growing_heap_op;
			break;
		default:
			critical_error("Bad GC op",current_gc->op);
			break;
		}

		if(verbose_gc)
			std::cout << "GC rewind, op=" << current_gc->op << std::endl;
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

	if(verbose_gc)
		std::cout << "GC done, op=" << current_gc->op << std::endl;

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
