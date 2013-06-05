namespace factor {

struct code_root {
  cell value;
  bool valid;
  factor_vm* parent;

  void push() { parent->code_roots.push_back(this); }

  code_root(cell value, factor_vm* parent)
      : value(value), valid(true), parent(parent) {
    push();
  }

  ~code_root() {
#ifdef FACTOR_DEBUG
    FACTOR_ASSERT(parent->code_roots.back() == this);
#endif
    parent->code_roots.pop_back();
  }
};

}
