namespace factor
{

struct safepoint_state
{
	factor_vm *parent;

	cell fep_p;
	cell queued_signal;
	profiling_sample_count sample_counts;

	safepoint_state(factor_vm *parent) :
		parent(parent),
		fep_p(false),
		queued_signal(0),
		sample_counts()
	{
	}

	void handle_safepoint() volatile;

	void enqueue_safepoint() volatile;
	void enqueue_samples(cell samples, cell pc, bool foreign_thread_p) volatile;
	void enqueue_fep() volatile;

	// os-*.cpp
	void enqueue_signal(cell signal) volatile;
	void report_signal(int fd) volatile;

};

}
