#include "factor.h"

F_SBUF* sbuf(F_FIXNUM capacity)
{
	F_SBUF* sbuf = allot_object(SBUF_TYPE,sizeof(F_SBUF));
	sbuf->top = 0;
	sbuf->string = tag_object(string(capacity,'\0'));
	return sbuf;
}

void primitive_sbuf(void)
{
	maybe_garbage_collection();
	drepl(tag_object(sbuf(to_fixnum(dpeek()))));
}

void primitive_sbuf_length(void)
{
	drepl(tag_fixnum(untag_sbuf(dpeek())->top));
}

void primitive_set_sbuf_length(void)
{
	F_SBUF* sbuf;
	F_FIXNUM length;
	F_STRING* str;

	maybe_garbage_collection();

	sbuf = untag_sbuf(dpop());
	str = untag_string(sbuf->string);
	length = to_fixnum(dpop());
	if(length < 0)
		range_error(tag_object(sbuf),0,to_fixnum(length),sbuf->top);
	sbuf->top = length;
	if(length > str->capacity)
		sbuf->string = tag_object(grow_string(str,length,F));
}

void primitive_sbuf_nth(void)
{
	F_SBUF* sbuf = untag_sbuf(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= sbuf->top)
		range_error(tag_object(sbuf),0,to_fixnum(index),sbuf->top);
	dpush(string_nth(untag_string(sbuf->string),index));
}

void sbuf_ensure_capacity(F_SBUF* sbuf, F_FIXNUM top)
{
	F_STRING* string = untag_string(sbuf->string);
	CELL capacity = string->capacity;
	if(top >= capacity)
		sbuf->string = tag_object(grow_string(string,top * 2 + 1,F));
	sbuf->top = top;
}

void set_sbuf_nth(F_SBUF* sbuf, CELL index, uint16_t value)
{
	if(index < 0)
		range_error(tag_object(sbuf),0,to_fixnum(index),sbuf->top);
	else if(index >= sbuf->top)
		sbuf_ensure_capacity(sbuf,index + 1);

	/* the following does not check bounds! */
	set_string_nth(untag_string(sbuf->string),index,value);
}

void primitive_set_sbuf_nth(void)
{
	F_SBUF* sbuf;
	F_FIXNUM index;
	CELL value;

	maybe_garbage_collection();

	sbuf = untag_sbuf(dpop());
	index = to_fixnum(dpop());
	value = dpop();

	set_sbuf_nth(sbuf,index,value);
}

void sbuf_append_string(F_SBUF* sbuf, F_STRING* string)
{
	CELL top = sbuf->top;
	CELL strlen = string->capacity;
	F_STRING* str;
	sbuf_ensure_capacity(sbuf,top + strlen);
	str = untag_string(sbuf->string);
	memcpy((void*)((CELL)str + sizeof(F_STRING) + top * CHARS),
		(void*)((CELL)string + sizeof(F_STRING)),strlen * CHARS);
}

void primitive_sbuf_append(void)
{
	F_SBUF* sbuf;
	CELL object;

	maybe_garbage_collection();

	sbuf = untag_sbuf(dpop());
	object = dpop();

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
		type_error(TEXT_TYPE,object);
		break;
	}
}

void primitive_sbuf_to_string(void)
{
	F_SBUF* sbuf;
	F_STRING* s;

	maybe_garbage_collection();

	sbuf = untag_sbuf(dpeek());
	s = string_clone(untag_string(sbuf->string),sbuf->top);
	rehash_string(s);
	drepl(tag_object(s));
}

void primitive_sbuf_reverse(void)
{
	F_SBUF* sbuf = untag_sbuf(dpop());
	string_reverse(untag_string(sbuf->string),sbuf->top);
}

void primitive_sbuf_clone(void)
{
	F_SBUF* s;
	F_SBUF* new_s;

	maybe_garbage_collection();

	s = untag_sbuf(dpeek());
	new_s = sbuf(s->top);

	sbuf_append_string(new_s,untag_string(s->string));
	drepl(tag_object(new_s));
}

bool sbuf_eq(F_SBUF* s1, F_SBUF* s2)
{
	if(s1 == s2)
		return true;
	else if(s1->top == s2->top)
	{
		return (string_compare_head(untag_string(s1->string),
			untag_string(s2->string),s1->top) == 0);
	}
	else
		return false;
}

void primitive_sbuf_eq(void)
{
	F_SBUF* s1 = untag_sbuf(dpop());
	CELL with = dpop();
	if(typep(SBUF_TYPE,with))
		dpush(tag_boolean(sbuf_eq(s1,(F_SBUF*)UNTAG(with))));
	else
		dpush(F);
}

void primitive_sbuf_hashcode(void)
{
	F_SBUF* sbuf = untag_sbuf(dpop());
	dpush(tag_fixnum(hash_string(untag_string(sbuf->string),sbuf->top)));
}

void fixup_sbuf(F_SBUF* sbuf)
{
	fixup(&sbuf->string);
}

void collect_sbuf(F_SBUF* sbuf)
{
	copy_object(&sbuf->string);
}
