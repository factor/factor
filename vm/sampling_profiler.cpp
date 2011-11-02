#include "master.hpp"

namespace factor
{

profiling_sample_count profiling_sample_count::record_counts() volatile
{
	atomic::fence();
	profiling_sample_count returned(
		sample_count,
		gc_sample_count,
		jit_sample_count,
		foreign_sample_count,
		foreign_thread_sample_count);
	atomic::subtract(&sample_count, returned.sample_count);
	atomic::subtract(&gc_sample_count, returned.gc_sample_count);
	atomic::subtract(&jit_sample_count, returned.jit_sample_count);
	atomic::subtract(&foreign_sample_count, returned.foreign_sample_count);
	atomic::subtract(&foreign_thread_sample_count, returned.foreign_thread_sample_count);
	return returned;
}

void profiling_sample_count::clear() volatile
{
	sample_count = 0;
	gc_sample_count = 0;
	jit_sample_count = 0;
	foreign_sample_count = 0;
	foreign_thread_sample_count = 0;
	atomic::fence();
}

profiling_sample::profiling_sample(factor_vm *vm,
	profiling_sample_count const &counts,
	cell thread)
	:
	counts(counts),
	thread(thread)
{
	vm->record_callstack_sample(&callstack_begin, &callstack_end);
}

void factor_vm::record_sample()
{
	profiling_sample_count counts = safepoint_sample_counts.record_counts();
	if (!counts.empty())
		samples.push_back(profiling_sample(this,
			counts, special_objects[OBJ_CURRENT_THREAD]));
}

void factor_vm::record_callstack_sample(cell *begin, cell *end)
{
	*begin = sample_callstacks.size();
	stack_frame *frame = ctx->bottom_frame();

	while (frame >= ctx->callstack_top) {
		sample_callstacks.push_back(frame_code(frame)->owner);
		frame = frame_successor(frame);
	}

	*end = sample_callstacks.size();
}

void factor_vm::set_sampling_profiler(fixnum rate)
{
	bool sampling_p = !!rate;
	if (sampling_p == sampling_profiler_p)
		return;
	
	if (sampling_p)
		start_sampling_profiler(rate);
	else
		end_sampling_profiler();
}

void factor_vm::clear_samples()
{
	// Swapping into temporaries releases the vector's allocated storage,
	// whereas clear() would leave the allocation as-is
	std::vector<profiling_sample> sample_graveyard;
	std::vector<cell> sample_callstack_graveyard;
	samples.swap(sample_graveyard);
	sample_callstacks.swap(sample_callstack_graveyard);
}

void factor_vm::start_sampling_profiler(fixnum rate)
{
	samples_per_second = rate;
	safepoint_sample_counts.clear();
	clear_samples();
	samples.reserve(10*rate);
	sample_callstacks.reserve(100*rate);
	sampling_profiler_p = true;
	start_sampling_profiler_timer();
}

void factor_vm::end_sampling_profiler()
{
	atomic::store(&sampling_profiler_p, false);
	end_sampling_profiler_timer();
	record_sample();
}

void factor_vm::primitive_sampling_profiler()
{
	set_sampling_profiler(to_fixnum(ctx->pop()));
}

void factor_vm::primitive_get_samples()
{
	if (sampling_profiler_p || samples.empty()) {
		ctx->push(false_object);
	} else {
		data_root<array> samples_array(allot_array(samples.size(), false_object),this);
		std::vector<profiling_sample>::const_iterator from_iter = samples.begin();
		cell to_i = 0;

		for (; from_iter != samples.end(); ++from_iter, ++to_i)
		{
			data_root<array> sample(allot_array(7, false_object),this);

			set_array_nth(sample.untagged(),0,tag_fixnum(from_iter->counts.sample_count));
			set_array_nth(sample.untagged(),1,tag_fixnum(from_iter->counts.gc_sample_count));
			set_array_nth(sample.untagged(),2,tag_fixnum(from_iter->counts.jit_sample_count));
			set_array_nth(sample.untagged(),3,tag_fixnum(from_iter->counts.foreign_sample_count));
			set_array_nth(sample.untagged(),4,tag_fixnum(from_iter->counts.foreign_thread_sample_count));

			set_array_nth(sample.untagged(),5,from_iter->thread);

			cell callstack_size = from_iter->callstack_end - from_iter->callstack_begin;
			data_root<array> callstack(allot_array(callstack_size,false_object),this);

			std::vector<cell>::const_iterator
				callstacks_begin = sample_callstacks.begin(),
				c_from_iter = callstacks_begin + from_iter->callstack_begin,
				c_from_iter_end = callstacks_begin + from_iter->callstack_end;
			cell c_to_i = 0;

			for (; c_from_iter != c_from_iter_end; ++c_from_iter, ++c_to_i)
				set_array_nth(callstack.untagged(),c_to_i,*c_from_iter);

			set_array_nth(sample.untagged(),6,callstack.value());

			set_array_nth(samples_array.untagged(),to_i,sample.value());
		}
		ctx->push(samples_array.value());
	}
}

void factor_vm::primitive_clear_samples()
{
	clear_samples();
}

void factor_vm::enqueue_safepoint_sample(cell samples, cell pc, bool foreign_thread_p)
{
	if (atomic::load(&sampling_profiler_p))
	{
		atomic::add(&safepoint_sample_counts.sample_count, samples);
		if (foreign_thread_p)
			atomic::add(&safepoint_sample_counts.foreign_thread_sample_count, samples);
		else {
			if (atomic::load(&current_gc_p))
				atomic::add(&safepoint_sample_counts.gc_sample_count, samples);
			if (atomic::load(&current_jit_count) > 0)
				atomic::add(&safepoint_sample_counts.jit_sample_count, samples);
			if (pc != 0 && !code->seg->in_segment_p(pc))
				atomic::add(&safepoint_sample_counts.foreign_sample_count, samples);
		}
		code->guard_safepoint();
	}
}

}
