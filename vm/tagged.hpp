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
}
