#include "factor.h"

/* untagged */
F_STRING* allot_string(CELL capacity)
{
	F_STRING* string = allot_object(STRING_TYPE,
		sizeof(F_STRING) + (capacity + 1) * CHARS);
	/* strings are null-terminated in memory, even though they also
	have a length field. The null termination allows us to add
	the sizeof(F_STRING) to a Factor string to get a C-style
	UTF16 string for C library calls. */
	cput(SREF(string,capacity),(u16)'\0');
	string->length = tag_fixnum(capacity);
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
F_STRING *string(CELL capacity, CELL fill)
{
	CELL i;

	F_STRING* string = allot_string(capacity);

	for(i = 0; i < capacity; i++)
		cput(SREF(string,i),fill);

	rehash_string(string);

	return string;
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
	drepl(tag_object(resize_string(string,capacity,F)));
}

F_STRING *memory_to_string(const BYTE* string, CELL length)
{
	F_STRING* s = allot_string(length);
	CELL i;

	for(i = 0; i < length; i++)
	{
		cput(SREF(s,i),*string);
		string++;
	}

	rehash_string(s);
	
	return s;
}

void primitive_memory_to_string(void)
{
	CELL length = unbox_unsigned_cell();
	BYTE *string = (BYTE*)unbox_unsigned_cell();
	dpush(tag_object(memory_to_string(string,length)));
}

/* untagged */
F_STRING *from_c_string(const char *c_string)
{
	return memory_to_string((BYTE*)c_string,strlen(c_string));
}

/* FFI calls this */
void box_c_string(const char *c_string)
{
	dpush(c_string ? tag_object(from_c_string(c_string)) : F);
}

F_ARRAY *string_to_alien(F_STRING *s, bool check)
{
	CELL capacity = string_capacity(s);
	F_ARRAY *_c_str;
	
	if(check)
	{
		CELL i;
		for(i = 0; i < capacity; i++)
		{
			u16 ch = string_nth(s,i);
			if(ch == '\0' || ch > 255)
				general_error(ERROR_C_STRING,tag_object(s));
		}
	}

	_c_str = allot_array(BYTE_ARRAY_TYPE,capacity / CELLS + 1);
	BYTE *c_str = (BYTE*)(_c_str + 1);
	string_to_memory(s,c_str);
	c_str[capacity] = '\0';
	return _c_str;
}

/* untagged */
char *to_c_string(F_STRING *s, bool check)
{
	return (char*)(string_to_alien(s,check) + 1);
}

void string_to_memory(F_STRING *s, BYTE *string)
{
	CELL i;
	CELL capacity = string_capacity(s);
	for(i = 0; i < capacity; i++)
		string[i] = string_nth(s,i);
}

void primitive_string_to_memory(void)
{
	BYTE *address = (BYTE*)unbox_unsigned_cell();
	F_STRING *str = untag_string(dpop());
	string_to_memory(str,address);
}

/* FFI calls this */
char* unbox_c_string(void)
{
	CELL str = dpop();
	if(type_of(str) == STRING_TYPE)
		return to_c_string(untag_string(str),true);
	else
		return (char*)alien_offset(str);
}

/* FFI calls this */
u16* unbox_utf16_string(void)
{
	/* Return pointer to first character */
	CELL str = dpop();
	if(type_of(str) == STRING_TYPE)
		return (u16*)(untag_string(str) + 1);
	else
		return (u16*)alien_offset(str);
}

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
