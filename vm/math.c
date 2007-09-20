#include "master.h"

/* Fixnums */

F_FIXNUM to_fixnum(CELL tagged)
{
	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(untag_object(tagged));
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

CELL to_cell(CELL tagged)
{
	return (CELL)to_fixnum(tagged);
}

DEFINE_PRIMITIVE(bignum_to_fixnum)
{
	drepl(tag_fixnum(bignum_to_fixnum(untag_object(dpeek()))));
}

DEFINE_PRIMITIVE(float_to_fixnum)
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

#define POP_FIXNUMS(x,y) \
	F_FIXNUM y = untag_fixnum_fast(dpop()); \
	F_FIXNUM x = untag_fixnum_fast(dpop());

/* The fixnum arithmetic operations defined in C are relatively slow.
The Factor compiler has optimized assembly intrinsics for some of these
operations. */
DEFINE_PRIMITIVE(fixnum_add)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x + y);
}

DEFINE_PRIMITIVE(fixnum_add_fast)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x + y));
}

DEFINE_PRIMITIVE(fixnum_subtract)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x - y);
}

DEFINE_PRIMITIVE(fixnum_subtract_fast)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x - y));
}

/* Multiply two integers, and trap overflow.
Thanks to David Blaikie (The_Vulture from freenode #java) for the hint. */
DEFINE_PRIMITIVE(fixnum_multiply)
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
			F_ARRAY *bx = fixnum_to_bignum(x);
			REGISTER_BIGNUM(bx);
			F_ARRAY *by = fixnum_to_bignum(y);
			UNREGISTER_BIGNUM(bx);
			dpush(tag_bignum(bignum_multiply(bx,by)));
		}
	}
}

DEFINE_PRIMITIVE(fixnum_multiply_fast)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x * y));
}

DEFINE_PRIMITIVE(fixnum_divint)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x / y);
}

DEFINE_PRIMITIVE(fixnum_divmod)
{
	POP_FIXNUMS(x,y)
	box_signed_cell(x / y);
	dpush(tag_fixnum(x % y));
}

DEFINE_PRIMITIVE(fixnum_mod)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x % y));
}

DEFINE_PRIMITIVE(fixnum_and)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x & y));
}

DEFINE_PRIMITIVE(fixnum_or)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x | y));
}

DEFINE_PRIMITIVE(fixnum_xor)
{
	POP_FIXNUMS(x,y)
	dpush(tag_fixnum(x ^ y));
}

/*
 * Note the hairy overflow check.
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
DEFINE_PRIMITIVE(fixnum_shift)
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
		F_FIXNUM mask = -(1L << (WORD_SIZE - 1 - TAG_BITS - y));
		if((x > 0 && (x & mask) == 0) || (x & mask) == mask)
		{
			dpush(tag_fixnum(x << y));
			return;
		}
	}

	dpush(tag_bignum(bignum_arithmetic_shift(
		fixnum_to_bignum(x),y)));
}

DEFINE_PRIMITIVE(fixnum_less)
{
	POP_FIXNUMS(x,y)
	box_boolean(x < y);
}

DEFINE_PRIMITIVE(fixnum_lesseq)
{
	POP_FIXNUMS(x,y)
	box_boolean(x <= y);
}

DEFINE_PRIMITIVE(fixnum_greater)
{
	POP_FIXNUMS(x,y)
	box_boolean(x > y);
}

DEFINE_PRIMITIVE(fixnum_greatereq)
{
	POP_FIXNUMS(x,y)
	box_boolean(x >= y);
}

DEFINE_PRIMITIVE(fixnum_not)
{
	drepl(tag_fixnum(~untag_fixnum_fast(dpeek())));
}

/* Bignums */
DEFINE_PRIMITIVE(fixnum_to_bignum)
{
	drepl(tag_bignum(fixnum_to_bignum(untag_fixnum_fast(dpeek()))));
}

DEFINE_PRIMITIVE(float_to_bignum)
{
	drepl(tag_bignum(float_to_bignum(dpeek())));
}

#define POP_BIGNUMS(x,y) \
	F_ARRAY *y = untag_object(dpop()); \
	F_ARRAY *x = untag_object(dpop());

DEFINE_PRIMITIVE(bignum_eq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_equal_p(x,y));
}

DEFINE_PRIMITIVE(bignum_add)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_add(x,y)));
}

