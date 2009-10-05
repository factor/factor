#include "master.hpp"

namespace factor
{

void factor_vm::init_data_gc()
{
	last_code_heap_scan = data->nursery();
}

gc_state::gc_state(data_heap *data_, bool growing_data_heap_, cell collecting_gen_) :
	data(data_),
	growing_data_heap(growing_data_heap_),
	collecting_gen(collecting_gen_),
        collecting_aging_again(false),
	start_time(current_micros()) { }

gc_state::~gc_state() { }

/* Given a pointer to oldspace, copy it to newspace */
object *factor_vm::copy_untagged_object_impl(object *pointer, cell size)
{
	if(current_gc->newspace->here + size >= current_gc->newspace->end)
		longjmp(current_gc->gc_unwind,1);

	object *newpointer = allot_zone(current_gc->newspace,size);

	gc_stats *s = &stats[current_gc->collecting_gen];
	s->object_count++;
	s->bytes_copied += size;

	memcpy(newpointer,pointer,size);
	return newpointer;
}

object *factor_vm::copy_object_impl(object *untagged)
{
	object *newpointer = copy_untagged_object_impl(untagged,untagged_object_size(untagged));
	untagged->h.forward_to(newpointer);
	return newpointer;
}

bool factor_vm::should_copy_p(object *untagged)
{
	if(in_zone(current_gc->newspace,untagged))
		return false;
	if(current_gc->collecting_tenured_p())
		return true;
	else if(data->have_aging_p() && current_gc->collecting_gen == data->aging())
		return !in_zone(&data->generations[data->tenured()],untagged);
	else if(current_gc->collecting_nursery_p())
		return in_zone(&nursery,untagged);
	else
	{
		critical_error("Bug in should_copy_p",(cell)untagged);
		return false;
	}
}

/* Follow a chain of forwarding pointers */
object *factor_vm::resolve_forwarding(object *untagged)
{
	check_data_pointer(untagged);

