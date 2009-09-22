namespace factor
{

template <typename TYPE> cell tag(TYPE *value)
{
	return RETAG(value,tag_for(TYPE::type_number));
}

inline static cell tag_dynamic(object *value)
{
	return RETAG(value,tag_for(value->h.hi_tag()));
}

template <typename TYPE>
struct tagged
{
	cell value_;

	cell value() const { return value_; }
	TYPE *untagged() const { return (TYPE *)(UNTAG(value_)); }

	cell type() const {
		cell tag = TAG(value_);
		if(tag == OBJECT_TYPE)
			return untagged()->h.hi_tag();
		else
			return tag;
	}

	bool type_p(cell type_) const { return type() == type_; }

	TYPE *untag_check(factorvm *myvm) const {
		if(TYPE::type_number != TYPE_COUNT && !type_p(TYPE::type_number))
			myvm->type_error(TYPE::type_number,value_);
		return untagged();
	}

	explicit tagged(cell tagged) : value_(tagged) {
#ifdef FACTOR_DEBUG
		untag_check(SIGNAL_VM_PTR());
#endif
	}

	explicit tagged(TYPE *untagged) : value_(factor::tag(untagged)) {
#ifdef FACTOR_DEBUG
		untag_check(SIGNAL_VM_PTR()); 
#endif
	}

	TYPE *operator->() const { return untagged(); }
	cell *operator&() const { return &value_; }

	const tagged<TYPE>& operator=(const TYPE *x) { value_ = tag(x); return *this; }
	const tagged<TYPE>& operator=(const cell &x) { value_ = x; return *this; }

	bool operator==(const tagged<TYPE> &x) { return value_ == x.value_; }
	bool operator!=(const tagged<TYPE> &x) { return value_ != x.value_; }

	template<typename X> tagged<X> as() { return tagged<X>(value_); }
};

template <typename TYPE> TYPE *factorvm::untag_check(cell value)
{
	return tagged<TYPE>(value).untag_check(this);
}

template <typename TYPE> TYPE *factorvm::untag(cell value)
{
	return tagged<TYPE>(value).untagged();
}

}
