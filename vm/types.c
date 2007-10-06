#include "master.h"

/* FFI calls this */
void box_boolean(bool value)
{
	dpush(value ? T : F);
}

/* FFI calls this */
bool to_boolean(CELL value)
{
	return value != F;
}

/* the array is full of undefined data, and must be correctly filled before the
next GC. size is in cells */
F_ARRAY *allot_array_internal(CELL type, CELL capacity)
{
	F_ARRAY *array = allot_object(type,array_size(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

/* make a new array with an initial element */
F_ARRAY *allot_array(CELL type, CELL capacity, CELL fill)
{
	int i;
	REGISTER_ROOT(fill);
	F_ARRAY* array = allot_array_internal(type, capacity);
	UNREGISTER_ROOT(fill);
	if(fill == 0)
		memset((void*)AREF(array,0),'\0',capacity * CELLS);
	else
	{
		for(i = 0; i < capacity; i++)
			set_array_nth(array,i,fill);
	}
	return array;
}

/* size is in bytes this time */
F_BYTE_ARRAY *allot_byte_array(CELL size)
{
	F_BYTE_ARRAY *array = allot_object(BYTE_ARRAY_TYPE,
		byte_array_size(size));
	array->capacity = tag_fixnum(size);
	memset(array + 1,0,size);
	return array;
}

/* size is in bits */
F_BIT_ARRAY *allot_bit_array(CELL size)
{
	F_BIT_ARRAY *array = allot_object(BIT_ARRAY_TYPE,
		bit_array_size(size));
	array->capacity = tag_fixnum(size);
	memset(array + 1,0,(size + 31) / 32 * 4);
	return array;
}

/* size is in 8-byte doubles */
F_BIT_ARRAY *allot_float_array(CELL size, double initial)
{
	F_FLOAT_ARRAY *array = allot_object(FLOAT_ARRAY_TYPE,
		float_array_size(size));
	array->capacity = tag_fixnum(size);

	double *elements = (double *)AREF(array,0);
	int i;
	for(i = 0; i < size; i++)
		elements[i] = initial;

	return array;
}

/* push a new array on the stack */
DEFINE_PRIMITIVE(array)
{
	CELL initial = dpop();
	CELL size = unbox_array_size();
	dpush(tag_object(allot_array(ARRAY_TYPE,size,initial)));
}

/* push a new tuple on the stack */
DEFINE_PRIMITIVE(tuple)
{
	CELL size = unbox_array_size();
	F_ARRAY *array = allot_array(TUPLE_TYPE,size,F);
	set_array_nth(array,0,dpop());
	dpush(tag_tuple(array));
}

/* push a new tuple on the stack, filling its slots from the stack */
DEFINE_PRIMITIVE(tuple_boa)
{
	CELL size = unbox_array_size();
	F_ARRAY *array = allot_array(TUPLE_TYPE,size,F);
	set_array_nth(array,0,dpop());

	CELL i;
	for(i = size - 1; i >= 2; i--)
		set_array_nth(array,i,dpop());

	dpush(tag_tuple(array));
}

/* push a new byte array on the stack */
DEFINE_PRIMITIVE(byte_array)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array(size)));
}

/* push a new bit array on the stack */
DEFINE_PRIMITIVE(bit_array)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_bit_array(size)));
}

/* push a new float array on the stack */
DEFINE_PRIMITIVE(float_array)
{
	double initial = untag_float(dpop());
	CELL size = unbox_array_size();
	dpush(tag_object(allot_float_array(size,initial)));
}

CELL clone(CELL object)
{
	CELL size = object_size(object);
	if(size == 0)
		return object;
	else
	{
		REGISTER_ROOT(object);
		void *new_obj = allot_object(type_of(object),size);
		UNREGISTER_ROOT(object);

		CELL tag = TAG(object);
		memcpy(new_obj,(void*)UNTAG(object),size);
		return RETAG(new_obj,tag);
	}
}

DEFINE_PRIMITIVE(clone)
{
	drepl(clone(dpeek()));
}

DEFINE_PRIMITIVE(tuple_to_array)
{
	CELL object = dpeek();
	type_check(TUPLE_TYPE,object);
	object = RETAG(clone(object),OBJECT_TYPE);
	set_slot(object,0,tag_header(ARRAY_TYPE));
	drepl(object);
}

DEFINE_PRIMITIVE(to_tuple)
{
	CELL object = RETAG(clone(dpeek()),TUPLE_TYPE);
	set_slot(object,0,tag_header(TUPLE_TYPE));
	drepl(object);
}

