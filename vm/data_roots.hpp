namespace factor {

template <typename Type> struct data_root : public tagged<Type> {
  factor_vm* parent;

  void push() {
    parent->data_roots.push_back(&this->value_);
  }

  data_root(cell value, factor_vm* parent)
      : tagged<Type>(value), parent(parent) {
    push();
  }

  data_root(Type* value, factor_vm* parent)
      : tagged<Type>(value), parent(parent) {
    FACTOR_ASSERT(value);
    push();
  }

  ~data_root() {
    parent->data_roots.pop_back();
  }

  data_root(const data_root&) = delete;

  data_root& operator=(const data_root& other) {
    // Just update the value, the GC root registration stays the same
    this->value_ = other.value_;
    return *this;
  }

  friend void swap(data_root<Type>& a, data_root<Type>& b) {
    cell tmp = a.value_;
    a.value_ = b.value_;
    b.value_ = tmp;
  }
};

}
