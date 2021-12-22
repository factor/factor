#include "master.hpp"

namespace factor {

// This is like the growable_array class, except the whole of it
// exists on the Factor heap. growarr = growable array.
static cell growarr_capacity(array *growarr) {
  return untag_fixnum(growarr->data()[0]);
}

static cell growarr_nth(array *growarr, cell slot) {
  return array_nth(untag<array>(growarr->data()[1]), slot);
}

// Allocates memory
array* factor_vm::allot_growarr() {
  data_root<array> contents(allot_array(10, false_object), this);
  array *growarr = allot_uninitialized_array<array>(2);
  set_array_nth(growarr, 0, tag_fixnum(0));
  set_array_nth(growarr, 1, contents.value());
  return growarr;
}

// Allocates memory
void factor_vm::growarr_add(array *growarr_, cell elt_) {
  data_root<array> growarr(growarr_, this);
  data_root<object> elt(elt_, this);
  data_root<array> contents(growarr.untagged()->data()[1], this);

  cell count = growarr_capacity(growarr.untagged());
  if (count == array_capacity(contents.untagged())) {
    contents.set_untagged(reallot_array(contents.untagged(), 2 * count));
    set_array_nth(growarr.untagged(), 1, contents.value());
  }
  set_array_nth(contents.untagged(), count, elt.value());
  set_array_nth(growarr.untagged(), 0, tag_fixnum(count + 1));
}

profiling_sample profiling_sample::record_counts() volatile {
  atomic::fence();
  profiling_sample returned(sample_count, gc_sample_count,
                            jit_sample_count, foreign_sample_count,
                            foreign_thread_sample_count);
  atomic::fetch_subtract(&sample_count, returned.sample_count);
  atomic::fetch_subtract(&gc_sample_count, returned.gc_sample_count);
  atomic::fetch_subtract(&jit_sample_count, returned.jit_sample_count);
  atomic::fetch_subtract(&foreign_sample_count, returned.foreign_sample_count);
  atomic::fetch_subtract(&foreign_thread_sample_count,
                         returned.foreign_thread_sample_count);
  return returned;
}

void profiling_sample::clear_counts() volatile {
  sample_count = 0;
  gc_sample_count = 0;
  jit_sample_count = 0;
  foreign_sample_count = 0;
  foreign_thread_sample_count = 0;
  atomic::fence();
}

// Allocates memory
void factor_vm::record_sample(bool prolog_p) {
  profiling_sample result = current_sample.record_counts();
  if (result.empty()) {
    return;
  }
  // Appends the callstack, which is just a sequence of quotation or
  // word references, to sample_callstacks.
  cell callstacks_cell = special_objects[OBJ_SAMPLE_CALLSTACKS];
  data_root<array> callstacks = data_root<array>(callstacks_cell, this);
  cell begin = growarr_capacity(callstacks.untagged());

  bool skip_p = prolog_p;
  auto recorder = [&](cell frame_top, cell size, code_block* owner, cell addr) {
    (void)frame_top;
    (void)size;
    (void)addr;
    if (skip_p)
      skip_p = false;
    else {
      growarr_add(callstacks.untagged(), owner->owner);
    }
  };
  iterate_callstack(ctx, recorder);
  cell end = growarr_capacity(callstacks.untagged());

  // Add the sample.
  result.thread = special_objects[OBJ_CURRENT_THREAD];
  result.callstack_begin = begin;
  result.callstack_end = end;
  samples.push_back(result);
}

// Allocates memory
void factor_vm::set_profiling(fixnum rate) {
  bool running_p = atomic::load(&sampling_profiler_p);
  if (rate > 0 && !running_p)
    start_sampling_profiler(rate);
  else if (rate == 0 && running_p)
    end_sampling_profiler();
}

// Allocates memory
void factor_vm::start_sampling_profiler(fixnum rate) {
  special_objects[OBJ_SAMPLE_CALLSTACKS] = tag<array>(allot_growarr());
  samples_per_second = rate;
  current_sample.clear_counts();
  // Release the memory consumed by collecting samples.
  samples.clear();
  samples.shrink_to_fit();
  samples.reserve(10 * rate);
  atomic::store(&sampling_profiler_p, true);
  start_sampling_profiler_timer();
}

void factor_vm::end_sampling_profiler() {
  atomic::store(&sampling_profiler_p, false);
  end_sampling_profiler_timer();
  record_sample(false);
}

// Allocates memory
void factor_vm::primitive_set_profiling() {
  set_profiling(to_fixnum(ctx->pop()));
}

// Allocates memory
void factor_vm::primitive_get_samples() {
  if (atomic::load(&sampling_profiler_p) || samples.empty()) {
    ctx->push(false_object);
    return;
  }
  data_root<array> samples_array(allot_array(samples.size(), false_object),
                                 this);
  std::vector<profiling_sample>::const_iterator from_iter = samples.begin();
  cell to_i = 0;

  cell callstacks_cell = special_objects[OBJ_SAMPLE_CALLSTACKS];
  data_root<array> callstacks = data_root<array>(callstacks_cell, this);

  for (; from_iter != samples.end(); ++from_iter, ++to_i) {
    data_root<array> sample(allot_array(7, false_object), this);

    set_array_nth(sample.untagged(), 0,
                  tag_fixnum(from_iter->sample_count));
    set_array_nth(sample.untagged(), 1,
                  tag_fixnum(from_iter->gc_sample_count));
    set_array_nth(sample.untagged(), 2,
                  tag_fixnum(from_iter->jit_sample_count));
    set_array_nth(sample.untagged(), 3,
                  tag_fixnum(from_iter->foreign_sample_count));
    set_array_nth(sample.untagged(), 4,
                  tag_fixnum(from_iter->foreign_thread_sample_count));

    set_array_nth(sample.untagged(), 5, from_iter->thread);

    cell callstack_size =
        from_iter->callstack_end - from_iter->callstack_begin;
    data_root<array> callstack(allot_array(callstack_size, false_object),
                               this);

    for (cell i = 0; i < callstack_size; i++) {
      cell block_owner = growarr_nth(callstacks.untagged(),
                                     from_iter->callstack_begin + i);
      set_array_nth(callstack.untagged(), i, block_owner);
    }
    set_array_nth(sample.untagged(), 6, callstack.value());
    set_array_nth(samples_array.untagged(), to_i, sample.value());
  }
  ctx->push(samples_array.value());
}

}
