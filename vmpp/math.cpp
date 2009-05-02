#include "master.hpp"

CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

/* Fixnums */
F_FIXNUM to_fixnum(CELL tagged)
{
	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(untag_bignum_fast(tagged));
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
	drepl(tag_fixnum(bignum_to_fixnum(untag_bignum_fast(dpeek()))));
}

void primitive_float_to_fixnum(void)
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

/* The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
overflow, they call these functions. */
F_FASTCALL void overflow_fixnum_add(F_FIXNUM x, F_FIXNUM y)
{
	drepl(tag_bignum(fixnum_to_bignum(
		untag_fixnum_fast(x) + untag_fixnum_fast(y))));
}

F_FASTCALL void overflow_fixnum_subtract(F_FIXNUM x, F_FIXNUM y)
{
	drepl(tag_bignum(fixnum_to_bignum(
		untag_fixnum_fast(x) - untag_fixnum_fast(y))));
}

F_FASTCALL void overflow_fixnum_multiply(F_FIXNUM x, F_FIXNUM y)
{
	F_BIGNUM *bx = fixnum_to_bignum(x);
	REGISTER_BIGNUM(bx);
	F_BIGNUM *by = fixnum_to_bignum(y);
	UNREGISTER_BIGNUM(bx);
	drepl(tag_bignum(bignum_multiply(bx,by)));
}

/* Division can only overflow when we are dividing the most negative fixnum
by -1. */
void primitive_fixnum_divint(void)
{
	F_FIXNUM y = untag_fixnum_fast(dpop()); \
	F_FIXNUM x = untag_fixnum_fast(dpeek());
	F_FIXNUM result = x / y;
	if(result == -FIXNUM_MIN)
		drepl(allot_integer(-FIXNUM_MIN));
	else
		drepl(tag_fixnum(result));
}

void primitive_fixnum_divmod(void)
{
	CELL y = get(ds);
	CELL x = get(ds - CELLS);
	if(y == tag_fixnum(-1) && x == tag_fixnum(FIXNUM_MIN))
	{
		put(ds - CELLS,allot_integer(-FIXNUM_MIN));
		put(ds,tag_fixnum(0));
	}
	else
	{
		put(ds - CELLS,tag_fixnum(untag_fixnum_fast(x) / untag_fixnum_fast(y)));
		put(ds,(F_FIXNUM)x % (F_FIXNUM)y);
	}
}

/*
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
#define SIGN_MASK(x) ((x) >> (WORD_SIZE - 1))
#define BRANCHLESS_MAX(x,y) ((x) - (((x) - (y)) & SIGN_MASK((x) - (y))))
#define BRANCHLESS_ABS(x) ((x ^ SIGN_MASK(x)) - SIGN_MASK(x))

void primitive_fixnum_shift(void)
{
	F_FIXNUM y = untag_fixnum_fast(dpop()); \
	F_FIXNUM x = untag_fixnum_fast(dpeek());

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

	drepl(tag_bignum(bignum_arithmetic_shift(
		fixnum_to_bignum(x),y)));
}

/* Bignums */
void primitive_fixnum_to_bignum(void)
{
	drepl(tag_bignum(fixnum_to_bignum(untag_fixnum_fast(dpeek()))));
}

void primitive_float_to_bignum(void)
{
	drepl(tag_bignum(float_to_bignum(dpeek())));
}

#define POP_BIGNUMS(x,y) \
	F_BIGNUM * y = untag_bignum_fast(dpop()); \
	F_BIGNUM * x = untag_bignum_fast(dpop());

void primitive_bignum_eq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_equal_p(x,y));
}

void primitive_bignum_add(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_add(x,y)));
}

void primitive_bignum_subtract(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_subtract(x,y)));
}

void primitive_bignum_multiply(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_multiply(x,y)));
}

void primitive_bignum_divint(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_quotient(x,y)));
}

void primitive_bignum_divmod(void)
{
	F_BIGNUM *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	dpush(tag_bignum(q));
	dpush(tag_bignum(r));
}

void primitive_bignum_mod(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_remainder(x,y)));
}

