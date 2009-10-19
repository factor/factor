namespace factor
{

struct nursery_policy {
	factor_vm *parent;

	nursery_policy(factor_vm *parent_) : parent(parent_) {}

	bool should_copy_p(object *untagged)
	{
		return parent->nursery.contains_p(untagged);
	}
};

struct nursery_collector : copying_collector<aging_space,nursery_policy> {
	nursery_collector(factor_vm *parent_);
};

}
