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
	return sizeof(F_STRING) + (size + 1) * CHARS;
}

INLINE CELL byte_array_capacity(F_BYTE_ARRAY *array)
{
	return untag_fixnum_fast(array->capacity);
}

INLINE CELL byte_array_size(CELL size)
{
	return sizeof(F_BYTE_ARRAY) + size;
}

INLINE CELL bit_array_capacity(F_BIT_ARRAY *array)
{
	return untag_fixnum_fast(array->capacity);
}

INLINE CELL bit_array_size(CELL size)
{
	return sizeof(F_BIT_ARRAY) + (size + 7) / 8;
}

INLINE CELL float_array_capacity(F_FLOAT_ARRAY *array)
{
	return untag_fixnum_fast(array->capacity);
}

INLINE CELL float_array_size(CELL size)
{
	return sizeof(F_FLOAT_ARRAY) + size * sizeof(double);
}

INLINE CELL callstack_size(CELL size)
{
	return sizeof(F_CALLSTACK) + size;
}

INLINE F_CALLSTACK *untag_callstack(CELL obj)
{
	type_check(CALLSTACK_TYPE,obj);
	return untag_object(obj);
}

INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

INLINE F_ARRAY* untag_array(CELL tagged)
{
	type_check(ARRAY_TYPE,tagged);
	return untag_object(tagged);
}

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

#define SREF(string,index) ((CELL)string + sizeof(F_STRING) + index * CHARS)

INLINE F_STRING* untag_string(CELL tagged)
{
	type_check(STRING_TYPE,tagged);
	return untag_object(tagged);
}

INLINE CELL string_nth(F_STRING* string, CELL index)
{
	return cget(SREF(string,index));
}

INLINE void set_string_nth(F_STRING* string, CELL index, u16 value)
{
	cput(SREF(string,index),value);
}

INLINE F_QUOTATION *untag_quotation(CELL tagged)
{
	type_check(QUOTATION_TYPE,tagged);
	return untag_object(tagged);
}

INLINE F_WORD *untag_word(CELL tagged)
{
	type_check(WORD_TYPE,tagged);
	return untag_object(tagged);
}

INLINE CELL tag_tuple(F_ARRAY *tuple)
{
	return RETAG(tuple,TUPLE_TYPE);
}

/* Prototypes */
DLLEXPORT void box_boolean(bool value);
DLLEXPORT bool to_boolean(CELL value);

F_ARRAY *allot_array_internal(CELL type, CELL capacity);
F_ARRAY *allot_array(CELL type, CELL capacity, CELL fill);
F_BYTE_ARRAY *allot_byte_array(CELL size);

CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

DECLARE_PRIMITIVE(array);
DECLARE_PRIMITIVE(tuple);
DECLARE_PRIMITIVE(tuple_boa);
DECLARE_PRIMITIVE(byte_array);
DECLARE_PRIMITIVE(bit_array);
DECLARE_PRIMITIVE(float_array);
DECLARE_PRIMITIVE(clone);
DECLARE_PRIMITIVE(tuple_to_array);
DECLARE_PRIMITIVE(to_tuple);

F_ARRAY *reallot_array(F_ARRAY* array, CELL capacity, CELL fill);
DECLARE_PRIMITIVE(resize_array);

DECLARE_PRIMITIVE(array_to_vector);

F_STRING* allot_string_internal(CELL capacity);
F_STRING* allot_string(CELL capacity, CELL fill);
DECLARE_PRIMITIVE(string);
F_STRING *reallot_string(F_STRING *string, CELL capacity, u16 fill);
DECLARE_PRIMITIVE(resize_string);

F_STRING *memory_to_char_string(const char *string, CELL length);
DECLARE_PRIMITIVE(memory_to_char_string);
F_STRING *from_char_string(const char *c_string);
DLLEXPORT void box_char_string(const char *c_string);
DECLARE_PRIMITIVE(alien_to_char_string);

F_STRING *memory_to_u16_string(const u16 *string, CELL length);
DECLARE_PRIMITIVE(memory_to_u16_string);
F_STRING *from_u16_string(const u16 *c_string);
DLLEXPORT void box_u16_string(const u16 *c_string);
DECLARE_PRIMITIVE(alien_to_u16_string);

void char_string_to_memory(F_STRING *s, char *string);
DECLARE_PRIMITIVE(char_string_to_memory);
F_BYTE_ARRAY *string_to_char_alien(F_STRING *s, bool check);
char* to_char_string(F_STRING *s, bool check);
DLLEXPORT char *unbox_char_string(void);
DECLARE_PRIMITIVE(string_to_char_alien);

void u16_string_to_memory(F_STRING *s, u16 *string);
DECLARE_PRIMITIVE(u16_string_to_memory);
F_BYTE_ARRAY *string_to_u16_alien(F_STRING *s, bool check);
u16* to_u16_string(F_STRING *s, bool check);
DLLEXPORT u16 *unbox_u16_string(void);
DECLARE_PRIMITIVE(string_to_u16_alien);

DECLARE_PRIMITIVE(char_slot);
DECLARE_PRIMITIVE(set_char_slot);

DECLARE_PRIMITIVE(string_to_sbuf);

DECLARE_PRIMITIVE(hashtable);

F_WORD *allot_word(CELL vocab, CELL name);
DECLARE_PRIMITIVE(word);
DECLARE_PRIMITIVE(update_xt);
DECLARE_PRIMITIVE(word_xt);

DECLARE_PRIMITIVE(wrapper);

/* Macros to simulate a vector in C */
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

INLINE F_ARRAY *growable_append(F_ARRAY *result, F_ARRAY *elts, CELL *result_count)
{
	REGISTER_UNTAGGED(elts);

	CELL elts_size = array_capacity(elts);
	CELL new_size = *result_count + elts_size;

	if(new_size >= array_capacity(result))
		result = reallot_array(result,new_size * 2,F);

	UNREGISTER_UNTAGGED(elts);

	memcpy((void*)AREF(result,*result_count),(void*)AREF(elts,0),elts_size * CELLS);

	*result_count += elts_size;

	return result;
}

#define GROWABLE_APPEND(result,elts) \
	result = growable_append(result,elts,&result##_count)
	
#define GROWABLE_TRIM(result) result = reallot_array(result,result##_count,F)
