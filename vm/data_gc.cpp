#include "master.hpp"

namespace factor
{

void factor_vm::init_data_gc()
{
	code->youngest_referenced_generation = data->nursery();
}

gc_state::gc_state(data_heap *data_, bool growing_data_heap_, cell collecting_gen_) :
	data(data_),
	growing_data_heap(growing_data_heap_),
	collecting_gen(collecting_gen_),
        collecting_aging_again(false),
	start_time(current_micros()) { }

gc_state::~gc_state() { }

template<typename Strategy> object *factor_vm::resolve_forwarding(object *untagged, Strategy &strategy)
{
	check_data_pointer(untagged);

	/* is there another forwarding pointer? */
	while(untagged->h.forwarding_pointer_p())
		untagged = untagged->h.forwarding_pointer();

	/* we've found the destination */
	untagged->h.check_header();
	return untagged;
}

template<typename Strategy> void factor_vm::trace_handle(cell *handle, Strategy &strategy)
{
	cell pointer = *handle;

	if(!immediate_p(pointer))
	{
		object *untagged = untag<object>(pointer);
		if(strategy.should_copy_p(untagged))
		{
			object *forwarding = resolve_forwarding(untagged,strategy);

			if(forwarding == untagged)
				untagged = strategy.copy_object(untagged);
			else if(strategy.should_copy_p(forwarding))
				untagged = strategy.copy_object(forwarding);
			else
				untagged = forwarding;

			*handle = RETAG(untagged,TAG(pointer));
		}
	}
}

template<typename Strategy> void factor_vm::trace_slots(object *ptr, Strategy &strategy)
{
	cell *slot = (cell *)ptr;
	cell *end = (cell *)((cell)ptr + binary_payload_start(ptr));

	if(slot != end)
	{
		slot++;
		for(; slot < end; slot++) trace_handle(slot,strategy);
	}
}

template<typename Strategy> object *factor_vm::promote_object(object *untagged, Strategy &strategy)
{
	cell size = untagged_object_size(untagged);
	object *newpointer = strategy.allot(size);
	if(!newpointer) longjmp(current_gc->gc_unwind,1);

	gc_stats *s = &stats[current_gc->collecting_gen];
	s->object_count++;
	s->bytes_copied += size;

	memcpy(newpointer,untagged,size);
	untagged->h.forward_to(newpointer);

	return newpointer;
}

template<typename Strategy> void factor_vm::trace_card(card *ptr, cell gen, cell here, Strategy &strategy)
{
	cell card_scan = card_to_addr(ptr) + card_offset(ptr);
	cell card_end = card_to_addr(ptr + 1);

	if(here < card_end)
		card_end = here;

	strategy.copy_reachable_objects(card_scan,&card_end);

	cards_scanned++;
}

template<typename Strategy> void factor_vm::trace_card_deck(card_deck *deck, cell gen, card mask, card unmask, Strategy &strategy)
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
					trace_card(&ptr[card],gen,here,strategy);
					ptr[card] &= ~unmask;
				}
			}
		}
	}

	decks_scanned++;
}

/* Trace all objects referenced from marked cards */
template<typename Strategy> void factor_vm::trace_generation_cards(cell gen, Strategy &strategy)
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
		else if(gen == data->aging())
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
	else if(current_gc->collecting_aging_p())
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
			trace_card_deck(ptr,gen,mask,unmask,strategy);
			*ptr &= ~unmask;
		}
	}
}

/* Scan cards in all generations older than the one being collected, copying
old->new references */
template<typename Strategy> void factor_vm::trace_cards(Strategy &strategy)
{
	u64 start = current_micros();

	cell i;
	for(i = current_gc->collecting_gen + 1; i < gen_count; i++)
		trace_generation_cards(i,strategy);

	card_scan_time += (current_micros() - start);
}

/* Copy all tagged pointers in a range of memory */
template<typename Strategy> void factor_vm::trace_stack_elements(segment *region, cell top, Strategy &strategy)
{
	cell ptr = region->start;

	for(; ptr <= top; ptr += sizeof(cell))
		trace_handle((cell*)ptr,strategy);
}

