#include "factor.h"

RATIO* ratio(CELL numerator, CELL denominator)
{
	RATIO* ratio = allot(sizeof(RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	return ratio;
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

CELL number_eq_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return tag_boolean(
		untag_boolean(number_eq(rx->numerator,ry->numerator)) &&
		untag_boolean(number_eq(rx->denominator,ry->denominator)));
}

CELL add_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(add(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
}

CELL subtract_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(subtract(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
}

CELL multiply_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->numerator),
		multiply(rx->denominator,ry->denominator));
}

CELL divide_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator));
}

CELL divfloat_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divfloat(
		multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator));
}

CELL less_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return less(multiply(rx->numerator,ry->denominator),
		multiply(ry->numerator,rx->denominator));
}

CELL lesseq_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return lesseq(multiply(rx->numerator,ry->denominator),
		multiply(ry->numerator,rx->denominator));
}

CELL greater_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return greater(multiply(rx->numerator,ry->denominator),
		multiply(ry->numerator,rx->denominator));
}

CELL greatereq_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return greatereq(multiply(rx->numerator,ry->denominator),
		multiply(ry->numerator,rx->denominator));
}
