namespace factor
{

template<typename Type> cell tag(Type *value)
{
	return RETAG(value,Type::type_number);
}

inline static cell tag_dynamic(object *value)
{
	return RETAG(value,value->h.hi_tag());
}

template<typename Type>
struct tagged
{
	cell value_;

	cell type() const {
		return TAG(value_);
	}

	bool type_p(cell type_) const
	{
		return type() == type_;
	}

	bool type_p() const
	{
		if(Type::type_number == TYPE_COUNT)
			return true;
		else
			return type_p(Type::type_number);
	}

	cell value() const {
#ifdef FACTOR_DEBUG
		assert(type_p());
#endif
		return value_;
	}
	Type *untagged() const {
#ifdef FACTOR_DEBUG
		assert(type_p());
#endif
		return (Type *)(UNTAG(value_));
	}

	Type *untag_check(factor_vm *parent) const {
		if(!type_p())
			parent->type_error(Type::type_number,value_);
		return untagged();
	}

	explicit tagged(cell tagged) : value_(tagged) {}
	explicit tagged(Type *untagged) : value_(factor::tag(untagged)) {}

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

template<typename Type> Type *untag(cell value)
{
	return tagged<Type>(value).untagged();
}

}
