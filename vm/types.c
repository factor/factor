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

CELL clone_object(CELL object)
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

void primitive_clone(void)
{
	drepl(clone_object(dpeek()));
}

F_WORD *allot_word(CELL vocab, CELL name)
{
	REGISTER_ROOT(vocab);
	REGISTER_ROOT(name);
	F_WORD *word = allot_object(WORD_TYPE,sizeof(F_WORD));
	UNREGISTER_ROOT(name);
	UNREGISTER_ROOT(vocab);

	word->hashcode = tag_fixnum((rand() << 16) ^ rand());
	word->vocabulary = vocab;
	word->name = name;
	word->def = userenv[UNDEFINED_ENV];
	word->props = F;
	word->counter = tag_fixnum(0);
	word->optimizedp = F;
	word->subprimitive = F;
	word->profiling = NULL;
	word->code = NULL;

	REGISTER_UNTAGGED(word);
	jit_compile_word(word,word->def,true);
	UNREGISTER_UNTAGGED(word);

	REGISTER_UNTAGGED(word);
	update_word_xt(word);
	UNREGISTER_UNTAGGED(word);

	if(profiling_p)
		relocate_code_block(word->profiling);

	return word;
}

/* <word> ( name vocabulary -- word ) */
void primitive_word(void)
{
	CELL vocab = dpop();
	CELL name = dpop();
	dpush(tag_object(allot_word(vocab,name)));
}

/* word-xt ( word -- start end ) */
void primitive_word_xt(void)
{
	F_WORD *word = untag_word(dpop());
	F_CODE_BLOCK *code = (profiling_p ? word->profiling : word->code);
	dpush(allot_cell((CELL)code + sizeof(F_CODE_BLOCK)));
	dpush(allot_cell((CELL)code + code->block.size));
}

void primitive_wrapper(void)
{
	F_WRAPPER *wrapper = allot_object(WRAPPER_TYPE,sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag_object(wrapper));
}

/* Arrays */

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
		/* No need for write barrier here. Either the object is in
		the nursery, or it was allocated directly in tenured space
		and the write barrier is already hit for us in that case. */
		for(i = 0; i < capacity; i++)
			put(AREF(array,i),fill);
	}
	return array;
}

/* push a new array on the stack */
void primitive_array(void)
{
	CELL initial = dpop();
	CELL size = unbox_array_size();
	dpush(tag_object(allot_array(ARRAY_TYPE,size,initial)));
}

CELL allot_array_1(CELL obj)
{
	REGISTER_ROOT(obj);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,1);
	UNREGISTER_ROOT(obj);
	set_array_nth(a,0,obj);
	return tag_object(a);
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

F_ARRAY *reallot_array(F_ARRAY* array, CELL capacity)
{
	CELL to_copy = array_capacity(array);
	if(capacity < to_copy)
		to_copy = capacity;

	REGISTER_UNTAGGED(array);
	F_ARRAY* new_array = allot_array_internal(untag_header(array->header),capacity);
	UNREGISTER_UNTAGGED(array);

	memcpy(new_array + 1,array + 1,to_copy * CELLS);
	memset((char *)AREF(new_array,to_copy),'\0',(capacity - to_copy) * CELLS);

	return new_array;
}

void primitive_resize_array(void)
{
	F_ARRAY* array = untag_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_array(array,capacity)));
}

F_ARRAY *growable_array_add(F_ARRAY *result, CELL elt, CELL *result_count)
{
	REGISTER_ROOT(elt);

	if(*result_count == array_capacity(result))
	{
		result = reallot_array(result,*result_count * 2);
	}

	UNREGISTER_ROOT(elt);
	set_array_nth(result,*result_count,elt);
	(*result_count)++;

	return result;
}

F_ARRAY *growable_array_append(F_ARRAY *result, F_ARRAY *elts, CELL *result_count)
{
	REGISTER_UNTAGGED(elts);

	CELL elts_size = array_capacity(elts);
	CELL new_size = *result_count + elts_size;

	if(new_size >= array_capacity(result))
		result = reallot_array(result,new_size * 2);

	UNREGISTER_UNTAGGED(elts);

	write_barrier((CELL)result);

	memcpy((void *)AREF(result,*result_count),(void *)AREF(elts,0),elts_size * CELLS);

	*result_count += elts_size;

	return result;
}

/* Byte arrays */

/* must fill out array before next GC */
F_BYTE_ARRAY *allot_byte_array_internal(CELL size)
{
	F_BYTE_ARRAY *array = allot_object(BYTE_ARRAY_TYPE,
		byte_array_size(size));
	array->capacity = tag_fixnum(size);
	return array;
}

