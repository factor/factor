namespace factor {

struct code_root {
  cell value;
  bool valid;
  factor_vm* parent;

  void push() { parent->code_roots.push_back(this); }

  code_root(cell val, factor_vm* vm)
      : value(val), valid(true), parent(vm) {
    push();
  }

  ~code_root() {
    parent->code_roots.remove(this);
  }

  // Disable copy operations to prevent double-free
  code_root(const code_root&) = delete;
  code_root& operator=(const code_root&) = delete;
  
  // Move operations could be implemented if needed
  code_root(code_root&&) = delete;
  code_root& operator=(code_root&&) = delete;
};

}
