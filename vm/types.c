#include "factor.h"

/* FFI calls this */
void box_boolean(bool value)
{
	dpush(value ? T : F);
}

/* FFI calls this */
bool unbox_boolean(void)
{
	return (dpop() != F);
}

/* the array is full of undefined data, and must be correctly filled before the
next GC. size is in cells */
F_ARRAY *allot_array(CELL type, F_FIXNUM capacity)
{
	F_ARRAY *array;

	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_integer(capacity),F,true);

	array = allot_object(type,array_size(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

/* make a new array with an initial element */
F_ARRAY *array(CELL type, F_FIXNUM capacity, CELL fill)
{
	int i;
	F_ARRAY* array = allot_array(type, capacity);
	for(i = 0; i < capacity; i++)
		put(AREF(array,i),fill);
	return array;
}

/* size is in bytes this time */
F_ARRAY *byte_array(F_FIXNUM size)
{
	F_FIXNUM byte_size = (size + sizeof(CELL) - 1) / sizeof(CELL);
	return array(BYTE_ARRAY_TYPE,byte_size,0);
}

/* push a new array on the stack */
void primitive_array(void)
{
	CELL initial;
	F_FIXNUM size;
	maybe_gc(0);
	initial = dpop();
	size = to_fixnum(dpop());
	dpush(tag_object(array(ARRAY_TYPE,size,initial)));
}

/* push a new tuple on the stack */
void primitive_tuple(void)
{
	CELL class;
	F_FIXNUM size;
	F_ARRAY *tuple;
	maybe_gc(0);
	size = to_fixnum(dpop());
	class = dpop();
	tuple = array(TUPLE_TYPE,size,F);
	put(AREF(tuple,0),class);
	dpush(tag_object(tuple));
}

/* push a new byte on the stack */
void primitive_byte_array(void)
{
	F_FIXNUM size = to_fixnum(dpop());
	maybe_gc(0);
	dpush(tag_object(byte_array(size)));
}

/* push a new quotation on the stack */
void primitive_quotation(void)
{
	F_FIXNUM size;
	maybe_gc(0);
	size = to_fixnum(dpop());
	dpush(tag_object(array(QUOTATION_TYPE,size,F)));
}

CELL make_array_2(CELL v1, CELL v2)
{
	F_ARRAY *a = array(ARRAY_TYPE,2,F);
	put(AREF(a,0),v1);
	put(AREF(a,1),v2);
	return tag_object(a);
}

CELL make_array_4(CELL v1, CELL v2, CELL v3, CELL v4)
{
	F_ARRAY *a = array(ARRAY_TYPE,4,F);
	put(AREF(a,0),v1);
	put(AREF(a,1),v2);
	put(AREF(a,2),v3);
	put(AREF(a,3),v4);
	return tag_object(a);
}

F_ARRAY* resize_array(F_ARRAY* array, F_FIXNUM capacity, CELL fill)
{
	int i;
	F_ARRAY* new_array;
	
	CELL to_copy = array_capacity(array);
	if(capacity < to_copy)
		to_copy = capacity;
	
	new_array = allot_array(untag_header(array->header),capacity);
	
	memcpy(new_array + 1,array + 1,to_copy * CELLS);
	
	for(i = to_copy; i < capacity; i++)
		put(AREF(new_array,i),fill);

	return new_array;
}

void primitive_resize_array(void)
{
	F_ARRAY* array;
	F_FIXNUM capacity = to_fixnum(dpeek2());
	maybe_gc(array_size(capacity));
	array = untag_array(dpop());
	drepl(tag_object(resize_array(array,capacity,F)));
}

void primitive_array_to_tuple(void)
{
	CELL array = dpeek();
	type_check(ARRAY_TYPE,array);
	array = clone(array);
	put(SLOT(UNTAG(array),0),tag_header(TUPLE_TYPE));
	drepl(array);
}

void primitive_tuple_to_array(void)
{
	CELL tuple = dpeek();
	type_check(TUPLE_TYPE,tuple);
	tuple = clone(tuple);
	put(SLOT(UNTAG(tuple),0),tag_header(ARRAY_TYPE));
	drepl(tuple);
}

F_VECTOR* vector(F_FIXNUM capacity)
{
	F_VECTOR* vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = tag_fixnum(0);
	vector->array = tag_object(array(ARRAY_TYPE,capacity,F));
	return vector;
}

void primitive_vector(void)
{
	CELL size = to_fixnum(dpeek());
	maybe_gc(array_size(size) + sizeof(F_VECTOR));
	drepl(tag_object(vector(size)));
}

void primitive_array_to_vector(void)
{
	F_ARRAY *array;
	F_VECTOR *vector;
	maybe_gc(sizeof(F_VECTOR));
	array = untag_array(dpeek());
	vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = array->capacity;
	vector->array = tag_object(array);
	drepl(tag_object(vector));
}

/* untagged */
F_STRING* allot_string(F_FIXNUM capacity)
{
	F_STRING* string;

	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_integer(capacity),F,true);

	string = allot_object(STRING_TYPE,
		sizeof(F_STRING) + (capacity + 1) * CHARS);
	/* strings are null-terminated in memory, even though they also
	have a length field. The null termination allows us to add
	the sizeof(F_STRING) to a Factor string to get a C-style
	UTF16 string for C library calls. */
	cput(SREF(string,capacity),(u16)'\0');
	string->length = tag_fixnum(capacity);
	string->hashcode = F;
	return string;
}

/* call this after constructing a string */
void rehash_string(F_STRING* str)
{
	s32 hash = 0;
	CELL i;
	CELL capacity = string_capacity(str);
	for(i = 0; i < capacity; i++)
		hash = (31*hash + string_nth(str,i));
	str->hashcode = (s32)tag_fixnum(hash);
}

void primitive_rehash_string(void)
{
	rehash_string(untag_string(dpop()));
}

/* untagged */
F_STRING *string(F_FIXNUM capacity, CELL fill)
{
	CELL i;

	F_STRING* string = allot_string(capacity);

	for(i = 0; i < capacity; i++)
		cput(SREF(string,i),fill);

	rehash_string(string);

	return string;
}

void primitive_string(void)
{
	CELL initial = to_cell(dpop());
	F_FIXNUM length = to_fixnum(dpop());
	maybe_gc(string_size(length));
	dpush(tag_object(string(length,initial)));
}

F_STRING* resize_string(F_STRING* string, F_FIXNUM capacity, u16 fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	CELL i;
	CELL to_copy = string_capacity(string);

	if(capacity < to_copy)
		to_copy = capacity;

	F_STRING* new_string = allot_string(capacity);

	memcpy(new_string + 1,string + 1,to_copy * CHARS);

	for(i = to_copy; i < capacity; i++)
		cput(SREF(new_string,i),fill);

	return new_string;
}

void primitive_resize_string(void)
{
	F_STRING* string;
	CELL capacity = to_fixnum(dpeek2());
	maybe_gc(string_size(capacity));
	string = untag_string_fast(dpop());
	drepl(tag_object(resize_string(string,capacity,0)));
}

/* Some ugly macros to prevent a 2x code duplication */

#define MEMORY_TO_STRING(type,utype) \
	F_STRING *memory_to_##type##_string(const type *string, CELL length) \
	{ \
		F_STRING* s = allot_string(length); \
		CELL i; \
		for(i = 0; i < length; i++) \
		{ \
			cput(SREF(s,i),(utype)*string); \
			string++; \
		} \
		rehash_string(s); \
		return s; \
	} \
	void primitive_memory_to_##type##_string(void) \
	{ \
		CELL length = unbox_unsigned_cell(); \
		type *string = (type*)unbox_unsigned_cell(); \
		dpush(tag_object(memory_to_##type##_string(string,length))); \
	} \
	F_STRING *from_##type##_string(const type *str) \
	{ \
		CELL length = 0; \
		type *scan = str; \
		while(*scan++) length++; \
		return memory_to_##type##_string((type*)str,length); \
	} \
	void box_##type##_string(const type *str) \
	{ \
		dpush(str ? tag_object(from_##type##_string(str)) : F); \
	} \
	void primitive_alien_to_##type##_string(void) \
	{ \
		maybe_gc(0); \
		drepl(tag_object(from_##type##_string(alien_offset(dpeek())))); \
	}

MEMORY_TO_STRING(char,u8)
MEMORY_TO_STRING(u16,u16)

bool check_string(F_STRING *s, CELL max)
{
	CELL capacity = string_capacity(s);
	CELL i;
	for(i = 0; i < capacity; i++)
	{
		u16 ch = string_nth(s,i);
		if(ch == '\0' || ch >= (1 << (max * 8)))
			return false;
	}
	return true;
}

F_ARRAY *allot_c_string(CELL capacity, CELL size)
{
	return allot_array(BYTE_ARRAY_TYPE,capacity * size / CELLS + 1);
}

#define STRING_TO_MEMORY(type) \
	void type##_string_to_memory(F_STRING *s, type *string) \
	{ \
		CELL i; \
		CELL capacity = string_capacity(s); \
		for(i = 0; i < capacity; i++) \
			string[i] = string_nth(s,i); \
	} \
	void primitive_##type##_string_to_memory(void) \
	{ \
		type *address = (type*)unbox_unsigned_cell(); \
		F_STRING *str = untag_string(dpop()); \
		type##_string_to_memory(str,address); \
	} \
	F_ARRAY *string_to_##type##_alien(F_STRING *s, bool check) \
	{ \
		CELL capacity = string_capacity(s); \
		F_ARRAY *_c_str; \
		if(check && !check_string(s,sizeof(type))) \
			general_error(ERROR_C_STRING,tag_object(s),F,true); \
		_c_str = allot_c_string(capacity,sizeof(type)); \
		type *c_str = (type*)(_c_str + 1); \
		type##_string_to_memory(s,c_str); \
		c_str[capacity] = 0; \
		return _c_str; \
	} \
	type *to_##type##_string(F_STRING *s, bool check) \
	{ \
		if(sizeof(type) == sizeof(u16)) \
		{ \
			if(check && !check_string(s,sizeof(type))) \
				general_error(ERROR_C_STRING,tag_object(s),F,true); \
			return (type*)(s + 1); \
		} \
		else \
			return (type*)(string_to_##type##_alien(s,check) + 1); \
	} \
	type *unbox_##type##_string(void) \
	{ \
		return to_##type##_string(untag_string(dpop()),true); \
	} \
	void primitive_string_to_##type##_alien(void) \
	{ \
		CELL string, t; \
		maybe_gc(0); \
		string = dpeek(); \
		t = type_of(string); \
		if(t != ALIEN_TYPE && t != BYTE_ARRAY_TYPE && t != F_TYPE) \
			drepl(tag_object(string_to_##type##_alien(untag_string(string),true))); \
	}

STRING_TO_MEMORY(char);
STRING_TO_MEMORY(u16);

void primitive_char_slot(void)
{
	F_STRING* string = untag_string_fast(dpop());
	CELL index = untag_fixnum_fast(dpop());
	dpush(tag_fixnum(string_nth(string,index)));
}

void primitive_set_char_slot(void)
{
	F_STRING* string = untag_string_fast(dpop());
	CELL index = untag_fixnum_fast(dpop());
	CELL value = untag_fixnum_fast(dpop());
	set_string_nth(string,index,value);
}

F_SBUF* sbuf(F_FIXNUM capacity)
{
	F_SBUF* sbuf;
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_integer(capacity),F,true);
	sbuf = allot_object(SBUF_TYPE,sizeof(F_SBUF));
	sbuf->top = tag_fixnum(0);
	sbuf->string = tag_object(string(capacity,'\0'));
	return sbuf;
}

void primitive_sbuf(void)
{
	CELL size = to_fixnum(dpeek());
	maybe_gc(sizeof(F_SBUF) + string_size(size));
	drepl(tag_object(sbuf(size)));
}

void primitive_hashtable(void)
{
	F_HASHTABLE* hash;
	maybe_gc(0);
	hash = allot_object(HASHTABLE_TYPE,sizeof(F_HASHTABLE));
	hash->count = F;
	hash->deleted = F;
	hash->array = F;
	dpush(tag_object(hash));
}

void update_xt(F_WORD* word)
{
	word->compiledp = F;
	word->xt = primitive_to_xt(to_fixnum(word->primitive));
}

/* <word> ( name vocabulary -- word ) */
void primitive_word(void)
{
	F_WORD *word;
	CELL name, vocabulary;

	maybe_gc(sizeof(F_WORD));

	vocabulary = dpop();
	name = dpop();
	word = allot_object(WORD_TYPE,sizeof(F_WORD));
	word->hashcode = tag_fixnum(rand());
	word->name = name;
	word->vocabulary = vocabulary;
	word->primitive = tag_fixnum(0);
	word->def = F;
	word->props = F;
	word->compiledp = F;
	word->xt = (CELL)undefined;
	dpush(tag_word(word));
}

void primitive_update_xt(void)
{
	update_xt(untag_word(dpop()));
}

void primitive_word_xt(void)
{
	F_WORD *word = untag_word(dpeek());
	drepl(tag_cell(word->xt));
}

void fixup_word(F_WORD* word)
{
	/* If this is a compiled word, relocate the code pointer. Otherwise,
	reset it based on the primitive number of the word. */
	if(word->compiledp != F)
		code_fixup(&word->xt);
	else
		update_xt(word);
}

void primitive_wrapper(void)
{
	F_WRAPPER *wrapper;

	maybe_gc(sizeof(F_WRAPPER));

	wrapper = allot_object(WRAPPER_TYPE,sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag_wrapper(wrapper));
}
