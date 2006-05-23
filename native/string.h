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

INLINE CELL string_size(CELL size)
{
	return align8(sizeof(F_STRING) + (size + 1) * CHARS);
}

F_STRING* allot_string(F_FIXNUM capacity);
void rehash_string(F_STRING* str);
void primitive_rehash_string(void);
F_STRING* string(F_FIXNUM capacity, CELL fill);
void primitive_string(void);
F_STRING *resize_string(F_STRING *string, F_FIXNUM capacity, u16 fill);
void primitive_resize_string(void);

F_STRING *memory_to_char_string(const char *string, CELL length);
void primitive_memory_to_char_string(void);
F_STRING *from_char_string(const char *c_string);
DLLEXPORT void box_char_string(const char *c_string);
void primitive_alien_to_char_string(void);

F_STRING *memory_to_u16_string(const u16 *string, CELL length);
void primitive_memory_to_u16_string(void);
F_STRING *from_u16_string(const u16 *c_string);
DLLEXPORT void box_u16_string(const u16 *c_string);
void primitive_alien_to_u16_string(void);

void char_string_to_memory(F_STRING *s, char *string);
void primitive_char_string_to_memory(void);
F_ARRAY *string_to_char_alien(F_STRING *s, bool check);
char* to_char_string(F_STRING *s, bool check);
char *pop_char_string(void);
DLLEXPORT char *unbox_char_string(void);
void primitive_string_to_char_alien(void);

void u16_string_to_memory(F_STRING *s, u16 *string);
void primitive_u16_string_to_memory(void);
F_ARRAY *string_to_u16_alien(F_STRING *s, bool check);
u16* to_u16_string(F_STRING *s, bool check);
u16 *pop_u16_string(void);
DLLEXPORT u16 *unbox_u16_string(void);
void primitive_string_to_u16_alien(void);

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
