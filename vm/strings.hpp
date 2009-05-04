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

string* allot_string_internal(cell capacity);
string* allot_string(cell capacity, cell fill);
PRIMITIVE(string);
string *reallot_string(string *string, cell capacity);
PRIMITIVE(resize_string);

/* String getters and setters */
cell string_nth(string* string, cell index);
void set_string_nth(string* string, cell index, cell value);

PRIMITIVE(string_nth);
PRIMITIVE(set_string_nth_slow);
PRIMITIVE(set_string_nth_fast);

}
