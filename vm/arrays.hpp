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





array *allot_array(cell capacity, cell fill);

cell allot_array_1(cell obj);
cell allot_array_2(cell v1, cell v2);
cell allot_array_4(cell v1, cell v2, cell v3, cell v4);

PRIMITIVE(array);
PRIMITIVE(resize_array);


}
