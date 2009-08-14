namespace factor
{

template <typename T> cell tag(T *value)
{
	return RETAG(value,tag_for(T::type_number));
}

inline static cell tag_dynamic(object *value)
{
	return RETAG(value,tag_for(value->h.hi_tag()));
}

template <typename T>
struct tagged
{
	cell value_;

	cell value() const { return value_; }
	T *untagged() const { return (T *)(UNTAG(value_)); }

	cell type() const {
		cell tag = TAG(value_);
		if(tag == OBJECT_TYPE)
			return untagged()->h.hi_tag();
		else
			return tag;
	}

	bool type_p(cell type_) const { return type() == type_; }

	T *untag_check() const {
		if(T::type_number != TYPE_COUNT && !type_p(T::type_number))
			type_error(T::type_number,value_);
		return untagged();
	}

	explicit tagged(cell tagged) : value_(tagged) {
#ifdef FACTOR_DEBUG
		untag_check();
#endif
	}

	explicit tagged(T *untagged) : value_(factor::tag(untagged)) {
#ifdef FACTOR_DEBUG
		untag_check();
#endif
	}

	T *operator->() const { return untagged(); }
	cell *operator&() const { return &value_; }

	const tagged<T>& operator=(const T *x) { value_ = tag(x); return *this; }
	const tagged<T>& operator=(const cell &x) { value_ = x; return *this; }

	bool operator==(const tagged<T> &x) { return value_ == x.value_; }
	bool operator!=(const tagged<T> &x) { return value_ != x.value_; }

	template<typename X> tagged<X> as() { return tagged<X>(value_); }
};

template <typename T> T *untag_check(cell value)
{
	return tagged<T>(value).untag_check();
}

template <typename T> T *untag(cell value)
{
	return tagged<T>(value).untagged();
}

}
