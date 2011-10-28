#include "master.hpp"

namespace factor
{

void factor_vm::record_sample()
{
	cell recorded_sample_count;
	cell recorded_gc_sample_count;

	recorded_sample_count = safepoint_sample_count;
	recorded_gc_sample_count = safepoint_gc_sample_count;
	if (recorded_sample_count == 0 && recorded_gc_sample_count == 0)
		return;

	/* Another sample signal could be raised while we record these counts */
	FACTOR_ATOMIC_SUB(&safepoint_sample_count, recorded_sample_count);
	FACTOR_ATOMIC_SUB(&safepoint_gc_sample_count, recorded_gc_sample_count);

	samples.push_back(profiling_sample(
		recorded_sample_count,
		recorded_gc_sample_count,
		ctx,
		capture_callstack(ctx)
	));
}

void factor_vm::set_sampling_profiler(bool sampling_p)
{
	if (sampling_p == sampling_profiler_p)
		return;
	
	if (sampling_p)
		start_sampling_profiler();
	else
		end_sampling_profiler();
}

void factor_vm::start_sampling_profiler()
{
	safepoint_sample_count = 0;
	safepoint_gc_sample_count = 0;
	samples.clear();
	samples.reserve(10*FACTOR_PROFILE_SAMPLES_PER_SECOND);
	sampling_profiler_p = true;
	start_sampling_profiler_timer();
}

void factor_vm::end_sampling_profiler()
{
	end_sampling_profiler_timer();
	record_sample();
	sampling_profiler_p = false;
}

void factor_vm::primitive_sampling_profiler()
{
	set_sampling_profiler(to_boolean(ctx->pop()));
}


}
