#include "factor.h"

void init_bignum(void)
{
	bignum_zero = bignum_allocate(0,0);

	bignum_pos_one = bignum_allocate(1,0);
	(BIGNUM_REF (bignum_pos_one, 0)) = 1;

	bignum_neg_one = bignum_allocate(1,1);
	(BIGNUM_REF (bignum_neg_one, 0)) = 1;
}

void primitive_bignump(void)
{
	drepl(tag_boolean(typep(BIGNUM_TYPE,dpeek())));
}

ARRAY* to_bignum(CELL tagged)
{
	RATIO* r;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_bignum(tagged);
	case BIGNUM_TYPE:
		return (ARRAY*)UNTAG(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_bignum(divint(r->numerator,r->denominator));
	case FLOAT_TYPE:
		f = (FLOAT*)UNTAG(tagged);
		return s48_double_to_bignum(f->n);
	default:
		type_error(BIGNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_bignum(void)
{
	drepl(tag_object(to_bignum(dpeek())));
}

CELL number_eq_bignum(ARRAY* x, ARRAY* y)
{
	return tag_boolean(s48_bignum_equal_p(x,y));
}

CELL add_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_add(x,y));
}

CELL subtract_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_subtract(x,y));
}

CELL multiply_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_multiply(x,y));
}

CELL gcd_bignum(ARRAY* x, ARRAY* y)
{
	ARRAY* t;

	if(BIGNUM_NEGATIVE_P(x))
		x = s48_bignum_negate(x);
	if(BIGNUM_NEGATIVE_P(y))
		y = s48_bignum_negate(y);

	if(s48_bignum_compare(x,y) == bignum_comparison_greater)
	{
		t = x;
		x = y;
		y = t;
	}

	for(;;)
	{
		if(BIGNUM_ZERO_P(x))
			return tag_object(y);

		t = s48_bignum_remainder(y,x);
		y = x;
		x = t;
	}
}

CELL divide_bignum(ARRAY* x, ARRAY* y)
{
	ARRAY* gcd;

	if(BIGNUM_ZERO_P(y))
		raise(SIGFPE);

	if(BIGNUM_NEGATIVE_P(y))
	{
		x = s48_bignum_negate(x);
		y = s48_bignum_negate(y);
	}

	gcd = (ARRAY*)UNTAG(gcd_bignum(x,y));
	x = s48_bignum_quotient(x,gcd);
	y = s48_bignum_quotient(y,gcd);

	if(BIGNUM_ONE_P(y,0))
		return tag_object(x);
	else
	{
		return tag_ratio(ratio(
			tag_object(x),
			tag_object(y)));
	}
}

CELL divint_bignum(ARRAY* x, ARRAY* y)
{
	ARRAY* q = s48_bignum_quotient(x,y);
	if(q == NULL)
		raise(SIGFPE);
	return tag_object(q);
}

CELL divfloat_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(make_float(
		s48_bignum_to_double(x) /
		s48_bignum_to_double(y)));
}

CELL divmod_bignum(ARRAY* x, ARRAY* y)
{
	ARRAY* q;
	ARRAY* r;
	if(s48_bignum_divide(x,y,&q,&r))
		raise(SIGFPE);
	dpush(tag_object(q));
	return tag_object(r);
}

CELL mod_bignum(ARRAY* x, ARRAY* y)
{
	ARRAY* r = s48_bignum_remainder(x,y);
	if(r == NULL)
		raise(SIGFPE);
	return tag_object(r);
}

CELL and_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_bitwise_and(x,y));
}

CELL or_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_bitwise_ior(x,y));
}

CELL xor_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_bitwise_xor(x,y));
}

CELL shiftleft_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_arithmetic_shift(x,
		s48_bignum_to_long(y)));
}

CELL shiftright_bignum(ARRAY* x, ARRAY* y)
{
	return tag_object(s48_bignum_arithmetic_shift(x,
		-s48_bignum_to_long(y)));
}

CELL less_bignum(ARRAY* x, ARRAY* y)
{
	return tag_boolean(
		s48_bignum_compare(x,y)
		== bignum_comparison_less);
}

CELL lesseq_bignum(ARRAY* x, ARRAY* y)
{
	switch(s48_bignum_compare(x,y))
	{
	case bignum_comparison_less:
	case bignum_comparison_equal:
		return T;
	case bignum_comparison_greater:
		return F;
	}
}

CELL greater_bignum(ARRAY* x, ARRAY* y)
{
	return tag_boolean(
		s48_bignum_compare(x,y)
		== bignum_comparison_greater);
}

CELL greatereq_bignum(ARRAY* x, ARRAY* y)
{
	switch(s48_bignum_compare(x,y))
	{
	case bignum_comparison_less:
		return F;
	case bignum_comparison_equal:
	case bignum_comparison_greater:
		return T;
	}
}

CELL not_bignum(ARRAY* x)
{
	return tag_object(s48_bignum_bitwise_not(x));
}

void copy_bignum_constants(void)
{
	bignum_zero = copy_array(bignum_zero);
	bignum_pos_one = copy_array(bignum_pos_one);
	bignum_neg_one = copy_array(bignum_neg_one);
}
