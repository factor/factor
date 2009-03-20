/* Inline functions */
INLINE CELL array_size(CELL size)
{
	return sizeof(F_ARRAY) + size * CELLS;
}

INLINE CELL string_capacity(F_STRING* str)
{
	return untag_fixnum_fast(str->length);
}

INLINE CELL string_size(CELL size)
{
	return sizeof(F_STRING) + size;
}

DEFINE_UNTAG(F_BYTE_ARRAY,BYTE_ARRAY_TYPE,byte_array)

INLINE CELL byte_array_capacity(F_BYTE_ARRAY *array)
{
	return untag_fixnum_fast(array->capacity);
}

INLINE CELL byte_array_size(CELL size)
{
	return sizeof(F_BYTE_ARRAY) + size;
}

INLINE CELL callstack_size(CELL size)
{
	return sizeof(F_CALLSTACK) + size;
}

DEFINE_UNTAG(F_CALLSTACK,CALLSTACK_TYPE,callstack)

INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

DEFINE_UNTAG(F_ARRAY,ARRAY_TYPE,array)

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)
#define UNAREF(array,ptr) (((CELL)(ptr)-(CELL)(array)-sizeof(F_ARRAY)) / CELLS)

INLINE CELL array_nth(F_ARRAY *array, CELL slot)
{
	return get(AREF(array,slot));
}

INLINE void set_array_nth(F_ARRAY *array, CELL slot, CELL value)
{
	put(AREF(array,slot),value);
	write_barrier((CELL)array);
}

INLINE CELL array_capacity(F_ARRAY* array)
{
	return array->capacity >> TAG_BITS;
}

#define BREF(byte_array,index) ((CELL)byte_array + sizeof(F_BYTE_ARRAY) + (index))
#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + (index))

INLINE F_STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return untag_object(tagged);
}

DEFINE_UNTAG(F_QUOTATION,QUOTATION_TYPE,quotation)

DEFINE_UNTAG(F_WORD,WORD_TYPE,word)

INLINE CELL tag_tuple(F_TUPLE *tuple)
{
	return RETAG(tuple,TUPLE_TYPE);
}

INLINE F_TUPLE *untag_tuple(CELL object)
{
	type_check(TUPLE_TYPE,object);
	return untag_object(object);
}

INLINE CELL tuple_size(F_TUPLE_LAYOUT *layout)
{
	CELL size = untag_fixnum_fast(layout->size);
	return sizeof(F_TUPLE) + size * CELLS;
}

INLINE CELL tuple_nth(F_TUPLE *tuple, CELL slot)
{
	return get(AREF(tuple,slot));
}

INLINE void set_tuple_nth(F_TUPLE *tuple, CELL slot, CELL value)
{
	put(AREF(tuple,slot),value);
	write_barrier((CELL)tuple);
}

/* Prototypes */
DLLEXPORT void box_boolean(bool value);
DLLEXPORT bool to_boolean(CELL value);

F_ARRAY *allot_array_internal(CELL type, CELL capacity);
F_ARRAY *allot_array(CELL type, CELL capacity, CELL fill);
F_BYTE_ARRAY *allot_byte_array(CELL size);

CELL allot_array_1(CELL obj);
CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

void primitive_array(void);
void primitive_tuple(void);
void primitive_tuple_boa(void);
void primitive_tuple_layout(void);
void primitive_byte_array(void);
void primitive_uninitialized_byte_array(void);
void primitive_clone(void);

F_ARRAY *reallot_array(F_ARRAY* array, CELL capacity);
F_BYTE_ARRAY *reallot_byte_array(F_BYTE_ARRAY *array, CELL capacity);
void primitive_resize_array(void);
void primitive_resize_byte_array(void);

F_STRING* allot_string_internal(CELL capacity);
F_STRING* allot_string(CELL capacity, CELL fill);
void primitive_uninitialized_string(void);
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

F_WORD *allot_word(CELL vocab, CELL name);
void primitive_word(void);
void primitive_word_xt(void);

void primitive_wrapper(void);

/* Macros to simulate a vector in C */
#define GROWABLE_ARRAY(result) \
	CELL result##_count = 0; \
	CELL result = tag_object(allot_array(ARRAY_TYPE,100,F))

F_ARRAY *growable_array_add(F_ARRAY *result, CELL elt, CELL *result_count);

#define GROWABLE_ARRAY_ADD(result,elt) \
	result = tag_object(growable_array_add(untag_object(result),elt,&result##_count))

F_ARRAY *growable_array_append(F_ARRAY *result, F_ARRAY *elts, CELL *result_count);

#define GROWABLE_ARRAY_APPEND(result,elts) \
	result = tag_object(growable_array_append(untag_object(result),elts,&result##_count))

#define GROWABLE_ARRAY_TRIM(result) \
	result = tag_object(reallot_array(untag_object(result),result##_count))

/* Macros to simulate a byte vector in C */
#define GROWABLE_BYTE_ARRAY(result) \
	CELL result##_count = 0; \
	CELL result = tag_object(allot_byte_array(100))

F_ARRAY *growable_byte_array_append(F_BYTE_ARRAY *result, void *elts, CELL len, CELL *result_count);

#define GROWABLE_BYTE_ARRAY_APPEND(result,elts,len) \
	result = tag_object(growable_byte_array_append(untag_object(result),elts,len,&result##_count))

#define GROWABLE_BYTE_ARRAY_TRIM(result) \
	result = tag_object(reallot_byte_array(untag_object(result),result##_count))
