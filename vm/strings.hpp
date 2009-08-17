namespace factor
{

inline static cell string_capacity(string *str)
{
	return untag_fixnum(str->length);
}

inline static cell string_size(cell size)
{
	return sizeof(string) + size;
}

PRIMITIVE(string);
PRIMITIVE(resize_string);

PRIMITIVE(string_nth);
PRIMITIVE(set_string_nth_slow);
PRIMITIVE(set_string_nth_fast);

}
