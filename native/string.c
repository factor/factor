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
	cput(SREF(string,capacity),(uint16_t)'\0');
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

F_STRING* grow_string(F_STRING* string, F_FIXNUM capacity, uint16_t fill)
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

INLINE F_STRING* memory_to_string(const BYTE* string, CELL length)
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
	CELL length = unbox_cell();
	BYTE* string = (BYTE*)unbox_cell();
	dpush(tag_object(memory_to_string(string,length)));
}

/* untagged */
F_STRING* from_c_string(const BYTE* c_string)
{
	return memory_to_string(c_string,strlen(c_string));
}

/* FFI calls this */
void box_c_string(const BYTE* c_string)
{
	dpush(tag_object(from_c_string(c_string)));
}

/* untagged */
BYTE* to_c_string(F_STRING* s)
{
	CELL i;
	CELL capacity = string_capacity(s);
	for(i = 0; i < capacity; i++)
	{
		uint16_t ch = string_nth(s,i);
		if(ch == '\0' || ch > 255)
			general_error(ERROR_C_STRING,tag_object(s));
	}

	return to_c_string_unchecked(s);
}

INLINE void string_to_memory(F_STRING* s, BYTE* string)
{
	CELL i;
	CELL capacity = string_capacity(s);
	for(i = 0; i < capacity; i++)
		string[i] = string_nth(s,i);
}

void primitive_string_to_memory(void)
{
	BYTE* address = (BYTE*)unbox_cell();
	F_STRING* str = untag_string(dpop());
	string_to_memory(str,address);
}

/* untagged */
BYTE* to_c_string_unchecked(F_STRING* s)
{
	CELL capacity = string_capacity(s);
	F_STRING* _c_str = allot_string(capacity / CHARS + 1);
	BYTE* c_str = (BYTE*)(_c_str + 1);
	string_to_memory(s,c_str);
	c_str[capacity] = '\0';
	return c_str;
}

/* FFI calls this */
BYTE* unbox_c_string(void)
{
	return to_c_string(untag_string(dpop()));
}

/* FFI calls this */
uint16_t* unbox_utf16_string(void)
{
	/* Return pointer to first character */
	return (uint16_t*)(untag_string(dpop()) + 1);
}

void primitive_string_nth(void)
{
	F_STRING* string = untag_string(dpop());
	CELL index = to_fixnum(dpop());
	CELL capacity = string_capacity(string);

	if(index < 0 || index >= capacity)
		range_error(tag_object(string),0,tag_fixnum(index),capacity);
	dpush(tag_fixnum(string_nth(string,index)));
}

F_FIXNUM string_compare_head(F_STRING* s1, F_STRING* s2, CELL len)
{
	CELL i = 0;
	while(i < len)
	{
		uint16_t c1 = string_nth(s1,i);
		uint16_t c2 = string_nth(s2,i);
		if(c1 != c2)
			return c1 - c2;
		i++;
	}
	
	return 0;
}

F_FIXNUM string_compare(F_STRING* s1, F_STRING* s2)
{
	CELL len1 = string_capacity(s1);
	CELL len2 = string_capacity(s2);

	CELL limit = (len1 < len2 ? len1 : len2);

	CELL comp = string_compare_head(s1,s2,limit);
	if(comp != 0)
		return comp;
	else
		return len1 - len2;
}

void primitive_string_compare(void)
{
	F_STRING* s2 = untag_string(dpop());
	F_STRING* s1 = untag_string(dpop());

	dpush(tag_fixnum(string_compare(s1,s2)));
}

void primitive_string_eq(void)
{
	F_STRING* s1 = untag_string(dpop());
	CELL with = dpop();
	if(type_of(with) == STRING_TYPE)
	{
		F_STRING* s2 = (F_STRING*)UNTAG(with);
		if(s1->hashcode != s2->hashcode)
			dpush(F);
		else if(s1 == s2)
			dpush(T);
		else
			dpush(tag_boolean((string_compare(s1,s2) == 0)));
	}
	else
		dpush(F);
}

CELL index_of_ch(CELL index, F_STRING* string, CELL ch)
{
	CELL capacity = string_capacity(string);
	
	while(index < capacity)
	{
		if(string_nth(string,index) == ch)
			return index;
		index++;
	}

	return -1;
}

INLINE F_FIXNUM index_of_str(F_FIXNUM index, F_STRING* string, F_STRING* substring)
{
	CELL i = index;
	CELL str_cap = string_capacity(string);
	CELL substr_cap = string_capacity(substring);
	F_FIXNUM limit = str_cap - substr_cap;
	CELL scan;

	if(substr_cap == 1)
		return index_of_ch(index,string,string_nth(substring,0));

	if(limit < 0)
		return -1;

outer:	if(i <= limit)
	{
		for(scan = 0; scan < substr_cap; scan++)
		{
			if(string_nth(string,i + scan) != string_nth(substring,scan))
			{
				i++;
				goto outer;
			}
		}

		/* We reached here and every char in the substring matched */
		return i;
	}

	/* We reached here and nothing matched */
	return -1;
}

/* index string substring -- index */
void primitive_index_of(void)
{
	CELL ch = dpop();
	F_STRING* string = untag_string(dpop());
	CELL capacity = string_capacity(string);
	F_FIXNUM index = to_fixnum(dpop());
	CELL result;
	if(index < 0 || index > capacity)
	{
		range_error(tag_object(string),0,tag_fixnum(index),capacity);
		result = -1; /* can't happen */
	}
	else if(TAG(ch) == FIXNUM_TYPE)
		result = index_of_ch(index,string,to_fixnum(ch));
	else
		result = index_of_str(index,string,untag_string(ch));
	dpush(tag_fixnum(result));
}

INLINE F_STRING* substring(CELL start, CELL end, F_STRING* string)
{
	F_STRING* result;
	CELL capacity = string_capacity(string);

	if(start < 0)
		range_error(tag_object(string),0,tag_fixnum(start),capacity);

	if(end < start || end > capacity)
		range_error(tag_object(string),0,tag_fixnum(end),capacity);

	result = allot_string(end - start);
	memcpy(result + 1,
		(void*)((CELL)(string + 1) + CHARS * start),
		CHARS * (end - start));
	rehash_string(result);

	return result;
}

/* start end string -- string */
void primitive_substring(void)
{
	F_STRING* string;
	CELL end, start;

	maybe_garbage_collection();

	string = untag_string(dpop());
	end = to_fixnum(dpop());
	start = to_fixnum(dpop());
	dpush(tag_object(substring(start,end,string)));
}

/* DESTRUCTIVE - don't use with user-visible strings */
void string_reverse(F_STRING* s, int len)
{
	int i, j;
	uint16_t ch1, ch2;
	for(i = 0; i < len / 2; i++)
	{
		j = len - i - 1;
		ch1 = string_nth(s,i);
		ch2 = string_nth(s,j);
		set_string_nth(s,j,ch1);
		set_string_nth(s,i,ch2);
	}
}

/* Doesn't rehash the string! */
F_STRING* string_clone(F_STRING* s, int len)
{
	F_STRING* copy = allot_string(len);
	memcpy(copy + 1,s + 1,len * CHARS);
	return copy;
}

void primitive_string_reverse(void)
{
	F_STRING* s;
	CELL capacity;

	maybe_garbage_collection();

	s = untag_string(dpeek());
	capacity = string_capacity(s);
	s = string_clone(s,capacity);
	string_reverse(s,capacity);
	rehash_string(s);
	drepl(tag_object(s));
}
