#include "factor.h"

SBUF* sbuf(FIXNUM capacity)
{
	SBUF* sbuf = (SBUF*)allot_object(SBUF_TYPE,sizeof(SBUF));
	sbuf->top = 0;
	sbuf->string = string(capacity,'\0');
	return sbuf;
}

void primitive_sbufp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(SBUF_TYPE,env.dt));
}

void primitive_sbuf(void)
{
	env.dt = tag_object(sbuf(untag_fixnum(env.dt)));
}

void primitive_sbuf_length(void)
{
	env.dt = tag_fixnum(untag_sbuf(env.dt)->top);
}

void primitive_set_sbuf_length(void)
{
	SBUF* sbuf = untag_sbuf(env.dt);
	FIXNUM length = untag_fixnum(dpop());
	sbuf->top = length;
	if(length < 0)
		range_error(env.dt,index,length);
	else if(length > sbuf->string->capacity)
		sbuf->string = grow_string(sbuf->string,length,F);
	env.dt = dpop(); /* don't forget this! */
}

void primitive_sbuf_nth(void)
{
	SBUF* sbuf = untag_sbuf(env.dt);
	CELL index = untag_fixnum(dpop());

	if(index < 0 || index >= sbuf->top)
		range_error(env.dt,index,sbuf->top);
	env.dt = string_nth(sbuf->string,index);
}

void sbuf_ensure_capacity(SBUF* sbuf, int top)
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
	SBUF* sbuf = untag_sbuf(env.dt);
	FIXNUM index = untag_fixnum(dpop());
	CELL value = dpop();
	check_non_empty(value);

	set_sbuf_nth(sbuf,index,value);
	
	env.dt = dpop(); /* don't forget this! */
}

void sbuf_append_string(SBUF* sbuf, STRING* string)
{
	CELL top = sbuf->top;
	CELL strlen = string->capacity;
	sbuf_ensure_capacity(sbuf,top + strlen);
	memcpy((CELL)sbuf->string + sizeof(STRING) + top * CHARS,
		(CELL)string + sizeof(STRING),strlen * CHARS);
}

void primitive_sbuf_append(void)
{
	SBUF* sbuf = untag_sbuf(env.dt);
	CELL object = dpop();
	check_non_empty(object);
	env.dt = dpop();
	if(TAG(object) == FIXNUM_TYPE)
		set_sbuf_nth(sbuf,sbuf->top,untag_fixnum(object));
	else
		sbuf_append_string(sbuf,untag_string(object));
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
	env.dt = tag_object(sbuf_to_string(untag_sbuf(env.dt)));
}

void fixup_sbuf(SBUF* sbuf)
{
	sbuf->string = (CELL)sbuf->string + (active->base - relocation_base);
}

void collect_sbuf(SBUF* sbuf)
{
	sbuf->string = copy_untagged_object(sbuf->string,
		sizeof(sbuf->string) + sbuf->string->capacity);
}