CELL allot_array_2(CELL v1, CELL v2)
{
	REGISTER_ROOT(v1);
	REGISTER_ROOT(v2);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,2);
	UNREGISTER_ROOT(v2);
	UNREGISTER_ROOT(v1);
	set_array_nth(a,0,v1);
	set_array_nth(a,1,v2);
	return tag_object(a);
}

CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4)
{
	REGISTER_ROOT(v1);
	REGISTER_ROOT(v2);
	REGISTER_ROOT(v3);
	REGISTER_ROOT(v4);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,4);
	UNREGISTER_ROOT(v4);
	UNREGISTER_ROOT(v3);
	UNREGISTER_ROOT(v2);
	UNREGISTER_ROOT(v1);
	set_array_nth(a,0,v1);
	set_array_nth(a,1,v2);
	set_array_nth(a,2,v3);
	set_array_nth(a,3,v4);
	return tag_object(a);
}

F_ARRAY *reallot_array(F_ARRAY* array, CELL capacity, CELL fill)
{
	int i;
	F_ARRAY* new_array;
	
	CELL to_copy = array_capacity(array);
	if(capacity < to_copy)
		to_copy = capacity;

	REGISTER_UNTAGGED(array);
	REGISTER_ROOT(fill);

	new_array = allot_array_internal(untag_header(array->header),capacity);

	UNREGISTER_ROOT(fill);
	UNREGISTER_UNTAGGED(array);

	memcpy(new_array + 1,array + 1,to_copy * CELLS);
	
	for(i = to_copy; i < capacity; i++)
		set_array_nth(new_array,i,fill);

	return new_array;
}

DEFINE_PRIMITIVE(resize_array)
{
	F_ARRAY* array = untag_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_array(array,capacity,F)));
}

DEFINE_PRIMITIVE(array_to_vector)
{
	F_VECTOR *vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = dpop();
	vector->array = dpop();
	dpush(tag_object(vector));
}

/* untagged */
F_STRING* allot_string_internal(CELL capacity)
{
	F_STRING* string = allot_object(STRING_TYPE,
		sizeof(F_STRING) + (capacity + 1) * CHARS);

	/* strings are null-terminated in memory, even though they also
	have a length field. The null termination allows us to add
	the sizeof(F_STRING) to a Factor string to get a C-style
	UCS-2 string for C library calls. */
	cput(SREF(string,capacity),(u16)'\0');
	string->length = tag_fixnum(capacity);
	string->hashcode = F;
	return string;
}

void fill_string(F_STRING *string, CELL start, CELL capacity, CELL fill)
{
	if(fill == 0)
		memset((void*)SREF(string,start),'\0',
			(capacity - start) * CHARS);
	else
	{
		CELL i;

		for(i = start; i < capacity; i++)
			cput(SREF(string,i),fill);
	}
}

/* untagged */
F_STRING *allot_string(CELL capacity, CELL fill)
{
	F_STRING* string = allot_string_internal(capacity);
	fill_string(string,0,capacity,fill);
	return string;
}

DEFINE_PRIMITIVE(string)
{
	CELL initial = to_cell(dpop());
	CELL length = unbox_array_size();
	dpush(tag_object(allot_string(length,initial)));
}

F_STRING* reallot_string(F_STRING* string, CELL capacity, u16 fill)
{
	CELL to_copy = string_capacity(string);
	if(capacity < to_copy)
		to_copy = capacity;

	REGISTER_STRING(string);
	F_STRING *new_string = allot_string_internal(capacity);
	UNREGISTER_STRING(string);

	memcpy(new_string + 1,string + 1,to_copy * CHARS);
	fill_string(new_string,to_copy,capacity,fill);

	return new_string;
}

DEFINE_PRIMITIVE(resize_string)
{
	F_STRING* string = untag_string(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_string(string,capacity,0)));
}

/* Some ugly macros to prevent a 2x code duplication */

