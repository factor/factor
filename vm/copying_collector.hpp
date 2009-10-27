namespace factor
{

struct dummy_unmarker {
	void operator()(card *ptr) {}
};

struct simple_unmarker {
	card unmask;
	explicit simple_unmarker(card unmask_) : unmask(unmask_) {}
	void operator()(card *ptr) { *ptr &= ~unmask; }
};

template<typename TargetGeneration, typename Policy>
struct copying_collector : collector<TargetGeneration,Policy> {
	cell scan;

	explicit copying_collector(factor_vm *parent_, TargetGeneration *target_, Policy policy_) :
		collector<TargetGeneration,Policy>(parent_,target_,policy_), scan(target_->here) {}

	void cheneys_algorithm()
	{
		while(scan && scan < this->target->here)
		{
			this->trace_slots((object *)scan);
			scan = this->target->next_object_after(scan);
		}
	}
};

}
