#include "master.hpp"

CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

PRIMITIVE(bignum_to_fixnum)
{
	drepl(tag_fixnum(bignum_to_fixnum(untag<F_BIGNUM>(dpeek()))));
}

PRIMITIVE(float_to_fixnum)
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

/* Division can only overflow when we are dividing the most negative fixnum
by -1. */
PRIMITIVE(fixnum_divint)
{
	F_FIXNUM y = untag_fixnum(dpop()); \
	F_FIXNUM x = untag_fixnum(dpeek());
	F_FIXNUM result = x / y;
	if(result == -FIXNUM_MIN)
		drepl(allot_integer(-FIXNUM_MIN));
	else
		drepl(tag_fixnum(result));
}

PRIMITIVE(fixnum_divmod)
{
	CELL y = ((CELL *)ds)[0];
	CELL x = ((CELL *)ds)[-1];
	if(y == tag_fixnum(-1) && x == tag_fixnum(FIXNUM_MIN))
	{
		((CELL *)ds)[-1] = allot_integer(-FIXNUM_MIN);
		((CELL *)ds)[0] = tag_fixnum(0);
	}
	else
	{
		((CELL *)ds)[-1] = tag_fixnum(untag_fixnum(x) / untag_fixnum(y));
		((CELL *)ds)[0] = (F_FIXNUM)x % (F_FIXNUM)y;
	}
}

/*
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
#define SIGN_MASK(x) ((x) >> (WORD_SIZE - 1))
#define BRANCHLESS_MAX(x,y) ((x) - (((x) - (y)) & SIGN_MASK((x) - (y))))
#define BRANCHLESS_ABS(x) ((x ^ SIGN_MASK(x)) - SIGN_MASK(x))

PRIMITIVE(fixnum_shift)
{
	F_FIXNUM y = untag_fixnum(dpop()); \
	F_FIXNUM x = untag_fixnum(dpeek());

	if(x == 0)
		return;
	else if(y < 0)
	{
		y = BRANCHLESS_MAX(y,-WORD_SIZE + 1);
		drepl(tag_fixnum(x >> -y));
		return;
	}
	else if(y < WORD_SIZE - TAG_BITS)
	{
		F_FIXNUM mask = -((F_FIXNUM)1 << (WORD_SIZE - 1 - TAG_BITS - y));
		if(!(BRANCHLESS_ABS(x) & mask))
		{
			drepl(tag_fixnum(x << y));
			return;
		}
	}

	drepl(tag<F_BIGNUM>(bignum_arithmetic_shift(
		fixnum_to_bignum(x),y)));
}

PRIMITIVE(fixnum_to_bignum)
{
	drepl(tag<F_BIGNUM>(fixnum_to_bignum(untag_fixnum(dpeek()))));
}

PRIMITIVE(float_to_bignum)
{
	drepl(tag<F_BIGNUM>(float_to_bignum(dpeek())));
}

#define POP_BIGNUMS(x,y) \
	F_BIGNUM * y = untag<F_BIGNUM>(dpop()); \
	F_BIGNUM * x = untag<F_BIGNUM>(dpop());

PRIMITIVE(bignum_eq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_equal_p(x,y));
}

PRIMITIVE(bignum_add)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_add(x,y)));
}

PRIMITIVE(bignum_subtract)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_subtract(x,y)));
}

PRIMITIVE(bignum_multiply)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_multiply(x,y)));
}

PRIMITIVE(bignum_divint)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_quotient(x,y)));
}

PRIMITIVE(bignum_divmod)
{
	F_BIGNUM *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	dpush(tag<F_BIGNUM>(q));
	dpush(tag<F_BIGNUM>(r));
}

PRIMITIVE(bignum_mod)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_remainder(x,y)));
}

PRIMITIVE(bignum_and)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_bitwise_and(x,y)));
}

PRIMITIVE(bignum_or)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_bitwise_ior(x,y)));
}

PRIMITIVE(bignum_xor)
{
	POP_BIGNUMS(x,y);
	dpush(tag<F_BIGNUM>(bignum_bitwise_xor(x,y)));
}

PRIMITIVE(bignum_shift)
{
	F_FIXNUM y = untag_fixnum(dpop());
        F_BIGNUM* x = untag<F_BIGNUM>(dpop());
	dpush(tag<F_BIGNUM>(bignum_arithmetic_shift(x,y)));
}

PRIMITIVE(bignum_less)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_less);
}

PRIMITIVE(bignum_lesseq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_greater);
}

PRIMITIVE(bignum_greater)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_greater);
}

PRIMITIVE(bignum_greatereq)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_less);
}

PRIMITIVE(bignum_not)
{
	drepl(tag<F_BIGNUM>(bignum_bitwise_not(untag<F_BIGNUM>(dpeek()))));
}

PRIMITIVE(bignum_bitp)
{
	F_FIXNUM bit = to_fixnum(dpop());
	F_BIGNUM *x = untag<F_BIGNUM>(dpop());
	box_boolean(bignum_logbitp(bit,x));
}

PRIMITIVE(bignum_log2)
{
	drepl(tag<F_BIGNUM>(bignum_integer_length(untag<F_BIGNUM>(dpeek()))));
}

unsigned int bignum_producer(unsigned int digit)
{
	unsigned char *ptr = (unsigned char *)alien_offset(dpeek());
	return *(ptr + digit);
}

PRIMITIVE(byte_array_to_bignum)
{
	CELL n_digits = array_capacity(untag_check<F_BYTE_ARRAY>(dpeek()));
	F_BIGNUM * bignum = digit_stream_to_bignum(n_digits,bignum_producer,0x100,0);
	drepl(tag<F_BIGNUM>(bignum));
}

CELL unbox_array_size(void)
{
	switch(tagged<F_OBJECT>(dpeek()).type())
	{
	case FIXNUM_TYPE:
		{
			F_FIXNUM n = untag_fixnum(dpeek());
			if(n >= 0 && n < (F_FIXNUM)ARRAY_SIZE_MAX)
			{
				dpop();
				return n;
			}
			break;
		}
	case BIGNUM_TYPE:
		{
			F_BIGNUM * zero = untag<F_BIGNUM>(bignum_zero);
			F_BIGNUM * max = cell_to_bignum(ARRAY_SIZE_MAX);
			F_BIGNUM * n = untag<F_BIGNUM>(dpeek());
			if(bignum_compare(n,zero) != bignum_comparison_less
				&& bignum_compare(n,max) == bignum_comparison_less)
			{
				dpop();
				return bignum_to_cell(n);
			}
			break;
		}
	}

	general_error(ERROR_ARRAY_SIZE,dpop(),tag_fixnum(ARRAY_SIZE_MAX),NULL);
	return 0; /* can't happen */
}