template<typename Strategy> void factor_vm::trace_registered_locals(Strategy &strategy)
{
	std::vector<cell>::const_iterator iter = gc_locals.begin();
	std::vector<cell>::const_iterator end = gc_locals.end();

	for(; iter < end; iter++)
		trace_handle((cell *)(*iter),strategy);
}

template<typename Strategy> void factor_vm::trace_registered_bignums(Strategy &strategy)
{
	std::vector<cell>::const_iterator iter = gc_bignums.begin();
	std::vector<cell>::const_iterator end = gc_bignums.end();

	for(; iter < end; iter++)
	{
		cell *handle = (cell *)(*iter);

		if(*handle)
		{
			*handle |= BIGNUM_TYPE;
			trace_handle(handle,strategy);
			*handle &= ~BIGNUM_TYPE;
		}
	}
}

/* Copy roots over at the start of GC, namely various constants, stacks,
the user environment and extra roots registered by local_roots.hpp */
template<typename Strategy> void factor_vm::trace_roots(Strategy &strategy)
{
	trace_handle(&T,strategy);
	trace_handle(&bignum_zero,strategy);
	trace_handle(&bignum_pos_one,strategy);
	trace_handle(&bignum_neg_one,strategy);

	trace_registered_locals(strategy);
	trace_registered_bignums(strategy);

	int i;
	for(i = 0; i < USER_ENV; i++)
		trace_handle(&userenv[i],strategy);
}

template<typename Strategy> struct stack_frame_marker {
	factor_vm *myvm;
	Strategy &strategy;

	explicit stack_frame_marker(factor_vm *myvm_, Strategy &strategy_) :
		myvm(myvm_), strategy(strategy_) {}
	void operator()(stack_frame *frame)
	{
		myvm->mark_code_block(myvm->frame_code(frame),strategy);
	}
};

/* Mark code blocks executing in currently active stack frames. */
template<typename Strategy> void factor_vm::mark_active_blocks(context *stacks, Strategy &strategy)
{
	if(current_gc->collecting_tenured_p())
	{
		cell top = (cell)stacks->callstack_top;
		cell bottom = (cell)stacks->callstack_bottom;

		stack_frame_marker<Strategy> marker(this,strategy);
		iterate_callstack(top,bottom,marker);
	}
}

template<typename Strategy> void factor_vm::mark_object_code_block(object *object, Strategy &strategy)
{
	switch(object->h.hi_tag())
	{
	case WORD_TYPE:
		{
			word *w = (word *)object;
			if(w->code)
				mark_code_block(w->code,strategy);
			if(w->profiling)
				mark_code_block(w->profiling,strategy);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)object;
			if(q->code)
				mark_code_block(q->code,strategy);
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)object;
			stack_frame_marker<Strategy> marker(this,strategy);
			iterate_callstack_object(stack,marker);
			break;
		}
	}
}

template<typename Strategy> void factor_vm::trace_contexts(Strategy &strategy)
{
	save_stacks();
	context *stacks = stack_chain;

	while(stacks)
	{
		trace_stack_elements(stacks->datastack_region,stacks->datastack,strategy);
		trace_stack_elements(stacks->retainstack_region,stacks->retainstack,strategy);

		trace_handle(&stacks->catchstack_save,strategy);
		trace_handle(&stacks->current_callback_save,strategy);

		mark_active_blocks(stacks,strategy);

		stacks = stacks->next;
	}
}

/* Trace all literals referenced from a code block. Only for aging and nursery collections */
template<typename Strategy> void factor_vm::trace_literal_references(code_block *compiled, Strategy &strategy)
{
	trace_handle(&compiled->owner,strategy);
	trace_handle(&compiled->literals,strategy);
	trace_handle(&compiled->relocation,strategy);
}