DEFINE_PRIMITIVE(bignum_subtract)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_subtract(x,y)));
}

DEFINE_PRIMITIVE(bignum_multiply)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_multiply(x,y)));
}

DEFINE_PRIMITIVE(bignum_divint)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_quotient(x,y)));
}

DEFINE_PRIMITIVE(bignum_divmod)
{
	F_ARRAY *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	dpush(tag_bignum(q));
	dpush(tag_bignum(r));
}

DEFINE_PRIMITIVE(bignum_mod)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_remainder(x,y)));
}

DEFINE_PRIMITIVE(bignum_and)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_and(x,y)));
}

DEFINE_PRIMITIVE(bignum_or)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_ior(x,y)));
}

DEFINE_PRIMITIVE(bignum_xor)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_xor(x,y)));
}

DEFINE_PRIMITIVE(bignum_shift)
{
	F_FIXNUM y = to_fixnum(dpop());
        F_ARRAY* x = untag_object(dpop());
	dpush(tag_bignum(bignum_arithmetic_shift(x,y)));
}

DEFINE_PRIMITIVE(bignum_less)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_less);
}

DEFINE_PRIMITIVE(bignum_lesseq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_greater);
}

DEFINE_PRIMITIVE(bignum_greater)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_greater);
}

DEFINE_PRIMITIVE(bignum_greatereq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_less);
}

DEFINE_PRIMITIVE(bignum_not)
{
	drepl(tag_bignum(bignum_bitwise_not(untag_object(dpeek()))));
}

DEFINE_PRIMITIVE(bignum_bitp)
{
	F_FIXNUM bit = to_fixnum(dpop());
	F_ARRAY *x = untag_object(dpop());
	box_boolean(bignum_logbitp(bit,x));
}

DEFINE_PRIMITIVE(bignum_log2)
{
	drepl(tag_bignum(bignum_integer_length(untag_object(dpeek()))));
}

unsigned int bignum_producer(unsigned int digit)
{
	unsigned char *ptr = alien_offset(dpeek());
	return *(ptr + digit);
}

DEFINE_PRIMITIVE(byte_array_to_bignum)
{
	type_check(BYTE_ARRAY_TYPE,dpeek());
	CELL n_digits = array_capacity(untag_object(dpeek()));
	bignum_type bignum = digit_stream_to_bignum(
		n_digits,bignum_producer,0x100,0);
	drepl(tag_bignum(bignum));
}

void box_signed_1(s8 n)
{
	dpush(tag_fixnum(n));
}

void box_unsigned_1(u8 n)
{
	dpush(tag_fixnum(n));
}

void box_signed_2(s16 n)
{
	dpush(tag_fixnum(n));
}

void box_unsigned_2(u16 n)
{
	dpush(tag_fixnum(n));
}

void box_signed_4(s32 n)
{
	dpush(allot_integer(n));
}

void box_unsigned_4(u32 n)
{
	dpush(allot_cell(n));
}

void box_signed_cell(F_FIXNUM integer)
{
	dpush(allot_integer(integer));
}

void box_unsigned_cell(CELL cell)
{
	dpush(allot_cell(cell));
}

