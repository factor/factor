namespace factor {

template <typename Type> struct data_root : public tagged<Type> {
  factor_vm* parent;

  void push() {
    parent->data_roots.push_back(&this->value_);
  }

  data_root(cell value, factor_vm* parent_)
      : tagged<Type>(value), parent(parent_) {
    push();
  }

  data_root(Type* value, factor_vm* parent_)
      : tagged<Type>(value), parent(parent_) {
    FACTOR_ASSERT(value);
    push();
  }

  ~data_root() {
    parent->data_roots.pop_back();
  }

  // Disable copy operations to prevent double-free
  data_root(const data_root&) = delete;
  data_root& operator=(const data_root&) = delete;
  
  // Move operations could be implemented if needed
  data_root(data_root&&) = delete;
  data_root& operator=(data_root&&) = delete;

  friend void swap(data_root<Type>& a, data_root<Type>& b) {
    cell tmp = a.value_;
    a.value_ = b.value_;
    b.value_ = tmp;
  }
};

}