	/* is there another forwarding pointer? */
	if(untagged->h.forwarding_pointer_p())
		return resolve_forwarding(untagged->h.forwarding_pointer());
	/* we've found the destination */
	else
	{
		untagged->h.check_header();
		if(should_copy_p(untagged))
			return copy_object_impl(untagged);
		else
			return untagged;
	}
}

template<typename Type> Type *factor_vm::copy_untagged_object(Type *untagged)
{
	check_data_pointer(untagged);

	if(untagged->h.forwarding_pointer_p())
		untagged = (Type *)resolve_forwarding(untagged->h.forwarding_pointer());
	else
	{
		untagged->h.check_header();
		untagged = (Type *)copy_object_impl(untagged);
	}

	return untagged;
}

cell factor_vm::copy_object(cell pointer)
{
	return RETAG(copy_untagged_object(untag<object>(pointer)),TAG(pointer));
}

void factor_vm::trace_handle(cell *handle)
{
	cell pointer = *handle;

	if(!immediate_p(pointer))
	{
		object *obj = untag<object>(pointer);
		check_data_pointer(obj);
		if(should_copy_p(obj))
			*handle = copy_object(pointer);
	}
}

/* Scan all the objects in the card */
void factor_vm::trace_card(card *ptr, cell gen, cell here)
{
	cell card_scan = card_to_addr(ptr) + card_offset(ptr);
	cell card_end = card_to_addr(ptr + 1);

	if(here < card_end)
		card_end = here;

	copy_reachable_objects(card_scan,&card_end);

	cards_scanned++;
}

void factor_vm::trace_card_deck(card_deck *deck, cell gen, card mask, card unmask)
{
	card *first_card = deck_to_card(deck);
	card *last_card = deck_to_card(deck + 1);

	cell here = data->generations[gen].here;

	u32 *quad_ptr;
	u32 quad_mask = mask | (mask << 8) | (mask << 16) | (mask << 24);

	for(quad_ptr = (u32 *)first_card; quad_ptr < (u32 *)last_card; quad_ptr++)
	{
		if(*quad_ptr & quad_mask)
		{
			card *ptr = (card *)quad_ptr;

			int card;
			for(card = 0; card < 4; card++)
			{
				if(ptr[card] & mask)
				{
					trace_card(&ptr[card],gen,here);
					ptr[card] &= ~unmask;
				}
			}
		}
	}

	decks_scanned++;
}

/* Copy all newspace objects referenced from marked cards to the destination */
void factor_vm::trace_generation_cards(cell gen)
{
	card_deck *first_deck = addr_to_deck(data->generations[gen].start);
	card_deck *last_deck = addr_to_deck(data->generations[gen].end);

	card mask, unmask;

	/* if we are collecting the nursery, we care about old->nursery pointers
	but not old->aging pointers */
	if(current_gc->collecting_nursery_p())
	{
		mask = card_points_to_nursery;

		/* after the collection, no old->nursery pointers remain
		anywhere, but old->aging pointers might remain in tenured
		space */
		if(gen == data->tenured())
			unmask = card_points_to_nursery;
		/* after the collection, all cards in aging space can be
		cleared */
		else if(data->have_aging_p() && gen == data->aging())
			unmask = card_mark_mask;
		else
		{
			critical_error("bug in trace_generation_cards",gen);
			return;
		}
	}
	/* if we are collecting aging space into tenured space, we care about
	all old->nursery and old->aging pointers. no old->aging pointers can
	remain */
	else if(data->have_aging_p() && current_gc->collecting_gen == data->aging())
	{
		if(current_gc->collecting_aging_again)
		{
			mask = card_points_to_aging;
			unmask = card_mark_mask;
		}
		/* after we collect aging space into the aging semispace, no
		old->nursery pointers remain but tenured space might still have
		pointers to aging space. */
		else
		{
			mask = card_points_to_aging;
			unmask = card_points_to_nursery;
		}
	}
	else
	{
		critical_error("bug in trace_generation_cards",gen);
		return;
	}

	card_deck *ptr;

	for(ptr = first_deck; ptr < last_deck; ptr++)
	{
		if(*ptr & mask)
		{
			trace_card_deck(ptr,gen,mask,unmask);
			*ptr &= ~unmask;
		}
	}
}

/* Scan cards in all generations older than the one being collected, copying
old->new references */
void factor_vm::trace_cards()
{
	u64 start = current_micros();

	cell i;
	for(i = current_gc->collecting_gen + 1; i < data->gen_count; i++)
		trace_generation_cards(i);

	card_scan_time += (current_micros() - start);
}

/* Copy all tagged pointers in a range of memory */
void factor_vm::trace_stack_elements(segment *region, cell top)
{
	cell ptr = region->start;

	for(; ptr <= top; ptr += sizeof(cell))
		trace_handle((cell*)ptr);
}

void factor_vm::trace_registered_locals()
{
	std::vector<cell>::const_iterator iter = gc_locals.begin();
	std::vector<cell>::const_iterator end = gc_locals.end();

	for(; iter < end; iter++)
		trace_handle((cell *)(*iter));
}

void factor_vm::trace_registered_bignums()
{
	std::vector<cell>::const_iterator iter = gc_bignums.begin();
	std::vector<cell>::const_iterator end = gc_bignums.end();

	for(; iter < end; iter++)
	{
		bignum **handle = (bignum **)(*iter);
		bignum *pointer = *handle;

		if(pointer)
		{
			check_data_pointer(pointer);
			if(should_copy_p(pointer))
				*handle = copy_untagged_object(pointer);
#ifdef FACTOR_DEBUG
			assert((*handle)->h.hi_tag() == BIGNUM_TYPE);
#endif
		}
	}
}

/* Copy roots over at the start of GC, namely various constants, stacks,
the user environment and extra roots registered by local_roots.hpp */
void factor_vm::trace_roots()
{
	trace_handle(&T);
	trace_handle(&bignum_zero);
	trace_handle(&bignum_pos_one);
	trace_handle(&bignum_neg_one);

	trace_registered_locals();
	trace_registered_bignums();

	int i;
	for(i = 0; i < USER_ENV; i++)
		trace_handle(&userenv[i]);
}

void factor_vm::trace_contexts()
{
	save_stacks();
	context *stacks = stack_chain;

	while(stacks)
	{
		trace_stack_elements(stacks->datastack_region,stacks->datastack);
		trace_stack_elements(stacks->retainstack_region,stacks->retainstack);

		trace_handle(&stacks->catchstack_save);
		trace_handle(&stacks->current_callback_save);

		mark_active_blocks(stacks);

		stacks = stacks->next;
	}
}

cell factor_vm::copy_next_from_nursery(cell scan)
{
	cell *obj = (cell *)scan;
	cell *end = (cell *)(scan + binary_payload_start((object *)scan));

	if(obj != end)
	{
		obj++;

		cell nursery_start = nursery.start;
		cell nursery_end = nursery.end;

		for(; obj < end; obj++)
		{
			cell pointer = *obj;

			if(!immediate_p(pointer))
			{
				check_data_pointer((object *)pointer);
				if(pointer >= nursery_start && pointer < nursery_end)
					*obj = copy_object(pointer);
			}
		}
	}

	return scan + untagged_object_size((object *)scan);
}

cell factor_vm::copy_next_from_aging(cell scan)
{
	cell *obj = (cell *)scan;
	cell *end = (cell *)(scan + binary_payload_start((object *)scan));

	if(obj != end)
	{
		obj++;

		cell tenured_start = data->generations[data->tenured()].start;
		cell tenured_end = data->generations[data->tenured()].end;

		cell newspace_start = current_gc->newspace->start;
		cell newspace_end = current_gc->newspace->end;

		for(; obj < end; obj++)
		{
			cell pointer = *obj;

			if(!immediate_p(pointer))
			{
				check_data_pointer((object *)pointer);
				if(!(pointer >= newspace_start && pointer < newspace_end)
				   && !(pointer >= tenured_start && pointer < tenured_end))
					*obj = copy_object(pointer);
			}
		}
	}

	return scan + untagged_object_size((object *)scan);
}

cell factor_vm::copy_next_from_tenured(cell scan)
{
	cell *obj = (cell *)scan;
	cell *end = (cell *)(scan + binary_payload_start((object *)scan));

	if(obj != end)
	{
		obj++;

		cell newspace_start = current_gc->newspace->start;
		cell newspace_end = current_gc->newspace->end;

		for(; obj < end; obj++)
		{
			cell pointer = *obj;

			if(!immediate_p(pointer))
			{
				check_data_pointer((object *)pointer);
				if(!(pointer >= newspace_start && pointer < newspace_end))
					*obj = copy_object(pointer);
			}
		}
	}

	mark_object_code_block((object *)scan);

	return scan + untagged_object_size((object *)scan);
}

void factor_vm::copy_reachable_objects(cell scan, cell *end)
{
	if(current_gc->collecting_nursery_p())
	{
		while(scan < *end)
			scan = copy_next_from_nursery(scan);
	}
	else if(data->have_aging_p() && current_gc->collecting_gen == data->aging())
	{
		while(scan < *end)
			scan = copy_next_from_aging(scan);
	}
	else if(current_gc->collecting_tenured_p())
	{
		while(scan < *end)
			scan = copy_next_from_tenured(scan);
	}
}

void factor_vm::update_code_heap_roots()
{
	if(current_gc->collecting_gen >= last_code_heap_scan)
	{
		code_heap_scans++;

		trace_code_heap_roots();

		if(current_gc->collecting_accumulation_gen_p())
			last_code_heap_scan = current_gc->collecting_gen;
		else
			last_code_heap_scan = current_gc->collecting_gen + 1;
	}
}

struct literal_and_word_reference_updater {
	factor_vm *myvm;

