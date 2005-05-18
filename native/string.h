typedef struct {
	CELL header;
	/* tagged num of chars */
	CELL length;
	/* tagged */
	CELL hashcode;
} F_STRING;

#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + index * CHARS)

INLINE F_STRING* untag_string_fast(CELL tagged)
{
	return (F_STRING*)UNTAG(tagged);
}

INLINE F_STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return untag_string_fast(tagged);
}

INLINE CELL string_capacity(F_STRING* str)
{
	return untag_fixnum_fast(str->length);
}

#define SSIZE(pointer) align8(sizeof(F_STRING) + \
	(string_capacity((F_STRING*)(pointer)) + 1) * CHARS)

F_STRING* allot_string(CELL capacity);
F_STRING* string(CELL capacity, CELL fill);
void rehash_string(F_STRING* str);
void primitive_rehash_string(void);
F_STRING* grow_string(F_STRING* string, F_FIXNUM capacity, u16 fill);
void primitive_grow_string(void);
char* to_c_string(F_STRING* s);
char* to_c_string_unchecked(F_STRING* s);
void string_to_memory(F_STRING* s, BYTE* string);
void primitive_string_to_memory(void);
DLLEXPORT void box_c_string(const char* c_string);
F_STRING* from_c_string(const char* c_string);
F_STRING* memory_to_string(const BYTE* string, CELL length);
void primitive_memory_to_string(void);
DLLEXPORT char* unbox_c_string(void);
DLLEXPORT u16* unbox_utf16_string(void);

/* untagged & unchecked */
INLINE CELL string_nth(F_STRING* string, CELL index)
{
	return cget(SREF(string,index));
}

/* untagged & unchecked */
INLINE void set_string_nth(F_STRING* string, CELL index, u16 value)
{
	cput(SREF(string,index),value);
}

void primitive_char_slot(void);
void primitive_set_char_slot(void);
F_FIXNUM string_compare(F_STRING* s1, F_STRING* s2);
void primitive_string_compare(void);
