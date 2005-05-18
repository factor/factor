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
	F_FIXNUM hash = 0;
	CELL i;
	CELL capacity = string_capacity(str);
	for(i = 0; i < capacity; i++)
		hash = 31*hash + string_nth(str,i);
	str->hashcode = tag_fixnum(hash);
}

void primitive_rehash_string(void)
{
	rehash_string(untag_string(dpop()));
}

/* untagged */
F_STRING* string(CELL capacity, CELL fill)
{
	CELL i;

	F_STRING* string = allot_string(capacity);

	for(i = 0; i < capacity; i++)
		cput(SREF(string,i),fill);

	rehash_string(string);

	return string;
}

F_STRING* grow_string(F_STRING* string, F_FIXNUM capacity, u16 fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	CELL i;
	CELL old_capacity = string_capacity(string);

	F_STRING* new_string = allot_string(capacity);

	memcpy(new_string + 1,string + 1,old_capacity * CHARS);

	for(i = old_capacity; i < capacity; i++)
		cput(SREF(new_string,i),fill);

	return new_string;
}

void primitive_grow_string(void)
{
	F_STRING* string; CELL capacity;
	maybe_garbage_collection();
	string = untag_string_fast(dpop());
	capacity = to_fixnum(dpop());
	dpush(tag_object(grow_string(string,capacity,F)));
}

F_STRING* memory_to_string(const BYTE* string, CELL length)
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
	BYTE* string = (BYTE*)unbox_unsigned_cell();
	dpush(tag_object(memory_to_string(string,length)));
}

/* untagged */
F_STRING* from_c_string(const char* c_string)
{
	return memory_to_string((BYTE*)c_string,strlen(c_string));
}

/* FFI calls this */
void box_c_string(const char* c_string)
{
	dpush(tag_object(from_c_string(c_string)));
}

/* untagged */
char* to_c_string(F_STRING* s)
{
	CELL i;
	CELL capacity = string_capacity(s);
	for(i = 0; i < capacity; i++)
	{
		u16 ch = string_nth(s,i);
		if(ch == '\0' || ch > 255)
			general_error(ERROR_C_STRING,tag_object(s));
	}

	return to_c_string_unchecked(s);
}

void string_to_memory(F_STRING* s, BYTE* string)
{
	CELL i;
	CELL capacity = string_capacity(s);
	for(i = 0; i < capacity; i++)
		string[i] = string_nth(s,i);
}

void primitive_string_to_memory(void)
{
	BYTE* address = (BYTE*)unbox_unsigned_cell();
	F_STRING* str = untag_string(dpop());
	string_to_memory(str,address);
}

/* untagged */
char* to_c_string_unchecked(F_STRING* s)
{
	CELL capacity = string_capacity(s);
	F_STRING* _c_str = allot_string(capacity / CHARS + 1);
	BYTE* c_str = (BYTE*)(_c_str + 1);
	string_to_memory(s,c_str);
	c_str[capacity] = '\0';
	return (char*)c_str;
}

/* FFI calls this */
char* unbox_c_string(void)
{
	return to_c_string(untag_string(dpop()));
}

/* FFI calls this */
u16* unbox_utf16_string(void)
{
	/* Return pointer to first character */
	return (u16*)(untag_string(dpop()) + 1);
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

F_FIXNUM string_compare(F_STRING* s1, F_STRING* s2)
{
	CELL len1 = string_capacity(s1);
	CELL len2 = string_capacity(s2);

	CELL limit = (len1 < len2 ? len1 : len2);

	CELL i = 0;
	while(i < limit)
	{
		u16 c1 = string_nth(s1,i);
		u16 c2 = string_nth(s2,i);
		if(c1 != c2)
			return c1 - c2;
		i++;
	}

	return len1 - len2;
}

void primitive_string_compare(void)
{
	F_STRING* s2 = untag_string(dpop());
	F_STRING* s1 = untag_string(dpop());

	dpush(tag_fixnum(string_compare(s1,s2)));
}
