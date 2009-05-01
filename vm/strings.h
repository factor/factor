INLINE CELL string_capacity(F_STRING* str)
{
	return untag_fixnum_fast(str->length);
}

INLINE CELL string_size(CELL size)
{
	return sizeof(F_STRING) + size;
}

#define BREF(byte_array,index) ((CELL)byte_array + sizeof(F_BYTE_ARRAY) + (index))
#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + (index))

INLINE F_STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return untag_object(tagged);
}

F_STRING* allot_string_internal(CELL capacity);
F_STRING* allot_string(CELL capacity, CELL fill);
void primitive_string(void);
F_STRING *reallot_string(F_STRING *string, CELL capacity);
void primitive_resize_string(void);

F_STRING *memory_to_char_string(const char *string, CELL length);
F_STRING *from_char_string(const char *c_string);
DLLEXPORT void box_char_string(const char *c_string);

F_STRING *memory_to_u16_string(const u16 *string, CELL length);
F_STRING *from_u16_string(const u16 *c_string);
DLLEXPORT void box_u16_string(const u16 *c_string);

void char_string_to_memory(F_STRING *s, char *string);
F_BYTE_ARRAY *string_to_char_alien(F_STRING *s, bool check);
char* to_char_string(F_STRING *s, bool check);
DLLEXPORT char *unbox_char_string(void);

void u16_string_to_memory(F_STRING *s, u16 *string);
F_BYTE_ARRAY *string_to_u16_alien(F_STRING *s, bool check);
u16* to_u16_string(F_STRING *s, bool check);
DLLEXPORT u16 *unbox_u16_string(void);

/* String getters and setters */
CELL string_nth(F_STRING* string, CELL index);
void set_string_nth(F_STRING* string, CELL index, CELL value);

void primitive_string_nth(void);
void primitive_set_string_nth_slow(void);
void primitive_set_string_nth_fast(void);
