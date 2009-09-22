namespace factor
{

template<typename T> cell array_capacity(T *array)
{
#ifdef FACTOR_DEBUG
	assert(array->h.hi_tag() == T::type_number);
#endif
	return array->capacity >> TAG_BITS;
}

template <typename T> cell array_size(cell capacity)
{
	return sizeof(T) + capacity * T::element_size;
}

template <typename T> cell array_size(T *array)
{
	return array_size<T>(array_capacity(array));
}

}
