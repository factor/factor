namespace factor
{

struct safepoint_state
{
	factor_vm *parent;

	cell fep_p;
	profiling_sample_count sample_counts;

	safepoint_state(factor_vm *parent) :
		parent(parent),
		fep_p(false),
		sample_counts()
	{
	}

	void handle_safepoint() volatile;

	void enqueue_safepoint() volatile;
	void enqueue_samples(cell samples, cell pc, bool foreign_thread_p) volatile;
	void enqueue_fep() volatile;
};

}