void box_signed_8(s64 n)
{
	if(n < FIXNUM_MIN || n > FIXNUM_MAX)
		dpush(tag_bignum(long_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

s64 to_signed_8(CELL obj)
{
	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(obj);
	case BIGNUM_TYPE:
		return bignum_to_long_long(untag_object(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

void box_unsigned_8(u64 n)
{
	if(n > FIXNUM_MAX)
		dpush(tag_bignum(ulong_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

u64 to_unsigned_8(CELL obj)
{
	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(obj);
	case BIGNUM_TYPE:
		return bignum_to_ulong_long(untag_object(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

CELL unbox_array_size(void)
{
	switch(type_of(dpeek()))
	{
	case FIXNUM_TYPE:
		{
			F_FIXNUM n = untag_fixnum_fast(dpeek());
			if(n >= 0 && n < ARRAY_SIZE_MAX)
			{
				dpop();
				return n;
			}
			break;
		}
	case BIGNUM_TYPE:
		{
			bignum_type zero = untag_object(bignum_zero);
			bignum_type max = ulong_to_bignum(ARRAY_SIZE_MAX);
			bignum_type n = untag_object(dpeek());
			if(bignum_compare(n,zero) != bignum_comparison_less
				&& bignum_compare(n,max) == bignum_comparison_less)
			{
				dpop();
				return bignum_to_ulong(n);
			}
			break;
		}
	}

	general_error(ERROR_ARRAY_SIZE,dpop(),tag_fixnum(ARRAY_SIZE_MAX),NULL);
	return 0; /* can't happen */
}

/* Ratios */

/* Does not reduce to lowest terms, so should only be used by math
library implementation, to avoid breaking invariants. */
DEFINE_PRIMITIVE(from_fraction)
{
	F_RATIO* ratio = allot_object(RATIO_TYPE,sizeof(F_RATIO));
	ratio->denominator = dpop();
	ratio->numerator = dpop();
	dpush(RETAG(ratio,RATIO_TYPE));
}

/* Floats */
DEFINE_PRIMITIVE(fixnum_to_float)
{
	drepl(allot_float(fixnum_to_float(dpeek())));
}

DEFINE_PRIMITIVE(bignum_to_float)
{
	drepl(allot_float(bignum_to_float(dpeek())));
}

DEFINE_PRIMITIVE(str_to_float)
{
	char *c_str, *end;
	double f;
	F_STRING *str = untag_string(dpeek());
	CELL capacity = string_capacity(str);

	c_str = to_char_string(str,false);
	end = c_str;
	f = strtod(c_str,&end);
	if(end != c_str + capacity)
		drepl(F);
	else
		drepl(allot_float(f));
}

DEFINE_PRIMITIVE(float_to_str)
{
	char tmp[33];
	snprintf(tmp,32,"%.16g",untag_float(dpop()));
	tmp[32] = '\0';
	box_char_string(tmp);
}

#define POP_FLOATS(x,y) \
	double y = untag_float_fast(dpop()); \
	double x = untag_float_fast(dpop());

DEFINE_PRIMITIVE(float_eq)
{
	POP_FLOATS(x,y);
	box_boolean(x == y);
}

DEFINE_PRIMITIVE(float_add)
{
	POP_FLOATS(x,y);
	box_double(x + y);
}

DEFINE_PRIMITIVE(float_subtract)
{
	POP_FLOATS(x,y);
	box_double(x - y);
}

DEFINE_PRIMITIVE(float_multiply)
{
	POP_FLOATS(x,y);
	box_double(x * y);
}

DEFINE_PRIMITIVE(float_divfloat)
{
	POP_FLOATS(x,y);
	box_double(x / y);
}

DEFINE_PRIMITIVE(float_mod)
{
	POP_FLOATS(x,y);
	box_double(fmod(x,y));
}

DEFINE_PRIMITIVE(float_less)
{
	POP_FLOATS(x,y);
	box_boolean(x < y);
}

DEFINE_PRIMITIVE(float_lesseq)
{
	POP_FLOATS(x,y);
	box_boolean(x <= y);
}

DEFINE_PRIMITIVE(float_greater)
{
	POP_FLOATS(x,y);
	box_boolean(x > y);
}

DEFINE_PRIMITIVE(float_greatereq)
{
	POP_FLOATS(x,y);
	box_boolean(x >= y);
}

DEFINE_PRIMITIVE(float_bits)
{
	box_unsigned_4(float_bits(untag_float(dpop())));
}

DEFINE_PRIMITIVE(bits_float)
{
	box_float(bits_float(to_cell(dpop())));
}

DEFINE_PRIMITIVE(double_bits)
{
	box_unsigned_8(double_bits(untag_float(dpop())));
}

DEFINE_PRIMITIVE(bits_double)
{
	box_double(bits_double(to_unsigned_8(dpop())));
}

float to_float(CELL value)
{
	return untag_float(value);
}

double to_double(CELL value)
{
	return untag_float(value);
}

void box_float(float flo)
{
        dpush(allot_float(flo));
}

void box_double(double flo)
{
        dpush(allot_float(flo));
}

/* Complex numbers */

DEFINE_PRIMITIVE(from_rect)
{
	F_COMPLEX* complex = allot_object(COMPLEX_TYPE,sizeof(F_COMPLEX));
	complex->imaginary = dpop();
	complex->real = dpop();
	dpush(RETAG(complex,COMPLEX_TYPE));
}
