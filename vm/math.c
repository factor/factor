#include "factor.h"

/* Fixnums */

F_FIXNUM to_fixnum(CELL tagged)
{
	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(tagged);
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

CELL to_cell(CELL tagged)
{
	return (CELL)to_fixnum(tagged);
}

void primitive_bignum_to_fixnum(void)
{
	drepl(tag_fixnum(bignum_to_fixnum(dpeek())));
}

void primitive_float_to_fixnum(void)
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

#define POP_FIXNUMS(x,y) \
	F_FIXNUM y = untag_fixnum_fast(dpop()); \
	F_FIXNUM x = untag_fixnum_fast(dpop());

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

/* Multiply two integers, and trap overflow.
Thanks to David Blaikie (The_Vulture from freenode #java) for the hint. */
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
			F_ARRAY *bx = s48_fixnum_to_bignum(x);
			REGISTER_BIGNUM(bx);
			F_ARRAY *by = s48_fixnum_to_bignum(y);
			UNREGISTER_BIGNUM(by);
			dpush(tag_bignum(s48_bignum_multiply(bx,by)));
		}
	}
}

void primitive_fixnum_divint(void)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x / y);
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

#define INT_DEFBOX(name,type) \
void name(type integer)                                                        \
{                                                                              \
	dpush(tag_fixnum(integer));                                            \
}

#define INT_DEFUNBOX(name,type) \
type name(void)                                                                \
{                                                                              \
	return to_fixnum(dpop());                                              \
}

INT_DEFBOX(box_signed_1, signed char)
INT_DEFBOX(box_signed_2, signed short)
INT_DEFBOX(box_unsigned_1, unsigned char)
INT_DEFBOX(box_unsigned_2, unsigned short)
INT_DEFUNBOX(unbox_signed_1, signed char)
INT_DEFUNBOX(unbox_signed_2, signed short)
INT_DEFUNBOX(unbox_unsigned_1, unsigned char)
INT_DEFUNBOX(unbox_unsigned_2, unsigned short) 

/* Bignums */
void primitive_fixnum_to_bignum(void)
{
	drepl(tag_bignum(fixnum_to_bignum(dpeek())));
}

void primitive_float_to_bignum(void)
{
	drepl(tag_bignum(float_to_bignum(dpeek())));
}

#define POP_BIGNUMS(x,y) \
	F_ARRAY *y = untag_bignum_fast(dpop()); \
	F_ARRAY *x = untag_bignum_fast(dpop());

void primitive_bignum_eq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(s48_bignum_equal_p(x,y));
}

void primitive_bignum_add(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_add(x,y)));
}

void primitive_bignum_subtract(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_subtract(x,y)));
}

void primitive_bignum_multiply(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_multiply(x,y)));
}

void primitive_bignum_divint(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_quotient(x,y)));
}

void primitive_bignum_divmod(void)
{
	F_ARRAY *q, *r;
	POP_BIGNUMS(x,y);
	s48_bignum_divide(x,y,&q,&r);
	dpush(tag_bignum(q));
	dpush(tag_bignum(r));
}

void primitive_bignum_mod(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_remainder(x,y)));
}

void primitive_bignum_and(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_bitwise_and(x,y)));
}

void primitive_bignum_or(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_bitwise_ior(x,y)));
}

void primitive_bignum_xor(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(s48_bignum_bitwise_xor(x,y)));
}

void primitive_bignum_shift(void)
{
	F_FIXNUM y = untag_fixnum_fast(dpop());
        F_ARRAY* x = untag_bignum_fast(dpop());
	dpush(tag_bignum(s48_bignum_arithmetic_shift(x,y)));
}

void primitive_bignum_less(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(s48_bignum_compare(x,y) == bignum_comparison_less);
}

void primitive_bignum_lesseq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(s48_bignum_compare(x,y) != bignum_comparison_greater);
}

void primitive_bignum_greater(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(s48_bignum_compare(x,y) == bignum_comparison_greater);
}

void primitive_bignum_greatereq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(s48_bignum_compare(x,y) != bignum_comparison_less);
}

void primitive_bignum_not(void)
{
	drepl(tag_bignum(s48_bignum_bitwise_not(
		untag_bignum_fast(dpeek()))));
}

void box_signed_cell(F_FIXNUM integer)
{
	dpush(allot_integer(integer));
}

F_FIXNUM unbox_signed_cell(void)
{
	return to_fixnum(dpop());
}

void box_unsigned_cell(CELL cell)
{
	dpush(allot_cell(cell));
}

F_FIXNUM unbox_unsigned_cell(void)
{
	return to_cell(dpop());
}

void box_signed_4(s32 n)
{
	dpush(allot_integer(n));
}

