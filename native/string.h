typedef struct {
	CELL header;
	/* untagged num of chars */
	CELL capacity;
	/* tagged */
	CELL hashcode;
} F_STRING;

#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + index * CHARS)

#define SSIZE(pointer) align8(sizeof(F_STRING) + \
	(((F_STRING*)pointer)->capacity + 1) * CHARS)

INLINE F_STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return (F_STRING*)UNTAG(tagged);
}

F_STRING* allot_string(CELL capacity);
F_STRING* string(CELL capacity, CELL fill);
F_FIXNUM hash_string(F_STRING* str, CELL len);
void rehash_string(F_STRING* str);
F_STRING* grow_string(F_STRING* string, F_FIXNUM capacity, uint16_t fill);
BYTE* to_c_string(F_STRING* s);
BYTE* to_c_string_unchecked(F_STRING* s);
void primitive_string_to_memory(void);
DLLEXPORT void box_c_string(const BYTE* c_string);
F_STRING* from_c_string(const BYTE* c_string);
void primitive_memory_to_string(void);
DLLEXPORT BYTE* unbox_c_string(void);
DLLEXPORT uint16_t* unbox_utf16_string(void);

/* untagged & unchecked */
INLINE CELL string_nth(F_STRING* string, CELL index)
{
	return cget(SREF(string,index));
}

/* untagged & unchecked */
INLINE void set_string_nth(F_STRING* string, CELL index, uint16_t value)
{
	cput(SREF(string,index),value);
}

void primitive_string_nth(void);
F_FIXNUM string_compare_head(F_STRING* s1, F_STRING* s2, CELL len);
F_FIXNUM string_compare(F_STRING* s1, F_STRING* s2);
void primitive_string_compare(void);
void primitive_string_eq(void);
void primitive_index_of(void);
void primitive_substring(void);
void string_reverse(F_STRING* s, int len);
F_STRING* string_clone(F_STRING* s, int len);
void primitive_string_reverse(void);
void primitive_to_string(void);
