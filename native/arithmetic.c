#include "factor.h"

CELL tag_integer(FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_object(s48_long_to_bignum(x));
	else
		return tag_fixnum(x);
}

CELL tag_cell(CELL x)
{
	if(x > FIXNUM_MAX)
		return tag_object(s48_ulong_to_bignum(x));
	else
		return tag_fixnum(x);
}

CELL to_cell(CELL x)
{
	switch(type_of(x))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(x);
	case BIGNUM_TYPE:
		/* really need bignum_to_ulong! */
		return s48_bignum_to_long(untag_bignum(x));
	default:
		type_error(INTEGER_TYPE,x);
		return 0;
	}
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

void primitive_arithmetic_type(void)
{
	CELL type2 = type_of(dpop());
	CELL type1 = type_of(dpop());
	dpush(tag_fixnum(upgraded_arithmetic_type(type1,type2)));
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

void primitive_numberp(void)
{
	CELL tagged = dpeek();
	drepl(tag_boolean(realp(tagged) || type_of(tagged) == COMPLEX_TYPE));
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
	case COMPLEX_TYPE:
		return false;
	default:
		type_error(NUMBER_TYPE,tagged);
		return false; /* Can't happen */
	}
}

bool onep(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return tagged == tag_fixnum(1);
	case BIGNUM_TYPE:
		return BIGNUM_ONE_P((ARRAY*)UNTAG(tagged),0);
	case FLOAT_TYPE:
		return ((FLOAT*)UNTAG(tagged))->n == 1.0;
	case RATIO_TYPE:
	case COMPLEX_TYPE:
		return false;
	default:
		type_error(NUMBER_TYPE,tagged);
		return false; /* Can't happen */
	}
}
