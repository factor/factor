namespace factor {

template <typename Type> cell tag(Type* value) {
  return RETAG(value, Type::type_number);
}

inline cell tag_dynamic(const object* value) {
  return RETAG(value, value->type());
}

template <typename Type> struct tagged {
  cell value_;

  cell type() const { return TAG(value_); }

  bool type_p() const {
    if (Type::type_number == TYPE_COUNT)
      return true;
    return type() == Type::type_number;
  }

  cell value() const {
    FACTOR_ASSERT(type_p());
    return value_;
  }

  Type* untagged() const {
    FACTOR_ASSERT(type_p());
    return reinterpret_cast<Type*>(UNTAG(value_));
  }

  explicit tagged(cell tag_val) : value_(tag_val) {}
  explicit tagged(Type* untagged) : value_(factor::tag(untagged)) {}

  void set_value(const cell ptr) {
    value_ = ptr;
  }

  void set_untagged(const Type *untagged) {
    set_value(tag(untagged));
  }

  Type* operator->() const { return untagged(); }
  cell* operator&() const { return &value(); }

  bool operator==(const tagged<Type>& x) { return value_ == x.value_; }
  bool operator!=(const tagged<Type>& x) { return value_ != x.value_; }

  template <typename NewType> tagged<NewType> as() {
    return tagged<NewType>(value_);
  }
};

template <typename Type> Type* untag(cell value) {
  return tagged<Type>(value).untagged();
}

}
