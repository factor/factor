INLINE CELL string_capacity(F_STRING *str)
{
	return untag_fixnum(str->length);
}

INLINE CELL string_size(CELL size)
{
	return sizeof(F_STRING) + size;
}

#define BREF(byte_array,index) ((CELL)byte_array + sizeof(F_BYTE_ARRAY) + (index))
#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + (index))

F_STRING* allot_string_internal(CELL capacity);
F_STRING* allot_string(CELL capacity, CELL fill);
void primitive_string(void);
F_STRING *reallot_string(F_STRING *string, CELL capacity);
void primitive_resize_string(void);

/* String getters and setters */
CELL string_nth(F_STRING* string, CELL index);
void set_string_nth(F_STRING* string, CELL index, CELL value);

void primitive_string_nth(void);
void primitive_set_string_nth_slow(void);
void primitive_set_string_nth_fast(void);
