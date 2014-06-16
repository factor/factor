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
    push();
  }

  const data_root<Type>& operator=(const Type* x) {
    tagged<Type>::operator=(x);
    return *this;
  }
  const data_root<Type>& operator=(const cell& x) {
    tagged<Type>::operator=(x);
    return *this;
  }

  ~data_root() {
    parent->data_roots.pop_back();
  }

  friend void swap(data_root<Type>& a, data_root<Type>& b) {
    cell tmp = a.value_;
    a.value_ = b.value_;
    b.value_ = tmp;
  }
};

/* A similar hack for the bignum implementation */
struct gc_bignum {
  bignum** addr;
  factor_vm* parent;

  gc_bignum(bignum** addr, factor_vm* parent) : addr(addr), parent(parent) {
    /* Don't bother with variables holding NULL pointers. */
    if (*addr) {
      parent->check_data_pointer(*addr);
      parent->bignum_roots.push_back(addr);
    }
  }

  ~gc_bignum() {
    if (*addr) {
      FACTOR_ASSERT(parent->bignum_roots.back() == addr);
      parent->bignum_roots.pop_back();
    }
  }
};

#define GC_BIGNUM(x) gc_bignum x##__data_root(&x, this)

}
