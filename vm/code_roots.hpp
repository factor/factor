#include <algorithm>

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
    auto& roots = parent->code_roots;
    // Find and swap with the last element, then pop_back
    // This avoids the expensive erase from middle of vector
    auto iter = std::find(roots.begin(), roots.end(), this);
    if (iter != roots.end()) {
      if (iter != roots.end() - 1) {
        std::swap(*iter, roots.back());
      }
      roots.pop_back();
    }
  }

  // Disable copy operations to prevent double-free
  code_root(const code_root&) = delete;
  code_root& operator=(const code_root&) = delete;
  
  // Move operations could be implemented if needed
  code_root(code_root&&) = delete;
  code_root& operator=(code_root&&) = delete;
};

}
