namespace factor
{

struct aging_policy {
	factor_vm *myvm;
	zone *aging, *tenured;

	aging_policy(factor_vm *myvm_) :
		myvm(myvm_),
		aging(myvm->data->aging),
		tenured(myvm->data->tenured) {}

	bool should_copy_p(object *untagged)
	{
		return !(aging->contains_p(untagged) || tenured->contains_p(untagged));
	}
};

struct aging_collector : copying_collector<aging_space,aging_policy> {
	aging_collector(factor_vm *myvm_);
	void go();
};

}
