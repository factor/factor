#include "factor.h"

/* untagged */
STRING* allot_string(CELL capacity)
{
	STRING* string = allot_object(STRING_TYPE,
		sizeof(STRING) + capacity * CHARS);
	string->capacity = capacity;
	return string;
}

/* call this after constructing a string */
/* uses same algorithm as java.lang.String for compatibility */
void hash_string(STRING* str)
{
	FIXNUM hash = 0;
	CELL i;
	for(i = 0; i < str->capacity; i++)
		hash = 31*hash + string_nth(str,i);
	str->hashcode = hash;
}

/* untagged */
STRING* string(CELL capacity, CELL fill)
{
	CELL i;

	STRING* string = allot_string(capacity);

	for(i = 0; i < capacity; i++)
		cput(SREF(string,i),fill);

	hash_string(string);

	return string;
}

STRING* grow_string(STRING* string, CELL capacity, CHAR fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	CELL i;

	STRING* new_string = allot_string(capacity);

	memcpy(new_string + 1,string + 1,string->capacity * CHARS);

	for(i = string->capacity; i < capacity; i++)
		cput(SREF(new_string,i),fill);

	return new_string;
}

/* untagged */
STRING* from_c_string(const char* c_string)
{
	CELL length = strlen(c_string);
	STRING* s = allot_string(length);
	CELL i;

	for(i = 0; i < length; i++)
	{
		cput(SREF(s,i),*c_string);
		c_string++;
	}

	hash_string(s);
	
	return s;
}

/* untagged */
char* to_c_string(STRING* s)
{
	STRING* _c_str = allot_string(s->capacity + 1 /* null byte */);
	CELL i;

	char* c_str = (char*)(_c_str + 1);
	
	for(i = 0; i < s->capacity; i++)
		c_str[i] = string_nth(s,i);

	c_str[s->capacity] = '\0';

	return c_str;
}

void primitive_stringp(void)
{
	drepl(tag_boolean(typep(STRING_TYPE,dpeek())));
}

void primitive_string_length(void)
{
	drepl(tag_fixnum(untag_string(dpeek())->capacity));
}

void primitive_string_nth(void)
{
	STRING* string = untag_string(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= string->capacity)
		range_error(tag_object(string),index,string->capacity);
	dpush(tag_fixnum(string_nth(string,index)));
}

FIXNUM string_compare_head(STRING* s1, STRING* s2, CELL len)
{
	CELL i = 0;
	while(i < len)
	{
		CHAR c1 = string_nth(s1,i);
		CHAR c2 = string_nth(s2,i);
		if(c1 != c2)
			return c1 - c2;
		i++;
	}
	
	return 0;
}

FIXNUM string_compare(STRING* s1, STRING* s2)
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
	STRING* s2 = untag_string(dpop());
	STRING* s1 = untag_string(dpop());

	dpush(tag_fixnum(string_compare(s1,s2)));
}

bool string_eq(STRING* s1, STRING* s2)
{
	if(s1->hashcode != s2->hashcode)
		return false;
	else
		return (string_compare(s1,s2) == 0);
}

void primitive_string_eq(void)
{
	STRING* s1 = untag_string(dpop());
	CELL with = dpop();
	if(typep(STRING_TYPE,with))
		dpush(tag_boolean(string_eq(s1,(STRING*)UNTAG(with))));
	else
		dpush(F);
}

void primitive_string_hashcode(void)
{
	drepl(tag_object(bignum(untag_string(dpeek())->hashcode)));
}

CELL index_of_ch(CELL index, STRING* string, CELL ch)
{
	if(index < 0)
		range_error(tag_object(string),index,string->capacity);

	while(index < string->capacity)
	{
		if(string_nth(string,index) == ch)
			return index;
		index++;
	}

	return -1;
}

INLINE FIXNUM index_of_str(FIXNUM index, STRING* string, STRING* substring)
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
	STRING* string;
	FIXNUM index;
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

INLINE STRING* substring(CELL start, CELL end, STRING* string)
{
	STRING* result;

	if(start < 0)
		range_error(tag_object(string),start,string->capacity);

	if(end < start)
		range_error(tag_object(string),end,string->capacity);

	result = allot_string(end - start);
	memcpy(result + 1,
		(void*)((CELL)(string + 1) + CHARS * start),
		CHARS * (end - start));
	hash_string(result);

	return result;
}

/* start end string -- string */
void primitive_substring(void)
{
	STRING* string = untag_string(dpop());
	CELL end = to_fixnum(dpop());
	CELL start = to_fixnum(dpop());
	dpush(tag_object(substring(start,end,string)));
}
