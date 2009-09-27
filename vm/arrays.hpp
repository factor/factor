namespace factor
{

inline cell array_nth(array *array, cell slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
#endif
	return array->data()[slot];
}

}
