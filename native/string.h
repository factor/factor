typedef struct {
	CELL header;
	/* untagged */
	CELL capacity;
	/* untagged */
	FIXNUM hashcode;
} STRING;

INLINE STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return (STRING*)UNTAG(tagged);
}

STRING* allot_string(FIXNUM capacity);
STRING* string(FIXNUM capacity, CELL fill);
FIXNUM hash_string(STRING* str, FIXNUM len);
void rehash_string(STRING* str);
STRING* grow_string(STRING* string, FIXNUM capacity, CHAR fill);
BYTE* to_c_string(STRING* s);
void box_c_string(const BYTE* c_string);
STRING* from_c_string(const BYTE* c_string);
BYTE* unbox_c_string(void);

#define SREF(string,index) ((CELL)string + sizeof(STRING) + index * CHARS)

#define SSIZE(pointer) align8(sizeof(STRING) + \
	((STRING*)pointer)->capacity * CHARS)

/* untagged & unchecked */
INLINE CELL string_nth(STRING* string, CELL index)
{
	return cget(SREF(string,index));
}

/* untagged & unchecked */
INLINE void set_string_nth(STRING* string, CELL index, CHAR value)
{
	cput(SREF(string,index),value);
}

void primitive_string_length(void);
void primitive_string_nth(void);
FIXNUM string_compare_head(STRING* s1, STRING* s2, CELL len);
FIXNUM string_compare(STRING* s1, STRING* s2);
void primitive_string_compare(void);
void primitive_string_eq(void);
void primitive_string_hashcode(void);
void primitive_index_of(void);
void primitive_substring(void);
void string_reverse(STRING* s, int len);
STRING* string_clone(STRING* s, int len);
void primitive_string_reverse(void);
STRING* fixup_untagged_string(STRING* str);
STRING* copy_untagged_string(STRING* str);