/* size is in bytes this time */
F_BYTE_ARRAY *allot_byte_array(CELL size)
{
	F_BYTE_ARRAY *array = allot_byte_array_internal(size);
	memset(array + 1,0,size);
	return array;
}

/* push a new byte array on the stack */
void primitive_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array(size)));
}

void primitive_uninitialized_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array_internal(size)));
}

F_BYTE_ARRAY *reallot_byte_array(F_BYTE_ARRAY *array, CELL capacity)
{
	CELL to_copy = array_capacity(array);
	if(capacity < to_copy)
		to_copy = capacity;

	REGISTER_UNTAGGED(array);
	F_BYTE_ARRAY *new_array = allot_byte_array_internal(capacity);
	UNREGISTER_UNTAGGED(array);

	memcpy(new_array + 1,array + 1,to_copy);

	return new_array;
}

void primitive_resize_byte_array(void)
{
	F_BYTE_ARRAY* array = untag_byte_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_byte_array(array,capacity)));
}

F_BYTE_ARRAY *growable_byte_array_append(F_BYTE_ARRAY *result, void *elts, CELL len, CELL *result_count)
{
	CELL new_size = *result_count + len;

	if(new_size >= byte_array_capacity(result))
		result = reallot_byte_array(result,new_size * 2);

	memcpy((void *)BREF(result,*result_count),elts,len);

	*result_count = new_size;

	return result;
}

/* Tuples */

/* push a new tuple on the stack */
F_TUPLE *allot_tuple(F_TUPLE_LAYOUT *layout)
{
	REGISTER_UNTAGGED(layout);
	F_TUPLE *tuple = allot_object(TUPLE_TYPE,tuple_size(layout));
	UNREGISTER_UNTAGGED(layout);
	tuple->layout = tag_object(layout);
	return tuple;
}

void primitive_tuple(void)
{
	F_TUPLE_LAYOUT *layout = untag_object(dpop());
	F_FIXNUM size = untag_fixnum_fast(layout->size);

	F_TUPLE *tuple = allot_tuple(layout);
	F_FIXNUM i;
	for(i = size - 1; i >= 0; i--)
		put(AREF(tuple,i),F);

	dpush(tag_tuple(tuple));
}

/* push a new tuple on the stack, filling its slots from the stack */
void primitive_tuple_boa(void)
{
	F_TUPLE_LAYOUT *layout = untag_object(dpop());
	F_FIXNUM size = untag_fixnum_fast(layout->size);
	F_TUPLE *tuple = allot_tuple(layout);
	memcpy(tuple + 1,(CELL *)(ds - CELLS * (size - 1)),CELLS * size);
	ds -= CELLS * size;
	dpush(tag_tuple(tuple));
}

/* Strings */
CELL string_nth(F_STRING* string, CELL index)
{
	/* If high bit is set, the most significant 16 bits of the char
	come from the aux vector. The least significant bit of the
	corresponding aux vector entry is negated, so that we can
	XOR the two components together and get the original code point
	back. */
	CELL ch = bget(SREF(string,index));
	if((ch & 0x80) == 0)
		return ch;
	else
	{
		F_BYTE_ARRAY *aux = untag_object(string->aux);
		return (cget(BREF(aux,index * sizeof(u16))) << 7) ^ ch;
	}
}

void set_string_nth_fast(F_STRING* string, CELL index, CELL ch)
{
	bput(SREF(string,index),ch);
}

void set_string_nth_slow(F_STRING* string, CELL index, CELL ch)
{
	F_BYTE_ARRAY *aux;

	bput(SREF(string,index),(ch & 0x7f) | 0x80);

	if(string->aux == F)
	{
		REGISTER_UNTAGGED(string);
		/* We don't need to pre-initialize the
		byte array with any data, since we
		only ever read from the aux vector
		if the most significant bit of a
		character is set. Initially all of
		the bits are clear. */
		aux = allot_byte_array_internal(
			untag_fixnum_fast(string->length)
			* sizeof(u16));
		UNREGISTER_UNTAGGED(string);

		write_barrier((CELL)string);
		string->aux = tag_object(aux);
	}
	else
		aux = untag_object(string->aux);

	cput(BREF(aux,index * sizeof(u16)),(ch >> 7) ^ 1);
}

/* allocates memory */
void set_string_nth(F_STRING* string, CELL index, CELL ch)
{
	if(ch <= 0x7f)
		set_string_nth_fast(string,index,ch);
	else
		set_string_nth_slow(string,index,ch);
}

