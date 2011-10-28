namespace factor
{

#define FACTOR_PROFILE_SAMPLES_PER_SECOND 1000

struct profiling_sample
{
	// Number of samples taken before the safepoint that recorded the sample
	cell sample_count;
	// Number of samples taken during GC
	cell gc_sample_count;
	// Active context during sample
	context *ctx;
	// The callstack at safepoint time
	cell callstack;

	profiling_sample(cell sample_count,
		cell gc_sample_count,
		context *ctx,
		cell callstack)
		:
		sample_count(sample_count),
		gc_sample_count(gc_sample_count),
		ctx(ctx),
		callstack(callstack)
	{
	}
};

}
