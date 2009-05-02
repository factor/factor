template <typename T> CELL tag(T *value)
{
	if(T::type_number < HEADER_TYPE)
		return RETAG(value,T::type_number);
	else
		return RETAG(value,OBJECT_TYPE);
}

template <typename T>
class tagged
{
	CELL value;
public:
	explicit tagged(CELL tagged) : value(tagged) {}
	explicit tagged(T *untagged) : value(::tag(untagged)) {}

	CELL tag() const { return value; }
	T *untag() const { type_check(T::type_number,value); }
	T *untag_fast() const { return (T *)(UNTAG(value)); }
	T *operator->() const { return untag_fast(); }
	CELL *operator&() const { return &value; }
};

template <typename T> T *untag(CELL value)
{
	return tagged<T>(value).untag();
}

template <typename T> T *untag_fast(CELL value)
{
	return tagged<T>(value).untag_fast();
}
