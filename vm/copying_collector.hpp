namespace factor
{

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
