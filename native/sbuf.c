#include "factor.h"

SBUF* sbuf(FIXNUM capacity)
{
	SBUF* sbuf = allot_object(SBUF_TYPE,sizeof(SBUF));
	sbuf->top = 0;
	sbuf->string = string(capacity,'\0');
	return sbuf;
}

void primitive_sbufp(void)
{
	drepl(tag_boolean(typep(SBUF_TYPE,dpeek())));
}

void primitive_sbuf(void)
{
	drepl(tag_object(sbuf(to_fixnum(dpeek()))));
}

void primitive_sbuf_length(void)
{
	drepl(tag_fixnum(untag_sbuf(dpeek())->top));
}

void primitive_set_sbuf_length(void)
{
	SBUF* sbuf = untag_sbuf(dpop());
	FIXNUM length = to_fixnum(dpop());
	if(length < 0)
		range_error(tag_object(sbuf),length,sbuf->top);
	sbuf->top = length;
	if(length > sbuf->string->capacity)
		sbuf->string = grow_string(sbuf->string,length,F);
}

void primitive_sbuf_nth(void)
{
	SBUF* sbuf = untag_sbuf(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= sbuf->top)
		range_error(tag_object(sbuf),index,sbuf->top);
	dpush(string_nth(sbuf->string,index));
}

void sbuf_ensure_capacity(SBUF* sbuf, FIXNUM top)
{
	STRING* string = sbuf->string;
	CELL capacity = string->capacity;
	if(top >= capacity)
		sbuf->string = grow_string(string,top * 2 + 1,F);
	sbuf->top = top;
}

void set_sbuf_nth(SBUF* sbuf, CELL index, CHAR value)
{
	if(index < 0)
		range_error(tag_object(sbuf),index,sbuf->top);
	else if(index >= sbuf->top)
		sbuf_ensure_capacity(sbuf,index + 1);

	/* the following does not check bounds! */
	set_string_nth(sbuf->string,index,value);
}

void primitive_set_sbuf_nth(void)
{
	SBUF* sbuf = untag_sbuf(dpop());
	FIXNUM index = to_fixnum(dpop());
	CELL value = dpop();

	set_sbuf_nth(sbuf,index,value);
}

void sbuf_append_string(SBUF* sbuf, STRING* string)
{
	CELL top = sbuf->top;
	CELL strlen = string->capacity;
	sbuf_ensure_capacity(sbuf,top + strlen);
	memcpy((void*)((CELL)sbuf->string + sizeof(STRING) + top * CHARS),
		(void*)((CELL)string + sizeof(STRING)),strlen * CHARS);
}

void primitive_sbuf_append(void)
{
	SBUF* sbuf = untag_sbuf(dpop());
	CELL object = dpop();
	switch(type_of(object))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		set_sbuf_nth(sbuf,sbuf->top,to_fixnum(object));
		break;
	case STRING_TYPE:
		sbuf_append_string(sbuf,untag_string(object));
		break;
	default:
		type_error(STRING_TYPE,object);
		break;
	}
}

STRING* sbuf_to_string(SBUF* sbuf)
{
	STRING* string = allot_string(sbuf->top);
	memcpy(string + 1,sbuf->string + 1,sbuf->top * CHARS);
	hash_string(string);
	return string;
}

void primitive_sbuf_to_string(void)
{
	drepl(tag_object(sbuf_to_string(untag_sbuf(dpeek()))));
}

void primitive_sbuf_reverse(void)
{
	SBUF* sbuf = untag_sbuf(dpop());
	int i, j;
	CHAR ch1, ch2;
	for(i = 0; i < sbuf->top / 2; i++)
	{
		j = sbuf->top - i - 1;
		ch1 = string_nth(sbuf->string,i);
		ch2 = string_nth(sbuf->string,j);
		set_string_nth(sbuf->string,j,ch1);
		set_string_nth(sbuf->string,i,ch2);
	}
}

void primitive_sbuf_clone(void)
{
	SBUF* s = untag_sbuf(dpeek());
	SBUF* new_s = sbuf(s->top);
	sbuf_append_string(new_s,s->string);
	drepl(tag_object(new_s));
}

bool sbuf_eq(SBUF* s1, SBUF* s2)
{
	if(s1->top == s2->top)
		return (string_compare_head(s1->string,s2->string,s1->top) == 0);
	else
		return false;
}

void primitive_sbuf_eq(void)
{
	SBUF* s1 = untag_sbuf(dpop());
	CELL with = dpop();
	if(typep(SBUF_TYPE,with))
		dpush(tag_boolean(sbuf_eq(s1,(SBUF*)UNTAG(with))));
	else
		dpush(F);
}

void fixup_sbuf(SBUF* sbuf)
{
	sbuf->string = fixup_untagged_string(sbuf->string);
}

void collect_sbuf(SBUF* sbuf)
{
	sbuf->string = copy_untagged_string(sbuf->string);
}