void primitive_bignum_and(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_and(x,y)));
}

void primitive_bignum_or(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_ior(x,y)));
}

void primitive_bignum_xor(void)
{
	POP_BIGNUMS(x,y);
	dpush(tag_bignum(bignum_bitwise_xor(x,y)));
}

void primitive_bignum_shift(void)
{
	F_FIXNUM y = untag_fixnum_fast(dpop());
        F_BIGNUM* x = untag_bignum_fast(dpop());
	dpush(tag_bignum(bignum_arithmetic_shift(x,y)));
}

void primitive_bignum_less(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_less);
}

void primitive_bignum_lesseq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_greater);
}

void primitive_bignum_greater(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_greater);
}

void primitive_bignum_greatereq(void)
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_less);
}

void primitive_bignum_not(void)
{
	drepl(tag_bignum(bignum_bitwise_not(untag_bignum_fast(dpeek()))));
}

void primitive_bignum_bitp(void)
{
	F_FIXNUM bit = to_fixnum(dpop());
	F_BIGNUM *x = untag_bignum_fast(dpop());
	box_boolean(bignum_logbitp(bit,x));
}

void primitive_bignum_log2(void)
{
	drepl(tag_bignum(bignum_integer_length(untag_bignum_fast(dpeek()))));
}

unsigned int bignum_producer(unsigned int digit)
{
	unsigned char *ptr = (unsigned char *)alien_offset(dpeek());
	return *(ptr + digit);
}

void primitive_byte_array_to_bignum(void)
{
	type_check(BYTE_ARRAY_TYPE,dpeek());
	CELL n_digits = array_capacity(untag_byte_array_fast(dpeek())) / CELLS;
	F_BIGNUM * bignum = digit_stream_to_bignum(
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
		return bignum_to_long_long(untag_bignum_fast(obj));
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
		return bignum_to_ulong_long(untag_bignum_fast(obj));
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
			if(n >= 0 && n < (F_FIXNUM)ARRAY_SIZE_MAX)
			{
				dpop();
				return n;
			}
			break;
		}
	case BIGNUM_TYPE:
		{
			F_BIGNUM * zero = untag_bignum_fast(bignum_zero);
			F_BIGNUM * max = cell_to_bignum(ARRAY_SIZE_MAX);
			F_BIGNUM * n = untag_bignum_fast(dpeek());
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
	F_BYTE_ARRAY *bytes = untag_byte_array(dpeek());
	CELL capacity = array_capacity(bytes);

	char *c_str = (char *)(bytes + 1);
	char *end = c_str;
	double f = strtod(c_str,&end);
	if(end == c_str + capacity - 1)
		drepl(allot_float(f));
	else
		drepl(F);
}

void primitive_float_to_str(void)
{
	F_BYTE_ARRAY *array = allot_byte_array(33);
	snprintf((char *)(array + 1),32,"%.16g",untag_float(dpop()));
	dpush(tag_object(array));
}

#define POP_FLOATS(x,y) \
	double y = untag_float_fast(dpop()); \
	double x = untag_float_fast(dpop());

void primitive_float_eq(void)
{
	POP_FLOATS(x,y);
	box_boolean(x == y);
}

void primitive_float_add(void)
{
	POP_FLOATS(x,y);
	box_double(x + y);
}

void primitive_float_subtract(void)
{
	POP_FLOATS(x,y);
	box_double(x - y);
}

void primitive_float_multiply(void)
{
	POP_FLOATS(x,y);
	box_double(x * y);
}

void primitive_float_divfloat(void)
{
	POP_FLOATS(x,y);
	box_double(x / y);
}

void primitive_float_mod(void)
{
	POP_FLOATS(x,y);
	box_double(fmod(x,y));
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
	box_unsigned_4(float_bits(untag_float(dpop())));
}

void primitive_bits_float(void)
{
	box_float(bits_float(to_cell(dpop())));
}

void primitive_double_bits(void)
{
	box_unsigned_8(double_bits(untag_float(dpop())));
}

void primitive_bits_double(void)
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
