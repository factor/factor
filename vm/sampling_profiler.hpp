namespace factor
{

#define FACTOR_PROFILE_SAMPLES_PER_SECOND 1000

struct profiling_sample
{
	// Number of samples taken before the safepoint that recorded the sample
	fixnum sample_count;
	// Number of samples taken during GC
	fixnum gc_sample_count;
	// Number of samples taken during foreign code execution
	fixnum foreign_sample_count;
	// Number of samples taken during code execution in non-Factor threads
	fixnum foreign_thread_sample_count;
	// Active context during sample
	context *ctx;
	/* The callstack at safepoint time. Indexes to the beginning and ending
	code_block entries in the vm sample_callstacks array. */
	cell callstack_begin, callstack_end;

	profiling_sample(factor_vm *vm,
		fixnum sample_count,
		fixnum gc_sample_count,
		fixnum foreign_sample_count,
		fixnum foreign_thread_sample_count,
		context *ctx);
};

}
