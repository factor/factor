namespace factor {

struct nursery_policy {
  factor_vm* parent;

  explicit nursery_policy(factor_vm* parent) : parent(parent) {}

  bool should_copy_p(object* obj) {
    return parent->data->nursery->contains_p(obj);
  }

  void promoted_object(object* obj) {}

  void visited_object(object* obj) {}
};

struct nursery_collector : copying_collector<aging_space, nursery_policy> {
  explicit nursery_collector(factor_vm* parent);
};

}
