#include "factor.h"

FIXNUM to_integer(CELL x)
{
	switch(type_of(x))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(x);
	case BIGNUM_TYPE:
		return s48_bignum_to_long(untag_bignum(x));
	default:
		type_error(INTEGER_TYPE,x);
		return 0;
	}
}

/* FFI calls this */
void box_integer(FIXNUM integer)
{
	dpush(tag_integer(integer));
}

/* FFI calls this */
void box_cell(CELL cell)
{
	dpush(tag_cell(cell));
}

/* FFI calls this */
FIXNUM unbox_integer(void)
{
	return to_integer(dpop());
}

/* FFI calls this */
CELL unbox_cell(void)
{
	return to_integer(dpop());
}

ARRAY* to_bignum(CELL tagged)
{
	RATIO* r;
	ARRAY* x;
	ARRAY* y;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return s48_long_to_bignum(untag_fixnum_fast(tagged));
	case BIGNUM_TYPE:
		return (ARRAY*)UNTAG(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		x = to_bignum(r->numerator);
		y = to_bignum(r->denominator);
		return s48_bignum_quotient(x,y);
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
	maybe_garbage_collection();
	drepl(tag_object(to_bignum(dpeek())));
}

void primitive_bignum_eq(void)
{
	ARRAY* y = to_bignum(dpop());
	ARRAY* x = to_bignum(dpop());
	dpush(tag_boolean(s48_bignum_equal_p(x,y)));
}

#define GC_AND_POP_BIGNUMS(x,y) \
	ARRAY *x, *y; \
	maybe_garbage_collection(); \
	y = to_bignum(dpop()); \
	x = to_bignum(dpop());

void primitive_bignum_add(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_add(x,y)));
}

void primitive_bignum_subtract(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_subtract(x,y)));
}

void primitive_bignum_multiply(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_multiply(x,y)));
}

void primitive_bignum_divint(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_quotient(x,y)));
}

void primitive_bignum_divfloat(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(make_float(
		s48_bignum_to_double(x) /
		s48_bignum_to_double(y))));
}

void primitive_bignum_divmod(void)
{
	ARRAY *q, *r;
	GC_AND_POP_BIGNUMS(x,y);
	s48_bignum_divide(x,y,&q,&r);
	dpush(tag_object(q));
	dpush(tag_object(r));
}

void primitive_bignum_mod(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_remainder(x,y)));
}

void primitive_bignum_and(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_bitwise_and(x,y)));
}

void primitive_bignum_or(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_bitwise_ior(x,y)));
}

void primitive_bignum_xor(void)
{
	GC_AND_POP_BIGNUMS(x,y);
	dpush(tag_object(s48_bignum_bitwise_xor(x,y)));
}

void primitive_bignum_shift(void)
{
	FIXNUM y;
        ARRAY* x;
	maybe_garbage_collection();
	y = to_fixnum(dpop());
	x = to_bignum(dpop());
	dpush(tag_object(s48_bignum_arithmetic_shift(x,y)));
}

void primitive_bignum_less(void)
{
	ARRAY* y = to_bignum(dpop());
	ARRAY* x = to_bignum(dpop());
	dpush(tag_boolean(
		s48_bignum_compare(x,y)
		== bignum_comparison_less));
}

void primitive_bignum_lesseq(void)
{
	ARRAY* y = to_bignum(dpop());
	ARRAY* x = to_bignum(dpop());

	switch(s48_bignum_compare(x,y))
	{
	case bignum_comparison_less:
	case bignum_comparison_equal:
		dpush(T);
		break;
	case bignum_comparison_greater:
		dpush(F);
		break;
	default:
		critical_error("s48_bignum_compare returns bogus value",0);
		break;
	}
}

void primitive_bignum_greater(void)
{
	ARRAY* y = to_bignum(dpop());
	ARRAY* x = to_bignum(dpop());
	dpush(tag_boolean(
		s48_bignum_compare(x,y)
		== bignum_comparison_greater));
}

void primitive_bignum_greatereq(void)
{
	ARRAY* y = to_bignum(dpop());
	ARRAY* x = to_bignum(dpop());

	switch(s48_bignum_compare(x,y))
	{
	case bignum_comparison_less:
		dpush(F);
		break;
	case bignum_comparison_equal:
	case bignum_comparison_greater:
		dpush(T);
		break;
	default:
		critical_error("s48_bignum_compare returns bogus value",0);
		break;
	}
}

void primitive_bignum_not(void)
{
	maybe_garbage_collection();
	drepl(tag_object(s48_bignum_bitwise_not(
		untag_bignum(dpeek()))));
}

void copy_bignum_constants(void)
{
	copy_object(&bignum_zero);
	copy_object(&bignum_pos_one);
	copy_object(&bignum_neg_one);
}
