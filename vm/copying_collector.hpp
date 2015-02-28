namespace factor {

template <typename TargetGeneration, typename Policy>
struct copying_collector : collector<TargetGeneration, Policy> {
  cell scan;

  copying_collector(factor_vm* parent, TargetGeneration* target,
                    Policy policy)
      : collector<TargetGeneration, Policy>(parent, target, policy),
        scan(target->here) {}

  void cheneys_algorithm() {
    while (scan && scan < this->target->here) {
      this->visitor.visit_object((object*)scan);
      scan = this->target->next_object_after(scan);
    }
  }
};

}
