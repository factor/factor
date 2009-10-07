namespace factor
{

/* statistics */
struct generation_statistics {
	cell collections;
	u64 gc_time;
	u64 max_gc_time;
	cell object_count;
	u64 bytes_copied;
};

struct gc_statistics {
	generation_statistics generations[gen_count];
	u64 cards_scanned;
	u64 decks_scanned;
	u64 card_scan_time;
	cell code_heap_scans;
};

struct gc_state {
	/* The data heap we're collecting */
	data_heap *data;

	/* sometimes we grow the heap */
	bool growing_data_heap;
	data_heap *old_data_heap;

	/* Which generation is being collected */
	cell collecting_gen;

	/* If true, we are collecting aging space for the second time, so if it is still
	   full, we go on to collect tenured */
	bool collecting_aging_again;

	/* GC start time, for benchmarking */
	u64 start_time;

        jmp_buf gc_unwind;

	explicit gc_state(data_heap *data_, bool growing_data_heap_, cell collecting_gen_);
	~gc_state();

	inline bool collecting_nursery_p()
	{
		return collecting_gen == nursery_gen;
	}

	inline bool collecting_aging_p()
	{
		return collecting_gen == aging_gen;
	}

	inline bool collecting_tenured_p()
	{
		return collecting_gen == tenured_gen;
	}

	inline bool collecting_accumulation_gen_p()
	{
		return ((collecting_aging_p() && !collecting_aging_again)
			|| collecting_tenured_p());
	}
};

template<typename Strategy> struct cheney_collector {
	factor_vm *myvm;
	gc_state *current_gc;
	old_space *target;
	cell scan;

	explicit cheney_collector(factor_vm *myvm_, old_space *target);
	Strategy &strategy();
	object *allot(cell size);
	cell trace_next(cell scan);
	object *copy_object(object *untagged);
	bool should_copy_p(object *untagged);
	void go();
};

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm);

}
