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

template <typename TYPE> TYPE *factorvm::reallot_array(TYPE *array_, cell capacity)
{
	gc_root<TYPE> array(array_,this);

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

		TYPE *new_array = allot_array_internal<TYPE>(capacity);
	
		memcpy(new_array + 1,array.untagged() + 1,to_copy * TYPE::element_size);
		memset((char *)(new_array + 1) + to_copy * TYPE::element_size,
			0,(capacity - to_copy) * TYPE::element_size);

		return new_array;
	}
}

}
