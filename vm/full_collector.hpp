namespace factor {

struct full_policy {
  factor_vm* parent;
  tenured_space* tenured;

  explicit full_policy(factor_vm* parent)
      : parent(parent), tenured(parent->data->tenured) {}

  bool should_copy_p(object* untagged) {
    return !tenured->contains_p(untagged);
  }

  void promoted_object(object* obj) {
    tenured->set_marked_p(obj);
    parent->mark_stack.push_back((cell)obj);
  }

  void visited_object(object* obj) {
    if (!tenured->marked_p(obj))
      promoted_object(obj);
  }
};

struct full_collector : collector<tenured_space, full_policy> {
  code_block_visitor<gc_workhorse<tenured_space, full_policy> > code_visitor;

  explicit full_collector(factor_vm* parent);
  void trace_code_block(code_block* compiled);
};

}
