namespace factor
{

inline static CELL string_capacity(F_STRING *str)
{
	return untag_fixnum(str->length);
}

inline static CELL string_size(CELL size)
{
	return sizeof(F_STRING) + size;
}

F_STRING* allot_string_internal(CELL capacity);
F_STRING* allot_string(CELL capacity, CELL fill);
PRIMITIVE(string);
F_STRING *reallot_string(F_STRING *string, CELL capacity);
PRIMITIVE(resize_string);

/* String getters and setters */
CELL string_nth(F_STRING* string, CELL index);
void set_string_nth(F_STRING* string, CELL index, CELL value);

PRIMITIVE(string_nth);
PRIMITIVE(set_string_nth_slow);
PRIMITIVE(set_string_nth_fast);

}
