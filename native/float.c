#include "factor.h"

void primitive_floatp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(FLOAT_TYPE,env.dt));
}

FLOAT* to_float(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_float(tagged);
	case BIGNUM_TYPE:
		return bignum_to_float(tagged);
	case RATIO_TYPE:
		return ratio_to_float(tagged);
	case FLOAT_TYPE:
		return (FLOAT*)UNTAG(tagged);
	default:
		type_error(FLOAT_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_float(void)
{
	env.dt = tag_object(to_float(env.dt));
}

CELL number_eq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		== ((FLOAT*)UNTAG(y))->n);
}

CELL add_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		+ ((FLOAT*)UNTAG(y))->n));
}

CELL subtract_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		- ((FLOAT*)UNTAG(y))->n));
}

CELL multiply_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		* ((FLOAT*)UNTAG(y))->n));
}

CELL divide_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		/ ((FLOAT*)UNTAG(y))->n));
}

CELL divfloat_float(CELL x, CELL y)
{
	return tag_object(make_float(((FLOAT*)UNTAG(x))->n
		/ ((FLOAT*)UNTAG(y))->n));
}

CELL less_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		< ((FLOAT*)UNTAG(y))->n);
}

CELL lesseq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		<= ((FLOAT*)UNTAG(y))->n);
}

CELL greater_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		> ((FLOAT*)UNTAG(y))->n);
}

CELL greatereq_float(CELL x, CELL y)
{
	return tag_boolean(((FLOAT*)UNTAG(x))->n
		>= ((FLOAT*)UNTAG(y))->n);
}
