#include "factor.h"

/* untagged */
F_STRING* allot_string(F_FIXNUM capacity)
{
	F_STRING* string;
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));
	string = allot_object(STRING_TYPE,
		sizeof(F_STRING) + capacity * CHARS);
	string->capacity = capacity;
	return string;
}

/* call this after constructing a string */
/* uses same algorithm as java.lang.String for compatibility with
images generated from Java Factor. */
F_FIXNUM hash_string(F_STRING* str, F_FIXNUM len)
{
	F_FIXNUM hash = 0;
	CELL i;
	for(i = 0; i < len; i++)
		hash = 31*hash + string_nth(str,i);
	return hash;
}

void rehash_string(F_STRING* str)
{
	str->hashcode = hash_string(str,str->capacity);
}

/* untagged */
F_STRING* string(F_FIXNUM capacity, CELL fill)
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

	F_STRING* new_string = allot_string(capacity);

	memcpy(new_string + 1,string + 1,string->capacity * CHARS);

	for(i = string->capacity; i < capacity; i++)
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

	for(i = 0; i < s->capacity; i++)
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
	for(i = 0; i < s->capacity; i++)
		string[i] = string_nth(s,i);
}

void primitive_string_to_memory(void)
{
	F_STRING* str = untag_string(dpop());
	BYTE* address = (BYTE*)unbox_cell();
	string_to_memory(str,address);
}

/* untagged */
BYTE* to_c_string_unchecked(F_STRING* s)
{
	F_STRING* _c_str = allot_string(s->capacity / CHARS + 1);
	BYTE* c_str = (BYTE*)(_c_str + 1);
	string_to_memory(s,c_str);
	c_str[s->capacity] = '\0';
	return c_str;
}

/* FFI calls this */
BYTE* unbox_c_string(void)
{
	return to_c_string(untag_string(dpop()));
}

void primitive_string_length(void)
{
	drepl(tag_fixnum(untag_string(dpeek())->capacity));
}

void primitive_string_nth(void)
{
	F_STRING* string = untag_string(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= string->capacity)
		range_error(tag_object(string),index,string->capacity);
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
	CELL len1 = s1->capacity;
	CELL len2 = s2->capacity;

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

bool string_eq(F_STRING* s1, F_STRING* s2)
{
	if(s1 == s2)
		return true;
	else if(s1->hashcode != s2->hashcode)
		return false;
	else
		return (string_compare(s1,s2) == 0);
}

void primitive_string_eq(void)
{
	F_STRING* s1 = untag_string(dpop());
	CELL with = dpop();
	if(typep(STRING_TYPE,with))
		dpush(tag_boolean(string_eq(s1,(F_STRING*)UNTAG(with))));
	else
		dpush(F);
}

void primitive_string_hashcode(void)
{
	drepl(tag_fixnum(untag_string(dpeek())->hashcode));
}

CELL index_of_ch(CELL index, F_STRING* string, CELL ch)
{
	while(index < string->capacity)
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
	CELL limit = string->capacity - substring->capacity;
	CELL scan;

	if(substring->capacity == 1)
		return index_of_ch(index,string,string_nth(substring,0));

	if(substring->capacity > string->capacity)
		return -1;

outer:	if(i <= limit)
	{
		for(scan = 0; scan < substring->capacity; scan++)
		{
			if(string_nth(string,i + scan)
				!= string_nth(substring,scan))
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
	F_STRING* string;
	F_FIXNUM index;
	CELL result;
	string = untag_string(dpop());
	index = to_fixnum(dpop());
	if(index < 0 || index > string->capacity)
	{
		range_error(tag_object(string),index,string->capacity);
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

	if(start < 0)
		range_error(tag_object(string),start,string->capacity);

	if(end < start || end > string->capacity)
		range_error(tag_object(string),end,string->capacity);

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

	maybe_garbage_collection();

	s = untag_string(dpeek());
	s = string_clone(s,s->capacity);
	string_reverse(s,s->capacity);
	rehash_string(s);
	drepl(tag_object(s));
}
