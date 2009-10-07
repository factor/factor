namespace factor
{

struct to_tenured_policy {
	factor_vm *myvm;
	zone *tenured;

	to_tenured_policy(factor_vm *myvm_) : myvm(myvm_), tenured(myvm->data->tenured) {}

	bool should_copy_p(object *untagged)
	{
		return !tenured->contains_p(untagged);
	}
};

struct to_tenured_collector : copying_collector<tenured_space,to_tenured_policy> {
	to_tenured_collector(factor_vm *myvm_);
	void go();
};

}
