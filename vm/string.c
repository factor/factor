#include "factor.h"

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

void check_string(F_STRING *s, CELL max)
{
	CELL capacity = string_capacity(s);
	CELL i;
	for(i = 0; i < capacity; i++)
	{
		u16 ch = string_nth(s,i);
		if(ch == '\0' || ch >= (1 << (max * 8)))
			general_error(ERROR_C_STRING,tag_object(s),F,true);
	}
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
		if(check) check_string(s,sizeof(type)); \
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
			if(check) check_string(s,sizeof(type)); \
			return (type*)(s + 1); \
		} \
		else \
			return (type*)(string_to_##type##_alien(s,check) + 1); \
	} \
	type *pop_##type##_string(void) \
	{ \
		return to_##type##_string(untag_string(dpop()),true); \
	} \
	type *unbox_##type##_string(void) \
	{ \
		if(type_of(dpeek()) == STRING_TYPE) \
			return pop_##type##_string(); \
		else \
			return unbox_alien(); \
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
