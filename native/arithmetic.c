#include "factor.h"

CELL tag_fixnum_or_bignum(FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_object(s48_long_to_bignum(x));
	else
		return tag_fixnum(x);
}

CELL upgraded_arithmetic_type(CELL type1, CELL type2)
{
	switch(type1)
	{
	case FIXNUM_TYPE:
		return type2;
	case BIGNUM_TYPE:
		switch(type2)
		{
		case FIXNUM_TYPE:
			return type1;
		default:
			return type2;
		}
	case RATIO_TYPE:
		switch(type2)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
			return type1;
		default:
			return type2;
		}
	case FLOAT_TYPE:
		switch(type2)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
		case RATIO_TYPE:
			return type1;
		default:
			return type2;
		}
	case COMPLEX_TYPE:
		switch(type2)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
		case RATIO_TYPE:
		case FLOAT_TYPE:
			return type1;
		default:
			return type2;
		}
	default:
		return type1;
	}
}

ARRAY* fixnum_to_bignum(CELL n)
{
	return s48_long_to_bignum(untag_fixnum_fast(n));
}

RATIO* fixnum_to_ratio(CELL n)
{
	return ratio(n,tag_fixnum(1));
}

FLOAT* fixnum_to_float(CELL n)
{
	return make_float((double)untag_fixnum_fast(n));
}

FIXNUM bignum_to_fixnum(CELL tagged)
{
	return (FIXNUM)s48_bignum_to_long(
		(ARRAY*)UNTAG(tagged));
}

RATIO* bignum_to_ratio(CELL n)
{
	return ratio(n,tag_fixnum(1));
}

FLOAT* bignum_to_float(CELL tagged)
{
	return make_float(s48_bignum_to_double(
		(ARRAY*)UNTAG(tagged)));
}

FLOAT* ratio_to_float(CELL tagged)
{
	RATIO* r = (RATIO*)UNTAG(tagged);
	return (FLOAT*)UNTAG(divfloat(r->numerator,r->denominator));
}

bool realp(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case RATIO_TYPE:
	case FLOAT_TYPE:
		return true;
		break;
	default:
		return false;
		break;
	}
}

bool numberp(CELL tagged)
{
	return realp(tagged) || type_of(tagged) == COMPLEX_TYPE;
}

void primitive_numberp(void)
{
	drepl(tag_boolean(numberp(dpeek())));
}

bool zerop(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return tagged == 0;
	case BIGNUM_TYPE:
		return BIGNUM_ZERO_P((ARRAY*)UNTAG(tagged));
	case FLOAT_TYPE:
		return ((FLOAT*)UNTAG(tagged))->n == 0.0;
	case RATIO_TYPE:
		return false;
	default:
		critical_error("Bad parameter to zerop",tagged);
		return false; /* Can't happen */
	}
}

/* EQUALITY */
CELL number_eq_anytype(CELL x, CELL y)
{
	return F;
}


BINARY_OP(number_eq)

BINARY_OP_NUMBER_ONLY(add)
BINARY_OP(add)

BINARY_OP_NUMBER_ONLY(subtract)
BINARY_OP(subtract)

BINARY_OP_NUMBER_ONLY(multiply)
BINARY_OP(multiply)

BINARY_OP_NUMBER_ONLY(divide)
BINARY_OP(divide)

BINARY_OP_INTEGER_ONLY(divint)
BINARY_OP_NUMBER_ONLY(divint)
BINARY_OP(divint)

BINARY_OP_NUMBER_ONLY(divfloat)
BINARY_OP(divfloat)

BINARY_OP_INTEGER_ONLY(divmod)
BINARY_OP_NUMBER_ONLY(divmod)
BINARY_OP(divmod)

BINARY_OP_INTEGER_ONLY(mod)
BINARY_OP_NUMBER_ONLY(mod)
BINARY_OP(mod)

BINARY_OP_INTEGER_ONLY(and)
BINARY_OP_NUMBER_ONLY(and)
BINARY_OP(and)

BINARY_OP_INTEGER_ONLY(or)
BINARY_OP_NUMBER_ONLY(or)
BINARY_OP(or)

BINARY_OP_INTEGER_ONLY(xor)
BINARY_OP_NUMBER_ONLY(xor)
BINARY_OP(xor)

BINARY_OP_FIXNUM(shift)

BINARY_OP_NUMBER_ONLY(less)
BINARY_OP(less)

BINARY_OP_NUMBER_ONLY(lesseq)
BINARY_OP(lesseq)

BINARY_OP_NUMBER_ONLY(greater)
BINARY_OP(greater)

BINARY_OP_NUMBER_ONLY(greatereq)
BINARY_OP(greatereq)

UNARY_OP_INTEGER_ONLY(not)
UNARY_OP_NUMBER_ONLY(not)
UNARY_OP(not)