s32 unbox_signed_4(void)
{
	return to_fixnum(dpop());
}

void box_unsigned_4(u32 n)
{
	dpush(allot_cell(n));
}

u32 unbox_unsigned_4(void)
{
	return to_cell(dpop());
}

void box_signed_8(s64 n)
{
	if(n < FIXNUM_MIN || n > FIXNUM_MAX)
		dpush(tag_bignum(s48_long_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

s64 unbox_signed_8(void)
{
	CELL obj = dpop();

	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(obj);
	case BIGNUM_TYPE:
		return s48_bignum_to_long_long(untag_array_fast(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

void box_unsigned_8(u64 n)
{
	if(n > FIXNUM_MAX)
		dpush(tag_bignum(s48_ulong_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

u64 unbox_unsigned_8(void)
{
	CELL obj = dpop();

	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(obj);
	case BIGNUM_TYPE:
		return s48_bignum_to_ulong_long(untag_array_fast(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

/* Ratios */

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
void primitive_from_fraction(void)
{
	F_RATIO* ratio = allot_object(RATIO_TYPE,sizeof(F_RATIO));
	ratio->denominator = dpop();
	ratio->numerator = dpop();
	dpush(RETAG(ratio,RATIO_TYPE));
}

/* Floats */
void primitive_fixnum_to_float(void)
{
	drepl(allot_float(fixnum_to_float(dpeek())));
}

void primitive_bignum_to_float(void)
{
	drepl(allot_float(bignum_to_float(dpeek())));
}

void primitive_str_to_float(void)
{
	char *c_str, *end;
	double f;
	F_STRING *str = untag_string(dpeek());
	CELL capacity = string_capacity(str);

	/* if the string has nulls or chars > 255, its definitely not a float */
	if(!check_string(str,sizeof(char)))
		drepl(F);
	else
	{
		c_str = to_char_string(str,false);
		end = c_str;
		f = strtod(c_str,&end);
		if(end != c_str + capacity)
			drepl(F);
		else
			drepl(allot_float(f));
	}
}

void primitive_float_to_str(void)
{
	char tmp[33];
	snprintf(tmp,32,"%.16g",unbox_double());
	tmp[32] = '\0';
	box_char_string(tmp);
}

#define POP_FLOATS(x,y) \
	double y = untag_float_fast(dpop()); \
	double x = untag_float_fast(dpop());

void primitive_float_add(void)
{
	POP_FLOATS(x,y);
	box_float(x + y);
}

void primitive_float_subtract(void)
{
	POP_FLOATS(x,y);
	box_float(x - y);
}

void primitive_float_multiply(void)
{
	POP_FLOATS(x,y);
	box_float(x * y);
}

void primitive_float_divfloat(void)
{
	POP_FLOATS(x,y);
	box_float(x / y);
}

void primitive_float_mod(void)
{
	POP_FLOATS(x,y);
	box_float(fmod(x,y));
}

void primitive_float_less(void)
{
	POP_FLOATS(x,y);
	box_boolean(x < y);
}

void primitive_float_lesseq(void)
{
	POP_FLOATS(x,y);
	box_boolean(x <= y);
}

void primitive_float_greater(void)
{
	POP_FLOATS(x,y);
	box_boolean(x > y);
}

void primitive_float_greatereq(void)
{
	POP_FLOATS(x,y);
	box_boolean(x >= y);
}

void primitive_float_bits(void)
{
	F_FLOAT_BITS b;
	b.x = unbox_float();
	box_unsigned_4(b.y);
}

void primitive_bits_float(void)
{
	F_FLOAT_BITS b;
	b.y = unbox_unsigned_4();
	box_float(b.x);
}

void primitive_double_bits(void)
{
	F_DOUBLE_BITS b;
	b.x = unbox_double();
	box_unsigned_8(b.y);
}

void primitive_bits_double(void)
{
	F_DOUBLE_BITS b;
	b.y = unbox_unsigned_8();
	box_double(b.x);
}

#define FLO_DEFBOX(name,type) \
void name (type flo)                                                       \
{                                                                              \
	dpush(allot_float(flo));                                               \
}

#define FLO_DEFUNBOX(name,type) \
type name(void)                                                                \
{                                                                              \
	return untag_float(dpop());                                            \
}

FLO_DEFBOX(box_float,float)
FLO_DEFUNBOX(unbox_float,float)  
FLO_DEFBOX(box_double,double)
FLO_DEFUNBOX(unbox_double,double)

/* Complex numbers */

void primitive_from_rect(void)
{
	F_COMPLEX* complex = allot_object(COMPLEX_TYPE,sizeof(F_COMPLEX));
	complex->imaginary = dpop();
	complex->real = dpop();
	dpush(RETAG(complex,COMPLEX_TYPE));
}
