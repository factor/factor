namespace factor {

struct safepoint_state {
  cell fep_p;
  profiling_sample_count sample_counts;

  safepoint_state() : fep_p(false), sample_counts() {}

  void handle_safepoint(factor_vm* parent, cell pc) volatile;

  void enqueue_samples(factor_vm* parent, cell samples, cell pc,
                       bool foreign_thread_p) volatile;
  void enqueue_fep(factor_vm* parent) volatile;
};

}
