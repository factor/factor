namespace factor
{

struct profiling_sample_count
{
	// Number of samples taken before the safepoint that recorded the sample
	fixnum sample_count;
	// Number of samples taken during GC
	fixnum gc_sample_count;
	// Number of samples taken during unoptimized compiler
	fixnum jit_sample_count;
	// Number of samples taken during foreign code execution
	fixnum foreign_sample_count;
	// Number of samples taken during code execution in non-Factor threads
	fixnum foreign_thread_sample_count;

	profiling_sample_count() :
		sample_count(0),
		gc_sample_count(0),
		jit_sample_count(0),
		foreign_sample_count(0),
		foreign_thread_sample_count(0) {}

	profiling_sample_count(fixnum sample_count,
		fixnum gc_sample_count,
		fixnum jit_sample_count,
		fixnum foreign_sample_count,
		fixnum foreign_thread_sample_count) :
		sample_count(sample_count),
		gc_sample_count(gc_sample_count),
		jit_sample_count(jit_sample_count),
		foreign_sample_count(foreign_sample_count),
		foreign_thread_sample_count(foreign_thread_sample_count) {}

	bool empty() const
	{
		return sample_count
			+ gc_sample_count
			+ jit_sample_count
			+ foreign_sample_count
			+ foreign_thread_sample_count == 0;
	}

	profiling_sample_count record_counts() volatile;
	void clear() volatile;
};

struct profiling_sample
{
	// Sample counts
	profiling_sample_count counts;
	// Active thread during sample
	cell thread;
	/* The callstack at safepoint time. Indexes to the beginning and ending
	code_block entries in the vm sample_callstacks array. */
	cell callstack_begin, callstack_end;

	profiling_sample(factor_vm *vm,
		bool prolog_p,
		profiling_sample_count const &counts,
		cell thread);
};

}
