#include "factor.h"

/* untagged */
STRING* allot_string(CELL capacity)
{
	STRING* string = (STRING*)allot_object(STRING_TYPE,
		sizeof(STRING) + capacity * CHARS);
	string->capacity = capacity;
	return string;
}

/* call this after constructing a string */
/* uses same algorithm as java.lang.String for compatibility */
void hash_string(STRING* str)
{
	CELL hash = 0;
	int i;
	for(i = 0; i < str->capacity; i++)
		hash = 31*hash + string_nth(str,i);
	str->hashcode = hash;
}

/* untagged */
STRING* string(CELL capacity, CELL fill)
{
	int i;

	STRING* string = allot_string(capacity);

	for(i = 0; i < capacity; i++)
		put(SREF(string,i),fill);

	hash_string(string);

	return string;
}

STRING* grow_string(STRING* string, CELL capacity, CHAR fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	int i;

	STRING* new_string = allot_string(capacity);

	memcpy(new_string + 1,string + 1,string->capacity * CHARS);

	for(i = string->capacity; i < capacity; i++)
		put(SREF(new_string,i),fill);

	return new_string;
}

/* untagged */
STRING* from_c_string(char* c_string)
{
	CELL length = strlen(c_string);
	STRING* s = allot_string(length);
	int i;

	for(i = 0; i < length; i++)
	{
		put(SREF(s,i),c_string);
		c_string++;
	}

	hash_string(s);
	
	return s;
}

/* untagged */
char* to_c_string(STRING* s)
{
	STRING* _c_str = allot_string(s->capacity + 1 /* null byte */);
	int i;

	char* c_str = (char*)(_c_str + 1);
	
	for(i = 0; i < s->capacity; i++)
		c_str[i] = string_nth(s,i);

	c_str[s->capacity] = '\0';

	return c_str;
}

void primitive_stringp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(STRING_TYPE,env.dt));
}

void primitive_string_length(void)
{
	env.dt = tag_fixnum(untag_string(env.dt)->capacity);
}

void primitive_string_nth(void)
{
	STRING* string = untag_string(env.dt);
	CELL index = untag_fixnum(dpop());

	if(index < 0 || index >= string->capacity)
		range_error(string,index,string->capacity);
	env.dt = tag_fixnum(string_nth(string,index));
}

FIXNUM string_compare(STRING* s1, STRING* s2)
{
	CELL len1 = s1->capacity;
	CELL len2 = s2->capacity;

	CELL limit = (len1 < len2 ? len1 : len2);

	CELL i = 0;
	while(i < limit)
	{
		CHAR c1 = string_nth(s1,i);
		CHAR c2 = string_nth(s2,i);
		if(c1 != c2)
			return c1 - c2;
		i++;
	}
	
	return len1 - len2;
}

void primitive_string_compare(void)
{
	STRING* s1 = untag_string(env.dt);
	STRING* s2 = untag_string(dpop());

	env.dt = tag_fixnum(string_compare(s1,s2));
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
	STRING* s1 = untag_string(env.dt);
	CELL with = dpop();
	check_non_empty(with);
	if(typep(STRING_TYPE,with))
		env.dt = tag_boolean(string_eq(s1,UNTAG(with)));
	else
		env.dt = F;
}

void primitive_string_hashcode(void)
{
	env.dt = tag_fixnum(untag_string(env.dt)->hashcode);
}

INLINE CELL index_of_ch(CELL index, STRING* string, CELL ch)
{
	if(index < 0)
		range_error(string,index,string->capacity);

	while(index < string->capacity)
	{
		if(string_nth(string,index) == ch)
			return index;
		index++;
	}

	return -1;
}

INLINE CELL index_of_str(CELL index, STRING* string, STRING* substring)
{
	if(substring->capacity != 1)
		fatal_error("index_of_str not supported yet",substring);

	return index_of_ch(index,string,string_nth(substring,0));
}

/* index string substring -- index */
void primitive_index_of(void)
{
	CELL ch = env.dt;
	STRING* string;
	CELL index;
	CELL result;
	check_non_empty(ch);
	string = untag_string(dpop());
	index = untag_fixnum(dpop());
	if(TAG(ch) == FIXNUM_TYPE)
		result = index_of_ch(index,string,untag_fixnum(ch));
	else
		result = index_of_str(index,string,untag_string(ch));
	env.dt = tag_fixnum(result);
}

INLINE STRING* substring(CELL start, CELL end, STRING* string)
{
	STRING* result;

	if(start < 0 || end < start)
		range_error(string,index,string->capacity);

	result = allot_string(end - start);
	memcpy(result + 1,
		(CELL)(string + 1) + CHARS * start,
		CHARS * (end - start));
	hash_string(result);
	
	return result;
}

/* start end string -- string */
void primitive_substring(void)
{
	STRING* string = untag_string(env.dt);
	CELL end = untag_fixnum(dpop());
	CELL start = untag_fixnum(dpop());
	env.dt = tag_object(substring(start,end,string));
}
