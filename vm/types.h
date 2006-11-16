INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

DLLEXPORT void box_boolean(bool value);
DLLEXPORT bool unbox_boolean(void);

INLINE F_ARRAY* untag_array_fast(CELL tagged)
{
	return (F_ARRAY*)UNTAG(tagged);
}

INLINE F_ARRAY* untag_array(CELL tagged)
{
	type_check(ARRAY_TYPE,tagged);
	return untag_array_fast(tagged);
}

INLINE CELL array_size(CELL size)
{
	return sizeof(F_ARRAY) + size * CELLS;
}

F_ARRAY *allot_array_internal(CELL type, F_FIXNUM capacity);
F_ARRAY *allot_array(CELL type, F_FIXNUM capacity, CELL fill);
F_ARRAY *allot_byte_array(F_FIXNUM size);

CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

void primitive_array(void);
void primitive_byte_array(void);

F_ARRAY *reallot_array(F_ARRAY* array, F_FIXNUM capacity, CELL fill);
void primitive_resize_array(void);

void primitive_become(void);

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)
#define UNAREF(array,ptr) (((CELL)(ptr)-(CELL)(array)-sizeof(F_ARRAY)) / CELLS)

INLINE void set_array_nth(F_ARRAY *array, CELL slot, CELL value)
{
	put(AREF(array,slot),value);
	write_barrier((CELL)array);
}

INLINE CELL array_capacity(F_ARRAY* array)
{
	return array->capacity >> TAG_BITS;
}

#define GROWABLE_ARRAY(result) \
	CELL result##_count = 0; \
	F_ARRAY *result = allot_array(ARRAY_TYPE,100,F)

INLINE F_ARRAY *growable_add(F_ARRAY *result, CELL elt, CELL *result_count)
{
	REGISTER_ROOT(elt);

	if(*result_count == array_capacity(result))
	{
		result = reallot_array(result,
			*result_count * 2,F);
	}

	UNREGISTER_ROOT(elt);
	set_array_nth(result,*result_count,elt);
	*result_count = *result_count + 1;

	return result;
}

#define GROWABLE_ADD(result,elt) \
	result = growable_add(result,elt,&result##_count)

#define GROWABLE_TRIM(result) result = reallot_array(result,result##_count,F)

INLINE F_VECTOR* untag_vector(CELL tagged)
{
	type_check(VECTOR_TYPE,tagged);
	return (F_VECTOR*)UNTAG(tagged);
}

F_VECTOR* vector(F_FIXNUM capacity);

void primitive_array_to_vector(void);

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
	return str->length >> TAG_BITS;
}

INLINE CELL string_size(CELL size)
{
	return sizeof(F_STRING) + (size + 1) * CHARS;
}

F_STRING* allot_string_internal(F_FIXNUM capacity);
void rehash_string(F_STRING* str);
void primitive_rehash_string(void);
F_STRING* allot_string(F_FIXNUM capacity, CELL fill);
void primitive_string(void);
F_STRING *reallot_string(F_STRING *string, F_FIXNUM capacity, u16 fill);
void primitive_resize_string(void);

bool check_string(F_STRING *s, CELL max);

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
DLLEXPORT char *unbox_char_string(void);
void primitive_string_to_char_alien(void);

void u16_string_to_memory(F_STRING *s, u16 *string);
void primitive_u16_string_to_memory(void);
F_ARRAY *string_to_u16_alien(F_STRING *s, bool check);
u16* to_u16_string(F_STRING *s, bool check);
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

void primitive_string_to_sbuf(void);

void primitive_hashtable(void);

typedef void (*XT)(F_WORD *word);

INLINE F_WORD *untag_word_fast(CELL tagged)
{
	return (F_WORD*)UNTAG(tagged);
}

INLINE F_WORD *untag_word(CELL tagged)
{
	type_check(WORD_TYPE,tagged);
	return untag_word_fast(tagged);
}

INLINE CELL tag_word(F_WORD *word)
{
	return RETAG(word,WORD_TYPE);
}

void update_xt(F_WORD* word);
void primitive_word(void);
void primitive_update_xt(void);
void primitive_word_xt(void);
void fixup_word(F_WORD* word);

INLINE F_WRAPPER *untag_wrapper_fast(CELL tagged)
{
	return (F_WRAPPER*)UNTAG(tagged);
}

INLINE CELL tag_wrapper(F_WRAPPER *wrapper)
{
	return RETAG(wrapper,WRAPPER_TYPE);
}

void primitive_wrapper(void);
