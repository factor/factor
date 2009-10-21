namespace factor
{

struct to_tenured_policy {
	factor_vm *myvm;
	tenured_space *tenured;

	to_tenured_policy(factor_vm *myvm_) : myvm(myvm_), tenured(myvm->data->tenured) {}

	bool should_copy_p(object *untagged)
	{
		return !tenured->contains_p(untagged);
	}

	void promoted_object(object *obj)
	{
		tenured->mark_stack.push_back(obj);
	}

	void visited_object(object *obj) {}
};

struct to_tenured_collector : collector<tenured_space,to_tenured_policy> {
	to_tenured_collector(factor_vm *myvm_);
	void tenure_reachable_objects();
};

}
