namespace factor
{

template<typename Type> cell tag(Type *value)
{
	return RETAG(value,tag_for(Type::type_number));
}

inline static cell tag_dynamic(object *value)
{
	return RETAG(value,tag_for(value->h.hi_tag()));
}

template<typename Type>
struct tagged
{
	cell value_;

	cell value() const { return value_; }
	Type *untagged() const { return (Type *)(UNTAG(value_)); }

	cell type() const {
		cell tag = TAG(value_);
		if(tag == OBJECT_TYPE)
			return untagged()->h.hi_tag();
		else
			return tag;
	}

	bool type_p(cell type_) const { return type() == type_; }

	Type *untag_check(factor_vm *myvm) const {
		if(Type::type_number != TYPE_COUNT && !type_p(Type::type_number))
			myvm->type_error(Type::type_number,value_);
		return untagged();
	}

	explicit tagged(cell tagged) : value_(tagged) {
#ifdef FACTOR_DEBUG
		untag_check(SIGNAL_VM_PTR());
#endif
	}

	explicit tagged(Type *untagged) : value_(factor::tag(untagged)) {
#ifdef FACTOR_DEBUG
		untag_check(SIGNAL_VM_PTR()); 
#endif
	}

	Type *operator->() const { return untagged(); }
	cell *operator&() const { return &value_; }

	const tagged<Type> &operator=(const Type *x) { value_ = tag(x); return *this; }
	const tagged<Type> &operator=(const cell &x) { value_ = x; return *this; }

	bool operator==(const tagged<Type> &x) { return value_ == x.value_; }
	bool operator!=(const tagged<Type> &x) { return value_ != x.value_; }

	template<typename NewType> tagged<NewType> as() { return tagged<NewType>(value_); }
};

template<typename Type> Type *factor_vm::untag_check(cell value)
{
	return tagged<Type>(value).untag_check(this);
}

template<typename Type> Type *factor_vm::untag(cell value)
{
	return tagged<Type>(value).untagged();
}

}
