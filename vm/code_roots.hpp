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
    FACTOR_ASSERT(parent->code_roots.back() == this);
    parent->code_roots.pop_back();
  }

  // Disable copy operations to prevent double-free
  code_root(const code_root&) = delete;
  code_root& operator=(const code_root&) = delete;
  
  // Move operations could be implemented if needed
  code_root(code_root&&) = delete;
  code_root& operator=(code_root&&) = delete;
};

}
