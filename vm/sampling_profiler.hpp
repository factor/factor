namespace factor {

struct profiling_sample {
  // Active thread during sample
  cell thread;
  // The callstack at safepoint time. Indexes to the beginning and ending
  // word entries in the vm sample_callstacks array.
  cell callstack_begin, callstack_end;

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

  profiling_sample(fixnum sample_count_, fixnum gc_sample_count_,
                   fixnum jit_sample_count_, fixnum foreign_sample_count_,
                   fixnum foreign_thread_sample_count_)
      : thread(0),
        callstack_begin(0),
        callstack_end(0),
        sample_count(sample_count_),
        gc_sample_count(gc_sample_count_),
        jit_sample_count(jit_sample_count_),
        foreign_sample_count(foreign_sample_count_),
        foreign_thread_sample_count(foreign_thread_sample_count_) {}

  profiling_sample record_counts() volatile;
  void clear_counts() volatile;
  bool empty() const {
    return sample_count + gc_sample_count + jit_sample_count +
               foreign_sample_count + foreign_thread_sample_count ==
           0;
  }
};

}
