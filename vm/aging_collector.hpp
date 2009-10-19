namespace factor
{

struct aging_policy {
	factor_vm *parent;
	zone *aging, *tenured;

	aging_policy(factor_vm *parent_) :
		parent(parent_),
		aging(parent->data->aging),
		tenured(parent->data->tenured) {}

	bool should_copy_p(object *untagged)
	{
		return !(aging->contains_p(untagged) || tenured->contains_p(untagged));
	}
};

struct aging_collector : copying_collector<aging_space,aging_policy> {
	aging_collector(factor_vm *parent_);
};

}
