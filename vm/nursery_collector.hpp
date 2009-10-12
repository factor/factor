namespace factor
{

struct nursery_policy {
	factor_vm *myvm;

	nursery_policy(factor_vm *myvm_) : myvm(myvm_) {}

	bool should_copy_p(object *untagged)
	{
		return myvm->nursery.contains_p(untagged);
	}
};

struct nursery_collector : copying_collector<aging_space,nursery_policy> {
	nursery_collector(factor_vm *myvm_);
};

}