/* untagged */
F_STRING* allot_string_internal(CELL capacity)
{
	F_STRING *string = allot_object(STRING_TYPE,string_size(capacity));

	string->length = tag_fixnum(capacity);
	string->hashcode = F;
	string->aux = F;

	return string;
}

/* allocates memory */
void fill_string(F_STRING *string, CELL start, CELL capacity, CELL fill)
{
	if(fill <= 0x7f)
		memset((void *)SREF(string,start),fill,capacity - start);
	else
	{
		CELL i;

		for(i = start; i < capacity; i++)
		{
			REGISTER_UNTAGGED(string);
			set_string_nth(string,i,fill);
			UNREGISTER_UNTAGGED(string);
		}
	}
}

/* untagged */
F_STRING *allot_string(CELL capacity, CELL fill)
{
	F_STRING* string = allot_string_internal(capacity);
	REGISTER_UNTAGGED(string);
	fill_string(string,0,capacity,fill);
	UNREGISTER_UNTAGGED(string);
	return string;
}

void primitive_string(void)
{
	CELL initial = to_cell(dpop());
	CELL length = unbox_array_size();
	dpush(tag_object(allot_string(length,initial)));
}

F_STRING* reallot_string(F_STRING* string, CELL capacity)
{
	CELL to_copy = string_capacity(string);
	if(capacity < to_copy)
		to_copy = capacity;

	REGISTER_UNTAGGED(string);
	F_STRING *new_string = allot_string_internal(capacity);
	UNREGISTER_UNTAGGED(string);

	memcpy(new_string + 1,string + 1,to_copy);

	if(string->aux != F)
	{
		REGISTER_UNTAGGED(string);
		REGISTER_UNTAGGED(new_string);
		F_BYTE_ARRAY *new_aux = allot_byte_array(capacity * sizeof(u16));
		UNREGISTER_UNTAGGED(new_string);
		UNREGISTER_UNTAGGED(string);

		write_barrier((CELL)new_string);
		new_string->aux = tag_object(new_aux);

		F_BYTE_ARRAY *aux = untag_object(string->aux);
		memcpy(new_aux + 1,aux + 1,to_copy * sizeof(u16));
	}

	REGISTER_UNTAGGED(string);
	REGISTER_UNTAGGED(new_string);
	fill_string(new_string,to_copy,capacity,'\0');
	UNREGISTER_UNTAGGED(new_string);
	UNREGISTER_UNTAGGED(string);

	return new_string;
}

void primitive_resize_string(void)
{
	F_STRING* string = untag_string(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_string(string,capacity)));
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
			REGISTER_UNTAGGED(s); \
			set_string_nth(s,i,(utype)*string); \
			UNREGISTER_UNTAGGED(s); \
			string++; \
		} \
		return s; \
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
	}

MEMORY_TO_STRING(char,u8)
MEMORY_TO_STRING(u16,u16)
MEMORY_TO_STRING(u32,u32)

bool check_string(F_STRING *s, CELL max)
{
	CELL capacity = string_capacity(s);
	CELL i;
	for(i = 0; i < capacity; i++)
	{
		CELL ch = string_nth(s,i);
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
	void primitive_##type##_string_to_memory(void) \
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
		REGISTER_UNTAGGED(s); \
		_c_str = allot_c_string(capacity,sizeof(type)); \
		UNREGISTER_UNTAGGED(s); \
		type *c_str = (type*)(_c_str + 1); \
		type##_string_to_memory(s,c_str); \
		c_str[capacity] = 0; \
		return _c_str; \
	} \
	type *to_##type##_string(F_STRING *s, bool check) \
	{ \
		return (type*)(string_to_##type##_alien(s,check) + 1); \
	} \
	type *unbox_##type##_string(void) \
	{ \
		return to_##type##_string(untag_string(dpop()),true); \
	}

STRING_TO_MEMORY(char);
STRING_TO_MEMORY(u16);

void primitive_string_nth(void)
{
	F_STRING *string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	dpush(tag_fixnum(string_nth(string,index)));
}

void primitive_set_string_nth(void)
{
	F_STRING *string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	CELL value = untag_fixnum_fast(dpop());
	set_string_nth(string,index,value);
}

void primitive_set_string_nth_fast(void)
{
	F_STRING *string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	CELL value = untag_fixnum_fast(dpop());
	set_string_nth_fast(string,index,value);
}

void primitive_set_string_nth_slow(void)
{
	F_STRING *string = untag_object(dpop());
	CELL index = untag_fixnum_fast(dpop());
	CELL value = untag_fixnum_fast(dpop());
	set_string_nth_slow(string,index,value);
}
