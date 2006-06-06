#include "factor.h"

F_FIXNUM to_fixnum(CELL tagged)
{
	F_RATIO* r;
	F_ARRAY* x;
	F_ARRAY* y;
	F_FLOAT* f;

	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return (F_FIXNUM)s48_bignum_to_fixnum((F_ARRAY*)UNTAG(tagged));
	case RATIO_TYPE:
		r = (F_RATIO*)UNTAG(tagged);
		x = to_bignum(r->numerator);
		y = to_bignum(r->denominator);
		return to_fixnum(tag_bignum(s48_bignum_quotient(x,y)));
	case FLOAT_TYPE:
		f = (F_FLOAT*)UNTAG(tagged);
		return (F_FIXNUM)f->n;
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

void primitive_to_fixnum(void)
{
	drepl(tag_fixnum(to_fixnum(dpeek())));
}

#define POP_FIXNUMS(x,y) \
	F_FIXNUM x, y; \
	y = untag_fixnum_fast(dpop()); \
	x = untag_fixnum_fast(dpop());
	
/* The fixnum arithmetic operations defined in C are relatively slow.
The Factor compiler has optimized assembly intrinsics for all these
operations. */
void primitive_fixnum_add(void)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x + y);
}

void primitive_fixnum_add_fast(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x + y));
}

void primitive_fixnum_subtract(void)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x - y);
}

void primitive_fixnum_subtract_fast(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x - y));
}

/**
 * Multiply two integers, and trap overflow.
 * Thanks to David Blaikie (The_Vulture from freenode #java) for the hint.
 */
void primitive_fixnum_multiply(void)
{
	POP_FIXNUMS(x,y)

	if(x == 0 || y == 0)
		dpush(tag_fixnum(0));
	else
	{
		F_FIXNUM prod = x * y;
		/* if this is not equal, we have overflow */
		if(prod / x == y)
			box_signed_cell(prod);
		else
		{
			dpush(tag_bignum(
				s48_bignum_multiply(
					s48_fixnum_to_bignum(x),
					s48_fixnum_to_bignum(y))));
		}
	}
}

void primitive_fixnum_divint(void)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x / y);
}

void primitive_fixnum_divfloat(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_float((double)x / (double)y));
}

void primitive_fixnum_divmod(void)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x / y);
	box_signed_cell(x % y);
}

void primitive_fixnum_mod(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x % y));
}

void primitive_fixnum_and(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x & y));
}

void primitive_fixnum_or(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x | y));
}

void primitive_fixnum_xor(void)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x ^ y));
}

/*
 * Note the hairy overflow check.
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
void primitive_fixnum_shift(void)
{
	POP_FIXNUMS(x,y)

	if(x == 0 || y == 0)
	{
		dpush(tag_fixnum(x));
		return;
	}
	else if(y < 0)
	{
		if(y <= -WORD_SIZE)
			dpush(x < 0 ? tag_fixnum(-1) : tag_fixnum(0));
		else
			dpush(tag_fixnum(x >> -y));
		return;
	}
	else if(y < WORD_SIZE - TAG_BITS)
	{
		F_FIXNUM mask = -(1 << (WORD_SIZE - 1 - TAG_BITS - y));
		if((x > 0 && (x & mask) == 0) || (x & mask) == mask)
		{
			dpush(tag_fixnum(x << y));
			return;
		}
	}

	dpush(tag_bignum(s48_bignum_arithmetic_shift(
		s48_fixnum_to_bignum(x),y)));
}

void primitive_fixnum_less(void)
{
	POP_FIXNUMS(x,y)
	box_boolean(x < y);
}

void primitive_fixnum_lesseq(void)
{
	POP_FIXNUMS(x,y)
	box_boolean(x <= y);
}

void primitive_fixnum_greater(void)
{
	POP_FIXNUMS(x,y)
	box_boolean(x > y);
}

void primitive_fixnum_greatereq(void)
{
	POP_FIXNUMS(x,y)
	box_boolean(x >= y);
}

void primitive_fixnum_not(void)
{
	drepl(tag_fixnum(~untag_fixnum_fast(dpeek())));
}

#define DEFBOX(name,type)                                                      \
void name (type integer)                                                       \
{                                                                              \
	dpush(tag_integer(integer));                                           \
}

#define DEFUNBOX(name,type)                                                    \
type name(void)                                                                \
{                                                                              \
	return to_fixnum(dpop());                                              \
}

DEFBOX(box_signed_1, signed char)
DEFBOX(box_signed_2, signed short)
DEFBOX(box_unsigned_1, unsigned char)
DEFBOX(box_unsigned_2, unsigned short)
DEFUNBOX(unbox_signed_1, signed char)
DEFUNBOX(unbox_signed_2, signed short)
DEFUNBOX(unbox_unsigned_1, unsigned char)
DEFUNBOX(unbox_unsigned_2, unsigned short) 
