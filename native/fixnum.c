#include "factor.h"

FIXNUM to_fixnum(CELL tagged)
{
	RATIO* r;
	ARRAY* x;
	ARRAY* y;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return (FIXNUM)s48_bignum_to_long((ARRAY*)UNTAG(tagged));
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		x = to_bignum(r->numerator);
		y = to_bignum(r->denominator);
		return to_fixnum(tag_object(s48_bignum_quotient(x,y)));
	case FLOAT_TYPE:
		f = (FLOAT*)UNTAG(tagged);
		return (FIXNUM)f->n;
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

void primitive_to_fixnum(void)
{
	drepl(tag_fixnum(to_fixnum(dpeek())));
}

void primitive_fixnum_eq(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_boolean(x == y));
}

void primitive_fixnum_add(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_integer(x + y));
}

void primitive_fixnum_subtract(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_integer(x - y));
}

/**
 * Multiply two integers, and trap overflow.
 * Thanks to David Blaikie (The_Vulture from freenode #java) for the hint.
 */
void primitive_fixnum_multiply(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());

	if(x == 0 || y == 0)
		dpush(tag_fixnum(0));
	else
	{
		FIXNUM prod = x * y;
		/* if this is not equal, we have overflow */
		if(prod / x == y)
			dpush(tag_integer(prod));
		else
		{
			dpush(tag_object(
				s48_bignum_multiply(
					s48_long_to_bignum(x),
					s48_long_to_bignum(y))));
		}
	}
}

void primitive_fixnum_divint(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_integer(x / y));
}

void primitive_fixnum_divfloat(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_object(make_float((double)x / (double)y)));
}

void primitive_fixnum_divmod(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_integer(x / y));
	dpush(tag_integer(x % y));
}

void primitive_fixnum_mod(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_fixnum(x % y));
}

void primitive_fixnum_and(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_fixnum(x & y));
}

void primitive_fixnum_or(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_fixnum(x | y));
}

void primitive_fixnum_xor(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_fixnum(x ^ y));
}

/*
 * Note the hairy overflow check.
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
void primitive_fixnum_shift(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());

	if(y < 0)
	{
		if(y <= -WORD_SIZE)
			dpush(x < 0 ? tag_fixnum(-1) : tag_fixnum(0));
		else
			dpush(tag_fixnum(x >> -y));
		return;
	}
	else if(y == 0)
	{
		dpush(tag_fixnum(x));
		return;
	}
	else if(y < WORD_SIZE - TAG_BITS)
	{
		FIXNUM mask = (1 << (WORD_SIZE - 1 - TAG_BITS - y));
		if(x > 0)
			mask = -mask;

		if((x & mask) == 0)
		{
			dpush(tag_fixnum(x << y));
			return;
		}
	}

	dpush(tag_object(s48_bignum_arithmetic_shift(
		s48_long_to_bignum(x),y)));
}

void primitive_fixnum_less(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_boolean(x < y));
}

void primitive_fixnum_lesseq(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_boolean(x <= y));
}

void primitive_fixnum_greater(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_boolean(x > y));
}

void primitive_fixnum_greatereq(void)
{
	FIXNUM y = to_fixnum(dpop());
	FIXNUM x = to_fixnum(dpop());
	dpush(tag_boolean(x >= y));
}

void primitive_fixnum_not(void)
{
	drepl(tag_fixnum(~to_fixnum(dpeek())));
}
