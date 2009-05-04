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

template <typename T> T *allot_array_internal(cell capacity)
{
	T *array = allot<T>(array_size<T>(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

template <typename T> bool reallot_array_in_place_p(T *array, cell capacity)
{
	return in_zone(&nursery,array) && capacity <= array_capacity(array);
}

template <typename T> T *reallot_array(T *array_, cell capacity)
{
	gc_root<T> array(array_);

	if(reallot_array_in_place_p(array.untagged(),capacity))
	{
		array->capacity = tag_fixnum(capacity);
		return array.untagged();
	}
	else
	{
		cell to_copy = array_capacity(array.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		T *new_array = allot_array_internal<T>(capacity);
	
		memcpy(new_array + 1,array.untagged() + 1,to_copy * T::element_size);
		memset((char *)(new_array + 1) + to_copy * T::element_size,
			0,(capacity - to_copy) * T::element_size);

		return new_array;
	}
}

}
