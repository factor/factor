#include "factor.h"

RATIO* ratio(CELL numerator, CELL denominator)
{
	RATIO* ratio = allot(sizeof(RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	return ratio;
}

RATIO* to_ratio(CELL x)
{
	switch(type_of(x))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		return ratio(x,tag_fixnum(1));
	case RATIO_TYPE:
		return (RATIO*)UNTAG(x);
	default:
		type_error(RATIONAL_TYPE,x);
		return NULL;
	}
}

void primitive_ratiop(void)
{
	drepl(tag_boolean(typep(RATIO_TYPE,dpeek())));
}

void primitive_numerator(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		/* No op */
		break;
	case RATIO_TYPE:
		drepl(untag_ratio(dpeek())->numerator);
		break;
	default:
		type_error(RATIONAL_TYPE,dpeek());
		break;
	}
}

void primitive_denominator(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		drepl(tag_fixnum(1));
		break;
	case RATIO_TYPE:
		drepl(untag_ratio(dpeek())->denominator);
		break;
	default:
		type_error(RATIONAL_TYPE,dpeek());
		break;
	}
}

CELL number_eq_ratio(RATIO* x, RATIO* y)
{
	return tag_boolean(
		untag_boolean(number_eq(x->numerator,y->numerator)) &&
		untag_boolean(number_eq(x->denominator,y->denominator)));
}

CELL add_ratio(RATIO* x, RATIO* y)
{
	return divide(add(multiply(x->numerator,y->denominator),
		multiply(x->denominator,y->numerator)),
		multiply(x->denominator,y->denominator));
}

CELL subtract_ratio(RATIO* x, RATIO* y)
{
	return divide(subtract(multiply(x->numerator,y->denominator),
		multiply(x->denominator,y->numerator)),
		multiply(x->denominator,y->denominator));
}

CELL multiply_ratio(RATIO* x, RATIO* y)
{
	return divide(
		multiply(x->numerator,y->numerator),
		multiply(x->denominator,y->denominator));
}

CELL divide_ratio(RATIO* x, RATIO* y)
{
	return divide(
		multiply(x->numerator,y->denominator),
		multiply(x->denominator,y->numerator));
}

CELL divfloat_ratio(RATIO* x, RATIO* y)
{
	return divfloat(
		multiply(x->numerator,y->denominator),
		multiply(x->denominator,y->numerator));
}

CELL less_ratio(RATIO* x, RATIO* y)
{
	return less(multiply(x->numerator,y->denominator),
		multiply(y->numerator,x->denominator));
}

CELL lesseq_ratio(RATIO* x, RATIO* y)
{
	return lesseq(multiply(x->numerator,y->denominator),
		multiply(y->numerator,x->denominator));
}

CELL greater_ratio(RATIO* x, RATIO* y)
{
	return greater(multiply(x->numerator,y->denominator),
		multiply(y->numerator,x->denominator));
}

CELL greatereq_ratio(RATIO* x, RATIO* y)
{
	return greatereq(multiply(x->numerator,y->denominator),
		multiply(y->numerator,x->denominator));
}