#define MEMORY_TO_STRING(type,utype) \
	F_STRING *memory_to_##type##_string(const type *string, CELL length) \
	{ \
		REGISTER_C_STRING(string); \
		F_STRING* s = allot_string_internal(length); \
		UNREGISTER_C_STRING(string); \
		CELL i; \
		for(i = 0; i < length; i++) \
		{ \
			cput(SREF(s,i),(utype)*string); \
			string++; \
		} \
		return s; \
	} \
	DEFINE_PRIMITIVE(memory_to_##type##_string) \
	{ \
		CELL length = to_cell(dpop()); \
		const type *string = unbox_alien(); \
		dpush(tag_object(memory_to_##type##_string(string,length))); \
	} \
	F_STRING *from_##type##_string(const type *str) \
	{ \
		CELL length = 0; \
		const type *scan = str; \
		while(*scan++) length++; \
		return memory_to_##type##_string(str,length); \
	} \
	void box_##type##_string(const type *str) \
	{ \
		dpush(str ? tag_object(from_##type##_string(str)) : F); \
	} \
	DEFINE_PRIMITIVE(alien_to_##type##_string) \
	{ \
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

F_BYTE_ARRAY *allot_c_string(CELL capacity, CELL size)
{
	return allot_byte_array((capacity + 1) * size);
}

#define STRING_TO_MEMORY(type) \
	void type##_string_to_memory(F_STRING *s, type *string) \
	{ \
		CELL i; \
		CELL capacity = string_capacity(s); \
		for(i = 0; i < capacity; i++) \
			string[i] = string_nth(s,i); \
	} \
	DEFINE_PRIMITIVE(type##_string_to_memory) \
	{ \
		type *address = unbox_alien(); \
		F_STRING *str = untag_string(dpop()); \
		type##_string_to_memory(str,address); \
	} \
	F_BYTE_ARRAY *string_to_##type##_alien(F_STRING *s, bool check) \
	{ \
		CELL capacity = string_capacity(s); \
		F_BYTE_ARRAY *_c_str; \
		if(check && !check_string(s,sizeof(type))) \
			general_error(ERROR_C_STRING,tag_object(s),F,NULL); \
		REGISTER_STRING(s); \
		_c_str = allot_c_string(capacity,sizeof(type)); \
		UNREGISTER_STRING(s); \
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
				general_error(ERROR_C_STRING,tag_object(s),F,NULL); \
			return (type*)(s + 1); \
		} \
		else \
			return (type*)(string_to_##type##_alien(s,check) + 1); \
	} \
	type *unbox_##type##_string(void) \
	{ \
		return to_##type##_string(untag_string(dpop()),true); \
	} \
	DEFINE_PRIMITIVE(string_to_##type##_alien) \
	{ \
		CELL string, t; \
		string = dpeek(); \
		t = type_of(string); \
		if(t != ALIEN_TYPE && t != BYTE_ARRAY_TYPE && t != F_TYPE) \
			drepl(tag_object(string_to_##type##_alien(untag_string(string),true))); \
	}

STRING_TO_MEMORY(char);
STRING_TO_MEMORY(u16);

DEFINE_PRIMITIVE(char_slot)
{
	F_STRING* string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	dpush(tag_fixnum(string_nth(string,index)));
}

DEFINE_PRIMITIVE(set_char_slot)
{
	F_STRING* string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	CELL value = untag_fixnum_fast(dpop());
	set_string_nth(string,index,value);
}

DEFINE_PRIMITIVE(string_to_sbuf)
{
	F_SBUF *sbuf = allot_object(SBUF_TYPE,sizeof(F_SBUF));
	sbuf->top = dpop();
	sbuf->string = dpop();
	dpush(tag_object(sbuf));
}

DEFINE_PRIMITIVE(hashtable)
{
	F_HASHTABLE* hash = allot_object(HASHTABLE_TYPE,sizeof(F_HASHTABLE));
	hash->count = F;
	hash->deleted = F;
	hash->array = F;
	dpush(tag_object(hash));
}

/* <word> ( name vocabulary -- word ) */
F_WORD *allot_word(CELL vocab, CELL name)
{
	REGISTER_ROOT(vocab);
	REGISTER_ROOT(name);
	F_WORD *word = allot_object(WORD_TYPE,sizeof(F_WORD));
	UNREGISTER_ROOT(name);
	UNREGISTER_ROOT(vocab);
	word->hashcode = tag_fixnum(rand());
	word->vocabulary = vocab;
	word->name = name;
	word->def = F;
	word->props = F;
	word->counter = tag_fixnum(0);
	word->compiledp = F;
	word->xt = default_word_xt(word);
	return word;
}

DEFINE_PRIMITIVE(word)
{
	CELL vocab = dpop();
	CELL name = dpop();
	dpush(tag_object(allot_word(vocab,name)));
}

DEFINE_PRIMITIVE(update_xt)
{
	F_WORD *word = untag_word(dpop());
	word->compiledp = F;
	word->xt = default_word_xt(word);
}

DEFINE_PRIMITIVE(word_xt)
{
	F_WORD *word = untag_word(dpeek());
	drepl(allot_cell((CELL)word->xt));
}

DEFINE_PRIMITIVE(wrapper)
{
	F_WRAPPER *wrapper = allot_object(WRAPPER_TYPE,sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag_object(wrapper));
}