	literal_and_word_reference_updater(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(heap_block *block)
	{
		code_block *compiled = (code_block *)block;
		myvm->update_literal_references(compiled);
		myvm->update_word_references(compiled);
	}
};

void factor_vm::free_unmarked_code_blocks()
{
	literal_and_word_reference_updater updater(this);
	code->free_unmarked(updater);
	last_code_heap_scan = current_gc->collecting_gen;
}

void factor_vm::update_dirty_code_blocks()
{
	std::set<code_block *> dirty_code_blocks = current_gc->dirty_code_blocks;
	std::set<code_block *>::const_iterator iter = dirty_code_blocks.begin();
	std::set<code_block *>::const_iterator end = dirty_code_blocks.end();

	for(; iter != end; iter++)
		update_literal_references(*iter);

	dirty_code_blocks.clear();
}

/* Prepare to start copying reachable objects into an unused zone */
void factor_vm::begin_gc(cell requested_bytes)
{
	if(current_gc->growing_data_heap)
	{
		assert(current_gc->collecting_tenured_p());

		current_gc->old_data_heap = data;
		set_data_heap(grow_data_heap(current_gc->old_data_heap,requested_bytes));
		current_gc->newspace = &data->generations[data->tenured()];
	}
	else if(current_gc->collecting_accumulation_gen_p())
	{
		/* when collecting one of these generations, rotate it
		with the semispace */
		zone z = data->generations[current_gc->collecting_gen];
		data->generations[current_gc->collecting_gen] = data->semispaces[current_gc->collecting_gen];
		data->semispaces[current_gc->collecting_gen] = z;
		reset_generation(current_gc->collecting_gen);
		current_gc->newspace = &data->generations[current_gc->collecting_gen];
		clear_cards(current_gc->collecting_gen,current_gc->collecting_gen);
		clear_decks(current_gc->collecting_gen,current_gc->collecting_gen);
		clear_allot_markers(current_gc->collecting_gen,current_gc->collecting_gen);
	}
	else
	{
		/* when collecting a younger generation, we copy
		reachable objects to the next oldest generation,
		so we set the newspace so the next generation. */
		current_gc->newspace = &data->generations[current_gc->collecting_gen + 1];
	}
}

void factor_vm::end_gc()
{
	gc_stats *s = &stats[current_gc->collecting_gen];

	cell gc_elapsed = (current_micros() - current_gc->start_time);
	s->collections++;
	s->gc_time += gc_elapsed;
	if(s->max_gc_time < gc_elapsed)
		s->max_gc_time = gc_elapsed;

	if(current_gc->growing_data_heap)
		delete current_gc->old_data_heap;

	if(current_gc->collecting_nursery_p())
	{
		nursery.here = nursery.start;
	}
	else if(current_gc->collecting_accumulation_gen_p())
	{
		reset_generations(data->nursery(),current_gc->collecting_gen - 1);
	}
	else
	{
		/* all generations up to and including the one
		collected are now empty */
		reset_generations(data->nursery(),current_gc->collecting_gen);
	}
}

/* Collect gen and all younger generations.
If growing_data_heap_ is true, we must grow the data heap to such a size that
an allocation of requested_bytes won't fail */
void factor_vm::garbage_collection(cell collecting_gen_, bool growing_data_heap_, bool trace_contexts_, cell requested_bytes)
{
	if(gc_off)
	{
		critical_error("GC disabled",collecting_gen_);
		return;
	}

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
                        current_gc->growing_data_heap = true;

                        /* see the comment in unmark_marked() */
                        code->unmark_marked();
                }
                /* we try collecting aging space twice before going on to
                collect tenured */
                else if(data->have_aging_p()
                        && current_gc->collecting_gen == data->aging()
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

        begin_gc(requested_bytes);

        /* Initialize chase pointer */
        cell scan = current_gc->newspace->here;

        /* Trace objects referenced from global environment */
        trace_roots();

        /* Trace objects referenced from stacks, unless we're doing
        save-image-and-exit in which case stack objects are irrelevant */
        if(trace_contexts_) trace_contexts();

        /* Trace objects referenced from older generations */
        trace_cards();

        /* On minor GC, trace code heap roots if it has pointers
        to this generation or younger. Otherwise, tracing data heap objects
        will mark all reachable code blocks, and we free the unmarked ones
        after. */
        if(!current_gc->collecting_tenured_p() && current_gc->collecting_gen >= last_code_heap_scan)
        {
                update_code_heap_roots();
        }

        /* do some copying -- this is where most of the work is done */
        copy_reachable_objects(scan,&current_gc->newspace->here);

        /* On minor GC, update literal references in code blocks, now that all
        data heap objects are in their final location. On a major GC,
        free all code blocks that did not get marked during tracing. */
        if(current_gc->collecting_tenured_p())
                free_unmarked_code_blocks();
        else
                update_dirty_code_blocks();

        /* GC completed without any generations filling up; finish up */
	end_gc();

	delete current_gc;
	current_gc = NULL;
}

void factor_vm::gc()
{
	garbage_collection(data->tenured(),false,true,0);
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

	for(i = 0; i < max_gen_count; i++)
	{
		gc_stats *s = &stats[i];
		result.add(allot_cell(s->collections));
		result.add(tag<bignum>(long_long_to_bignum(s->gc_time)));
		result.add(tag<bignum>(long_long_to_bignum(s->max_gc_time)));
		result.add(allot_cell(s->collections == 0 ? 0 : s->gc_time / s->collections));
		result.add(allot_cell(s->object_count));
		result.add(tag<bignum>(long_long_to_bignum(s->bytes_copied)));

		total_gc_time += s->gc_time;
	}

	result.add(tag<bignum>(ulong_long_to_bignum(total_gc_time)));
	result.add(tag<bignum>(ulong_long_to_bignum(cards_scanned)));
	result.add(tag<bignum>(ulong_long_to_bignum(decks_scanned)));
	result.add(tag<bignum>(ulong_long_to_bignum(card_scan_time)));
	result.add(allot_cell(code_heap_scans));

	result.trim();
	dpush(result.elements.value());
}

void factor_vm::clear_gc_stats()
{
	for(cell i = 0; i < max_gen_count; i++)
		memset(&stats[i],0,sizeof(gc_stats));

	cards_scanned = 0;
	decks_scanned = 0;
	card_scan_time = 0;
	code_heap_scans = 0;
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

	garbage_collection(data->nursery(),false,true,0);

	for(cell i = 0; i < gc_roots_size; i++)
		gc_locals.pop_back();
}

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm)
{
	ASSERTVM();
	VM_PTR->inline_gc(gc_roots_base,gc_roots_size);
}

inline object *factor_vm::allot_zone(zone *z, cell a)
{
	cell h = z->here;
	z->here = h + align8(a);
	object *obj = (object *)h;
	allot_barrier(obj);
	return obj;
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

	if(nursery.size - allot_buffer_zone > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + allot_buffer_zone + size > nursery.end)
			garbage_collection(data->nursery(),false,true,0);

		cell h = nursery.here;
		nursery.here = h + align8(size);
		obj = (object *)h;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
	{
		zone *tenured = &data->generations[data->tenured()];

		/* If tenured space does not have enough room, collect */
		if(tenured->here + size > tenured->end)
		{
			gc();
			tenured = &data->generations[data->tenured()];
		}

		/* If it still won't fit, grow the heap */
		if(tenured->here + size > tenured->end)
		{
			garbage_collection(data->tenured(),true,true,size);
			tenured = &data->generations[data->tenured()];
		}

		obj = allot_zone(tenured,size);

		/* Allows initialization code to store old->new pointers
		without hitting the write barrier in the common case of
		a nursery allocation */
		write_barrier(obj);
	}

	obj->h = header;
	return obj;
}

}
