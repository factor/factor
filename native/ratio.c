#include "factor.h"

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
	else
	{
		RATIO* ratio = allot(sizeof(RATIO));
		ratio->numerator = numerator;
		ratio->denominator = denominator;
		dpush(tag_ratio(ratio));
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
