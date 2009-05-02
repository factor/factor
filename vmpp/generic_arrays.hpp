template<typename T> CELL array_capacity(T *array)
{
#ifdef FACTOR_DEBUG
	CELL header = untag_header(array->header);
	assert(header == T::type_number);
#endif
	return array->capacity >> TAG_BITS;
}

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)
#define UNAREF(array,ptr) (((CELL)(ptr)-(CELL)(array)-sizeof(F_ARRAY)) / CELLS)

template <typename T> CELL array_nth(T *array, CELL slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity<T>(array));
	assert(untag_header(array->header) == T::type_number);
#endif
	return get(AREF(array,slot));
}

template <typename T> void set_array_nth(T *array, CELL slot, CELL value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity<T>(array));
	assert(untag_header(array->header) == T::type_number);
#endif
	put(AREF(array,slot),value);
	write_barrier((CELL)array);
}

template <typename T> CELL array_size(CELL capacity)
{
	return sizeof(T) + capacity * T::element_size;
}

template <typename T> CELL array_size(T *array)
{
	return array_size<T>(array_capacity(array));
}

template <typename T> T *allot_array_internal(CELL capacity)
{
	T *array = allot<T>(array_size<T>(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

template <typename T> bool reallot_array_in_place_p(T *array, CELL capacity)
{
	return in_zone(&nursery,(CELL)array) && capacity <= array_capacity(array);
}

template <typename T> T *reallot_array(T *array_, CELL capacity)
{
	gc_root<T> array(array_);

	if(reallot_array_in_place_p(array.untagged(),capacity))
	{
		array->capacity = tag_fixnum(capacity);
		return array.untagged();
	}
	else
	{
		CELL to_copy = array_capacity(array.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		T *new_array = allot_array_internal<T>(capacity);
	
		memcpy(new_array + 1,array.untagged() + 1,to_copy * T::element_size);
		memset((char *)(new_array + 1) + to_copy * T::element_size,
			0,(capacity - to_copy) * T::element_size);

		return new_array;
	}
}
