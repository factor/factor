#include "master.hpp"

namespace factor
{

profiling_sample::profiling_sample(factor_vm *vm,
	cell sample_count,
	cell gc_sample_count,
	context *ctx)
	:
	sample_count(sample_count),
	gc_sample_count(gc_sample_count),
	ctx(ctx)
{
	vm->record_callstack_sample(&callstack_begin, &callstack_end);
}

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
		this,
		recorded_sample_count,
		recorded_gc_sample_count,
		ctx
	));
}

void factor_vm::record_callstack_sample(cell *begin, cell *end)
{
	*begin = sample_callstacks.size();
	stack_frame *frame = ctx->bottom_frame();

	while (frame >= ctx->callstack_top) {
		sample_callstacks.push_back(frame_code(frame));
		frame = frame_successor(frame);
	}

	*end = sample_callstacks.size();
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
	sample_callstacks.reserve(100*FACTOR_PROFILE_SAMPLES_PER_SECOND);
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
