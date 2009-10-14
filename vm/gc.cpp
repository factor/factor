#include "master.hpp"

namespace factor
{

gc_state::gc_state(data_heap *data_, bool growing_data_heap_, cell collecting_gen_) :
	data(data_),
	growing_data_heap(growing_data_heap_),
	collecting_gen(collecting_gen_),
        collecting_aging_again(false),
	start_time(current_micros()) { }

gc_state::~gc_state() { }

void factor_vm::update_dirty_code_blocks(std::set<code_block *> *remembered_set)
{
	/* The youngest generation that any code block can now reference */
	std::set<code_block *>::const_iterator iter = remembered_set->begin();
	std::set<code_block *>::const_iterator end = remembered_set->end();

	for(; iter != end; iter++) update_literal_references(*iter);
}

void factor_vm::record_gc_stats()
{
	generation_statistics *s = &gc_stats.generations[current_gc->collecting_gen];

	cell gc_elapsed = (current_micros() - current_gc->start_time);
	s->collections++;
	s->gc_time += gc_elapsed;
	if(s->max_gc_time < gc_elapsed)
		s->max_gc_time = gc_elapsed;
}

/* Collect gen and all younger generations.
If growing_data_heap_ is true, we must grow the data heap to such a size that
an allocation of requested_bytes won't fail */
void factor_vm::garbage_collection(cell collecting_gen_, bool growing_data_heap_, bool trace_contexts_p, cell requested_bytes)
{
	assert(!gc_off);
	assert(!current_gc);

	save_stacks();

	current_gc = new gc_state(data,growing_data_heap_,collecting_gen_);

	/* Keep trying to GC higher and higher generations until we don't run out
	of space */
	if(setjmp(current_gc->gc_unwind))
	{
		/* We come back here if a generation is full */

		/* We have no older generations we can try collecting, so we
		resort to growing the data heap */
		if(current_gc->collecting_tenured_p())
		{
			assert(!current_gc->growing_data_heap);
			current_gc->growing_data_heap = true;

			/* Since we start tracing again, any previously
			marked code blocks must be re-marked and re-traced */
			code->clear_mark_bits();
		}
		/* we try collecting aging space twice before going on to
		collect tenured */
		else if(current_gc->collecting_aging_p()
			&& !current_gc->collecting_aging_again)
		{
			current_gc->collecting_aging_again = true;
		}
		/* Collect the next oldest generation */
		else
		{
			current_gc->collecting_gen++;
		}
	}

	if(current_gc->collecting_nursery_p())
		collect_nursery();
	else if(current_gc->collecting_aging_p())
	{
		if(current_gc->collecting_aging_again)
			collect_to_tenured();
		else
			collect_aging();
	}
        else if(current_gc->collecting_tenured_p())
	{
		if(current_gc->growing_data_heap)
			collect_growing_heap(requested_bytes,trace_contexts_p);
		else
			collect_full(trace_contexts_p);
	}
	else
		critical_error("Bug in GC",0);

	record_gc_stats();

	delete current_gc;
	current_gc = NULL;
}

void factor_vm::gc()
{
	garbage_collection(tenured_gen,false,true,0);
}

void factor_vm::primitive_gc()
{
	gc();
}

void factor_vm::primitive_gc_stats()
{
	growable_array result(this);

	cell i;
	u64 total_gc_time = 0;

	for(i = 0; i < gen_count; i++)
	{
		generation_statistics *s = &gc_stats.generations[i];
		result.add(allot_cell(s->collections));
		result.add(tag<bignum>(long_long_to_bignum(s->gc_time)));
		result.add(tag<bignum>(long_long_to_bignum(s->max_gc_time)));
		result.add(allot_cell(s->collections == 0 ? 0 : s->gc_time / s->collections));
		result.add(allot_cell(s->object_count));
		result.add(tag<bignum>(long_long_to_bignum(s->bytes_copied)));

		total_gc_time += s->gc_time;
	}

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

	gc();

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

	garbage_collection(nursery_gen,false,true,0);

	for(cell i = 0; i < gc_roots_size; i++)
		gc_locals.pop_back();
}

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm)
{
	ASSERTVM();
	VM_PTR->inline_gc(gc_roots_base,gc_roots_size);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
object *factor_vm::allot_object(header header, cell size)
{
#ifdef GC_DEBUG
	if(!gc_off)
		gc();
#endif

	object *obj;

	if(nursery.size > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + size > nursery.end)
			garbage_collection(nursery_gen,false,true,0);

		obj = nursery.allot(size);
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		/* If tenured space does not have enough room, collect */
		if(data->tenured->here + size > data->tenured->end)
			gc();

		/* If it still won't fit, grow the heap */
		if(data->tenured->here + size > data->tenured->end)
			garbage_collection(tenured_gen,true,true,size);

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