PRIMITIVE(fixnum_to_float)
{
	drepl(allot_float(fixnum_to_float(dpeek())));
}

PRIMITIVE(bignum_to_float)
{
	drepl(allot_float(bignum_to_float(dpeek())));
}

PRIMITIVE(str_to_float)
{
	F_BYTE_ARRAY *bytes = untag_check<F_BYTE_ARRAY>(dpeek());
	CELL capacity = array_capacity(bytes);

	char *c_str = (char *)(bytes + 1);
	char *end = c_str;
	double f = strtod(c_str,&end);
	if(end == c_str + capacity - 1)
		drepl(allot_float(f));
	else
		drepl(F);
}

PRIMITIVE(float_to_str)
{
	F_BYTE_ARRAY *array = allot_byte_array(33);
	snprintf((char *)(array + 1),32,"%.16g",untag_float_check(dpop()));
	dpush(tag<F_BYTE_ARRAY>(array));
}

#define POP_FLOATS(x,y) \
	double y = untag_float(dpop()); \
	double x = untag_float(dpop());

PRIMITIVE(float_eq)
{
	POP_FLOATS(x,y);
	box_boolean(x == y);
}

PRIMITIVE(float_add)
{
	POP_FLOATS(x,y);
	box_double(x + y);
}

PRIMITIVE(float_subtract)
{
	POP_FLOATS(x,y);
	box_double(x - y);
}

