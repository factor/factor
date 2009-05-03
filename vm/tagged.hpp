template <typename T> CELL tag(T *value)
{
	if(T::type_number < HEADER_TYPE)
		return RETAG(value,T::type_number);
	else
		return RETAG(value,OBJECT_TYPE);
}

template <typename T>
struct tagged
{
	CELL value_;

	T *untag_check() const {
		if(T::type_number != TYPE_COUNT)
			type_check(T::type_number,value_);
		return untagged();
	}
	
	explicit tagged(CELL tagged) : value_(tagged) {
#ifdef FACTOR_DEBUG
		untag_check();
#endif
	}

	explicit tagged(T *untagged) : value_(::tag(untagged)) {
#ifdef FACTOR_DEBUG
		untag_check();
#endif		
	}

	CELL value() const { return value_; }
	T *untagged() const { return (T *)(UNTAG(value_)); }

	T *operator->() const { return untagged(); }
	CELL *operator&() const { return &value_; }

	const tagged<T>& operator=(const T *x) { value_ = tag(x); return *this; }
	const tagged<T>& operator=(const CELL &x) { value_ = x; return *this; }

	CELL type() const { return type_of(value_); }
	bool isa(CELL type_) const { return type() == type_; }

	template<typename X> tagged<X> as() { return tagged<X>(value_); }
};

template <typename T> T *untag_check(CELL value)
{
	return tagged<T>(value).untag_check();
}

template <typename T> T *untag(CELL value)
{
	return tagged<T>(value).untagged();
}
