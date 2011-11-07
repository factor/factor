#include "master.hpp"

namespace factor
{

void safepoint_state::enqueue_safepoint() volatile
{
	parent->code->guard_safepoint();
}

void safepoint_state::enqueue_fep(cell signal) volatile
{
	if (parent->fep_p)
		fatal_error("Low-level debugger interrupted", 0);
	atomic::store(&fep_p, true);
	if (signal != 0)
		atomic::store(&queued_signal, signal);
	enqueue_safepoint();
}

void safepoint_state::enqueue_signal(cell signal) volatile
{
	atomic::store(&queued_signal, signal);
	enqueue_safepoint();
}

void safepoint_state::enqueue_samples(cell samples, cell pc, bool foreign_thread_p) volatile
{
	if (atomic::load(&parent->sampling_profiler_p))
	{
		atomic::add(&sample_counts.sample_count, samples);
		if (foreign_thread_p)
			atomic::add(&sample_counts.foreign_thread_sample_count, samples);
		else {
			if (atomic::load(&parent->current_gc_p))
				atomic::fetch_add(&sample_counts.gc_sample_count, samples);
			if (atomic::load(&parent->current_jit_count) > 0)
				atomic::fetch_add(&sample_counts.jit_sample_count, samples);
			if (!parent->code->seg->in_segment_p(pc))
				atomic::fetch_add(&sample_counts.foreign_sample_count, samples);
		}
		enqueue_safepoint();
	}
}

void safepoint_state::handle_safepoint() volatile
{
	parent->code->unguard_safepoint();

	report_signal(parent->signal_pipe_input);

	if (atomic::load(&fep_p))
	{
		if (atomic::load(&parent->sampling_profiler_p))
			parent->end_sampling_profiler();
		std::cout << "Interrupted\n";
		parent->factorbug();
		atomic::store(&fep_p, false);
	}
	else if (atomic::load(&parent->sampling_profiler_p))
		parent->record_sample();
}

}