PRIMITIVE(float_multiply)
{
	POP_FLOATS(x,y);
	box_double(x * y);
}

PRIMITIVE(float_divfloat)
{
	POP_FLOATS(x,y);
	box_double(x / y);
}

PRIMITIVE(float_mod)
{
	POP_FLOATS(x,y);
	box_double(fmod(x,y));
}

PRIMITIVE(float_less)
{
	POP_FLOATS(x,y);
	box_boolean(x < y);
}

PRIMITIVE(float_lesseq)
{
	POP_FLOATS(x,y);
	box_boolean(x <= y);
}

PRIMITIVE(float_greater)
{
	POP_FLOATS(x,y);
	box_boolean(x > y);
}

PRIMITIVE(float_greatereq)
{
	POP_FLOATS(x,y);
	box_boolean(x >= y);
}

PRIMITIVE(float_bits)
{
	box_unsigned_4(float_bits(untag_float_check(dpop())));
}

PRIMITIVE(bits_float)
{
	box_float(bits_float(to_cell(dpop())));
}

PRIMITIVE(double_bits)
{
	box_unsigned_8(double_bits(untag_float_check(dpop())));
}

PRIMITIVE(bits_double)
{
	box_double(bits_double(to_unsigned_8(dpop())));
}

VM_C_API F_FIXNUM to_fixnum(CELL tagged)
{
	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(untag<F_BIGNUM>(tagged));
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

VM_C_API CELL to_cell(CELL tagged)
{
	return (CELL)to_fixnum(tagged);
}

VM_C_API void box_signed_1(s8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_1(u8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_2(s16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_2(u16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_4(s32 n)
{
	dpush(allot_integer(n));
}

VM_C_API void box_unsigned_4(u32 n)
{
	dpush(allot_cell(n));
}

VM_C_API void box_signed_cell(F_FIXNUM integer)
{
	dpush(allot_integer(integer));
}

VM_C_API void box_unsigned_cell(CELL cell)
{
	dpush(allot_cell(cell));
}

VM_C_API void box_signed_8(s64 n)
{
	if(n < FIXNUM_MIN || n > FIXNUM_MAX)
		dpush(tag<F_BIGNUM>(long_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API s64 to_signed_8(CELL obj)
{
	switch(tagged<F_OBJECT>(obj).type())
	{
	case FIXNUM_TYPE:
		return untag_fixnum(obj);
	case BIGNUM_TYPE:
		return bignum_to_long_long(untag<F_BIGNUM>(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

VM_C_API void box_unsigned_8(u64 n)
{
	if(n > FIXNUM_MAX)
		dpush(tag<F_BIGNUM>(ulong_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API u64 to_unsigned_8(CELL obj)
{
	switch(tagged<F_OBJECT>(obj).type())
	{
	case FIXNUM_TYPE:
		return untag_fixnum(obj);
	case BIGNUM_TYPE:
		return bignum_to_ulong_long(untag<F_BIGNUM>(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return -1;
	}
}

VM_C_API void box_float(float flo)
{
        dpush(allot_float(flo));
}

VM_C_API float to_float(CELL value)
{
	return untag_float_check(value);
}

VM_C_API void box_double(double flo)
{
        dpush(allot_float(flo));
}

VM_C_API double to_double(CELL value)
{
	return untag_float_check(value);
}

/* The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
overflow, they call these functions. */
VM_ASM_API void overflow_fixnum_add(F_FIXNUM x, F_FIXNUM y)
{
	drepl(tag<F_BIGNUM>(fixnum_to_bignum(
		untag_fixnum(x) + untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_subtract(F_FIXNUM x, F_FIXNUM y)
{
	drepl(tag<F_BIGNUM>(fixnum_to_bignum(
		untag_fixnum(x) - untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_multiply(F_FIXNUM x, F_FIXNUM y)
{
	F_BIGNUM *bx = fixnum_to_bignum(x);
	GC_BIGNUM(bx);
	F_BIGNUM *by = fixnum_to_bignum(y);
	GC_BIGNUM(by);
	drepl(tag<F_BIGNUM>(bignum_multiply(bx,by)));
}
