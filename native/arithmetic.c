#include "factor.h"

BIGNUM* fixnum_to_bignum(CELL n)
{
	return bignum((BIGNUM_2)untag_fixnum_fast(n));
}

RATIO* fixnum_to_ratio(CELL n)
{
	return ratio(n,tag_fixnum(1));
}

FIXNUM bignum_to_fixnum(CELL tagged)
{
	return (FIXNUM)(untag_bignum(tagged)->n);
}

RATIO* bignum_to_ratio(CELL n)
{
	return ratio(n,tag_fixnum(1));
}

void primitive_numberp(void)
{
	check_non_empty(env.dt);

	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case RATIO_TYPE:
		env.dt = T;
		break;
	default:
		env.dt = F;
		break;
	}
}

CELL to_integer(CELL tagged)
{
	RATIO* r;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		return tagged;
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return divint(r->numerator,r->denominator);
	default:
		type_error(FIXNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_integer(void)
{
	env.dt = to_integer(env.dt);
}

/* EQUALITY */
CELL number_eq_anytype(CELL x, CELL y)
{
	return F;
}

          /* op */   /* anytype */   /* integer only */
BINARY_OP(number_eq, true,           false)
BINARY_OP(add,       false,          false)
BINARY_OP(subtract,  false,          false)
BINARY_OP(multiply,  false,          false)
BINARY_OP(divide,    false,          false)
BINARY_OP(divint,    false,          true)
BINARY_OP(divmod,    false,          true)
BINARY_OP(mod,       false,          true)
BINARY_OP(and,       false,          true)
BINARY_OP(or,        false,          true)
BINARY_OP(xor,       false,          true)
BINARY_OP(shiftleft, false,          true)
BINARY_OP(shiftright,false,          true)
BINARY_OP(less,      false,          false)
BINARY_OP(lesseq,    false,          false)
BINARY_OP(greater,   false,          false)
BINARY_OP(greatereq, false,          false)
