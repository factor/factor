#include "factor.h"

RATIO* ratio(CELL numerator, CELL denominator)
{
	RATIO* ratio = allot(sizeof(RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	return ratio;
}

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
void primitive_from_fraction(void)
{
	CELL denominator = dpop();
	CELL numerator = dpop();
	if(zerop(denominator))
		raise(SIGFPE);
	if(onep(denominator))
		dpush(numerator);
	dpush(tag_ratio(ratio(numerator,denominator)));
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

void primitive_to_fraction(void)
{
	RATIO* r;

	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		dpush(tag_fixnum(1));
		break;
	case RATIO_TYPE:
		r = untag_ratio(dpeek());
		drepl(r->numerator);
		dpush(r->denominator);
		break;
	default:
		type_error(RATIONAL_TYPE,dpeek());
		break;
	}
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
