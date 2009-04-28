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

INLINE CELL array_capacity(F_ARRAY* array)
{
#ifdef FACTOR_DEBUG
	CELL header = untag_header(array->header);
	assert(header == ARRAY_TYPE || header == BIGNUM_TYPE || header == BYTE_ARRAY_TYPE);
#endif
	return array->capacity >> TAG_BITS;
}

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)
#define UNAREF(array,ptr) (((CELL)(ptr)-(CELL)(array)-sizeof(F_ARRAY)) / CELLS)

INLINE CELL array_nth(F_ARRAY *array, CELL slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(untag_header(array->header) == ARRAY_TYPE);
#endif
	return get(AREF(array,slot));
}

INLINE void set_array_nth(F_ARRAY *array, CELL slot, CELL value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(untag_header(array->header) == ARRAY_TYPE);
#endif
	put(AREF(array,slot),value);
	write_barrier((CELL)array);
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
typedef struct {
	CELL count;
	CELL array;
} F_GROWABLE_ARRAY;

/* Allocates memory */
INLINE F_GROWABLE_ARRAY make_growable_array(void)
{
	F_GROWABLE_ARRAY result;
	result.count = 0;
	result.array = tag_object(allot_array(ARRAY_TYPE,100,F));
	return result;
}

#define GROWABLE_ARRAY(result) F_GROWABLE_ARRAY result##_g = make_growable_array(); \
	REGISTER_ROOT(result##_g.array)

void growable_array_add(F_GROWABLE_ARRAY *result, CELL elt);

#define GROWABLE_ARRAY_ADD(result,elt) \
	growable_array_add(&result##_g,elt)

void growable_array_append(F_GROWABLE_ARRAY *result, F_ARRAY *elts);

#define GROWABLE_ARRAY_APPEND(result,elts) \
	growable_array_append(&result##_g,elts)

INLINE void growable_array_trim(F_GROWABLE_ARRAY *array)
{
	array->array = tag_object(reallot_array(untag_object(array->array),array->count));
}

#define GROWABLE_ARRAY_TRIM(result) growable_array_trim(&result##_g)

#define GROWABLE_ARRAY_DONE(result) \
	UNREGISTER_ROOT(result##_g.array); \
	CELL result = result##_g.array;

/* Macros to simulate a byte vector in C */
typedef struct {
	CELL count;
	CELL array;
} F_GROWABLE_BYTE_ARRAY;

INLINE F_GROWABLE_BYTE_ARRAY make_growable_byte_array(void)
{
	F_GROWABLE_BYTE_ARRAY result;
	result.count = 0;
	result.array = tag_object(allot_byte_array(100));
	return result;
}

void growable_byte_array_append(F_GROWABLE_BYTE_ARRAY *result, void *elts, CELL len);

INLINE void growable_byte_array_trim(F_GROWABLE_BYTE_ARRAY *byte_array)
{
	byte_array->array = tag_object(reallot_byte_array(untag_object(byte_array->array),byte_array->count));
}
