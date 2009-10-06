namespace factor
{

/* statistics */
struct gc_stats {
	cell collections;
	u64 gc_time;
	u64 max_gc_time;
	cell object_count;
	u64 bytes_copied;
};

struct gc_state {
	/* The data heap we're collecting */
	data_heap *data;

	/* New objects are copied here */
	zone *newspace;

	/* sometimes we grow the heap */
	bool growing_data_heap;
	data_heap *old_data_heap;

	/* Which generation is being collected */
	cell collecting_gen;

	/* If true, we are collecting aging space for the second time, so if it is still
	   full, we go on to collect tenured */
	bool collecting_aging_again;

	/* A set of code blocks which need to have their literals updated */
	std::set<code_block *> dirty_code_blocks;

	/* GC start time, for benchmarking */
	u64 start_time;

        jmp_buf gc_unwind;

	explicit gc_state(data_heap *data_, bool growing_data_heap_, cell collecting_gen_);
	~gc_state();

	inline bool collecting_nursery_p()
	{
		return collecting_gen == data->nursery();
	}

	inline bool collecting_aging_p()
	{
		return data->have_aging_p() && collecting_gen == data->aging();
	}

	inline bool collecting_tenured_p()
	{
		return collecting_gen == data->tenured();
	}

	inline bool collecting_accumulation_gen_p()
	{
		return ((data->have_aging_p()
			 && collecting_gen == data->aging()
			 && !collecting_aging_again)
			|| collecting_gen == data->tenured());
	}
};

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm);

}