/* Trace literals referenced from all code blocks. Only for aging and nursery collections */
template<typename Strategy> void factor_vm::trace_code_heap_roots(Strategy &strategy)
{
	if(current_gc->collecting_gen >= code->youngest_referenced_generation)
	{
		unordered_map<code_block *,cell>::const_iterator iter = code->remembered_set.begin();
		unordered_map<code_block *,cell>::const_iterator end = code->remembered_set.end();

		for(; iter != end; iter++)
		{
			if(current_gc->collecting_gen >= iter->second)
				trace_literal_references(iter->first,strategy);
		}

		code_heap_scans++;
	}
}

/* Mark all literals referenced from a word XT. Only for tenured
collections */
template<typename Strategy> void factor_vm::mark_code_block(code_block *compiled, Strategy &strategy)
{
	check_code_address((cell)compiled);

	code->mark_block(compiled);
	trace_literal_references(compiled,strategy);
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
	code->remembered_set.clear();
	code->youngest_referenced_generation = data->tenured();
}

void factor_vm::update_dirty_code_blocks()
{
	/* The youngest generation that any code block can now reference */
	cell gen;

	if(current_gc->collecting_accumulation_gen_p())
		gen = current_gc->collecting_gen;
	else
		gen = current_gc->collecting_gen + 1;

	unordered_map<code_block *,cell>::iterator iter = code->remembered_set.begin();
	unordered_map<code_block *,cell>::iterator end = code->remembered_set.end();

	for(; iter != end; iter++)
	{
		if(current_gc->collecting_gen >= iter->second)
		{
			check_code_address((cell)iter->first);
			update_literal_references(iter->first);
			iter->second = gen;
		}
	}

	code->youngest_referenced_generation = gen;
}

template<typename Strategy>
copying_collector<Strategy>::copying_collector(factor_vm *myvm_, zone *newspace_)
: myvm(myvm_), current_gc(myvm_->current_gc), newspace(newspace_)
{
	scan = newspace->here;
}

template<typename Strategy> Strategy &copying_collector<Strategy>::strategy()
{
	return static_cast<Strategy &>(*this);
}

template<typename Strategy> object *copying_collector<Strategy>::allot(cell size)
{
	if(newspace->here + size <= newspace->end)
		return myvm->allot_zone(newspace,size);
	else
		return NULL;
}

template<typename Strategy> object *copying_collector<Strategy>::copy_object(object *untagged)
{
	return myvm->promote_object(untagged,strategy());
}

template<typename Strategy> bool copying_collector<Strategy>::should_copy_p(object *pointer)
{
	return strategy().should_copy_p(pointer);
}

template<typename Strategy> cell copying_collector<Strategy>::trace_next(cell scan)
{
	object *obj = (object *)scan;
	myvm->trace_slots(obj,strategy());
	return scan + myvm->untagged_object_size(obj);
}

template<typename Strategy> void copying_collector<Strategy>::go()
{
	strategy().copy_reachable_objects(scan,&newspace->here);
}

struct nursery_collector : copying_collector<nursery_collector>
{
	explicit nursery_collector(factor_vm *myvm_, zone *newspace_) :
		copying_collector<nursery_collector>(myvm_,newspace_) {}

	bool should_copy_p(object *untagged)
	{
		return myvm->nursery.contains_p(untagged);
	}

	void copy_reachable_objects(cell scan, cell *end)
	{
		while(scan < *end) scan = trace_next(scan);
	}
};

struct aging_collector : copying_collector<aging_collector>
{
	zone *tenured;

	explicit aging_collector(factor_vm *myvm_, zone *newspace_) :
		copying_collector<aging_collector>(myvm_,newspace_),
		tenured(&myvm->data->generations[myvm->data->tenured()]) {}

	bool should_copy_p(object *untagged)
	{
		if(newspace->contains_p(untagged))
			return false;
		else
			return !tenured->contains_p(untagged);
	}
	
	void copy_reachable_objects(cell scan, cell *end)
	{
		while(scan < *end) scan = trace_next(scan);
	}
};

struct aging_again_collector : copying_collector<aging_again_collector>
{
	explicit aging_again_collector(factor_vm *myvm_, zone *newspace_) :
		copying_collector<aging_again_collector>(myvm_,newspace_) {}

	bool should_copy_p(object *untagged)
	{
		return !newspace->contains_p(untagged);
	}
	
	void copy_reachable_objects(cell scan, cell *end)
	{
		while(scan < *end) scan = trace_next(scan);
	}
};

struct tenured_collector : copying_collector<tenured_collector>
{
	explicit tenured_collector(factor_vm *myvm_, zone *newspace_) :
		copying_collector<tenured_collector>(myvm_,newspace_) {}
	
	bool should_copy_p(object *untagged)
	{
		return !newspace->contains_p(untagged);
	}
	
	void copy_reachable_objects(cell scan, cell *end)
	{
		while(scan < *end)
		{
			myvm->mark_object_code_block(myvm->untag<object>(scan),*this);
			scan = trace_next(scan);
		}
	}
};

void factor_vm::collect_nursery()
{
	nursery_collector collector(this,&data->generations[data->aging()]);

	trace_roots(collector);
	trace_contexts(collector);
	trace_cards(collector);
	trace_code_heap_roots(collector);
	collector.go();
	update_dirty_code_blocks();

	nursery.here = nursery.start;
}

void factor_vm::collect_aging()
{
	std::swap(data->generations[data->aging()],data->semispaces[data->aging()]);
	reset_generation(data->aging());

	aging_collector collector(this,&data->generations[data->aging()]);

	trace_roots(collector);
	trace_contexts(collector);
	trace_cards(collector);
	trace_code_heap_roots(collector);
	collector.go();
	update_dirty_code_blocks();

	nursery.here = nursery.start;
}

void factor_vm::collect_aging_again()
{
	aging_again_collector collector(this,&data->generations[data->tenured()]);

	trace_roots(collector);
	trace_contexts(collector);
	trace_cards(collector);
	trace_code_heap_roots(collector);
	collector.go();
	update_dirty_code_blocks();

	reset_generation(data->aging());
	nursery.here = nursery.start;
}

void factor_vm::collect_tenured(cell requested_bytes, bool trace_contexts_)
{
	if(current_gc->growing_data_heap)
	{
		current_gc->old_data_heap = data;
		set_data_heap(grow_data_heap(current_gc->old_data_heap,requested_bytes));
	}
	else
	{
		std::swap(data->generations[data->tenured()],data->semispaces[data->tenured()]);
		reset_generation(data->tenured());
	}

	tenured_collector collector(this,&data->generations[data->tenured()]);

        trace_roots(collector);
        if(trace_contexts_) trace_contexts(collector);
        collector.go();
        free_unmarked_code_blocks();

	reset_generation(data->aging());
	nursery.here = nursery.start;

	if(current_gc->growing_data_heap)
		delete current_gc->old_data_heap;
}

void factor_vm::record_gc_stats()
{
	gc_stats *s = &stats[current_gc->collecting_gen];

	cell gc_elapsed = (current_micros() - current_gc->start_time);
	s->collections++;
	s->gc_time += gc_elapsed;
	if(s->max_gc_time < gc_elapsed)
		s->max_gc_time = gc_elapsed;
}

/* Collect gen and all younger generations.
If growing_data_heap_ is true, we must grow the data heap to such a size that
an allocation of requested_bytes won't fail */
void factor_vm::garbage_collection(cell collecting_gen_, bool growing_data_heap_, bool trace_contexts_, cell requested_bytes)
{
	assert(!gc_off);
	assert(!current_gc);

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
			collect_aging_again();
		else
			collect_aging();
	}
        else if(current_gc->collecting_tenured_p())
        	collect_tenured(requested_bytes,trace_contexts_);

	record_gc_stats();

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

	for(i = 0; i < gen_count; i++)
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
	for(cell i = 0; i < gen_count; i++)
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

	if(nursery.size > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + size > nursery.end)
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
