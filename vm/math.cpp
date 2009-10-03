#include "master.hpp"

namespace factor
{

void factor_vm::primitive_bignum_to_fixnum()
{
	drepl(tag_fixnum(bignum_to_fixnum(untag<bignum>(dpeek()))));
}

void factor_vm::primitive_float_to_fixnum()
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

/* Division can only overflow when we are dividing the most negative fixnum
by -1. */
void factor_vm::primitive_fixnum_divint()
{
	fixnum y = untag_fixnum(dpop()); \
	fixnum x = untag_fixnum(dpeek());
	fixnum result = x / y;
	if(result == -fixnum_min)
		drepl(allot_integer(-fixnum_min));
	else
		drepl(tag_fixnum(result));
}

void factor_vm::primitive_fixnum_divmod()
{
	cell y = ((cell *)ds)[0];
	cell x = ((cell *)ds)[-1];
	if(y == tag_fixnum(-1) && x == tag_fixnum(fixnum_min))
	{
		((cell *)ds)[-1] = allot_integer(-fixnum_min);
		((cell *)ds)[0] = tag_fixnum(0);
	}
	else
	{
		((cell *)ds)[-1] = tag_fixnum(untag_fixnum(x) / untag_fixnum(y));
		((cell *)ds)[0] = (fixnum)x % (fixnum)y;
	}
}

/*
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
inline fixnum factor_vm::sign_mask(fixnum x)
{
	return x >> (WORD_SIZE - 1);
}

inline fixnum factor_vm::branchless_max(fixnum x, fixnum y)
{
	return (x - ((x - y) & sign_mask(x - y)));
}

inline fixnum factor_vm::branchless_abs(fixnum x)
{
	return (x ^ sign_mask(x)) - sign_mask(x);
}

void factor_vm::primitive_fixnum_shift()
{
	fixnum y = untag_fixnum(dpop());
	fixnum x = untag_fixnum(dpeek());

	if(x == 0)
		return;
	else if(y < 0)
	{
		y = branchless_max(y,-WORD_SIZE + 1);
		drepl(tag_fixnum(x >> -y));
		return;
	}
	else if(y < WORD_SIZE - TAG_BITS)
	{
		fixnum mask = -((fixnum)1 << (WORD_SIZE - 1 - TAG_BITS - y));
		if(!(branchless_abs(x) & mask))
		{
			drepl(tag_fixnum(x << y));
			return;
		}
	}

	drepl(tag<bignum>(bignum_arithmetic_shift(
		fixnum_to_bignum(x),y)));
}

void factor_vm::primitive_fixnum_to_bignum()
{
	drepl(tag<bignum>(fixnum_to_bignum(untag_fixnum(dpeek()))));
}

void factor_vm::primitive_float_to_bignum()
{
	drepl(tag<bignum>(float_to_bignum(dpeek())));
}

#define POP_BIGNUMS(x,y) \
	bignum * y = untag<bignum>(dpop()); \
	bignum * x = untag<bignum>(dpop());

void factor_vm::primitive_bignum_eq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_equal_p(x,y));
}

void factor_vm::primitive_bignum_add()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_add(x,y)));
}

void factor_vm::primitive_bignum_subtract()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_subtract(x,y)));
}

void factor_vm::primitive_bignum_multiply()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_multiply(x,y)));
}

void factor_vm::primitive_bignum_divint()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_quotient(x,y)));
}

void factor_vm::primitive_bignum_divmod()
{
	bignum *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	dpush(tag<bignum>(q));
	dpush(tag<bignum>(r));
}

void factor_vm::primitive_bignum_mod()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_remainder(x,y)));
}

void factor_vm::primitive_bignum_and()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_and(x,y)));
}

void factor_vm::primitive_bignum_or()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_ior(x,y)));
}

void factor_vm::primitive_bignum_xor()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_xor(x,y)));
}

void factor_vm::primitive_bignum_shift()
{
	fixnum y = untag_fixnum(dpop());
        bignum* x = untag<bignum>(dpop());
	dpush(tag<bignum>(bignum_arithmetic_shift(x,y)));
}

void factor_vm::primitive_bignum_less()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_less);
}

void factor_vm::primitive_bignum_lesseq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_greater);
}

void factor_vm::primitive_bignum_greater()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_greater);
}

void factor_vm::primitive_bignum_greatereq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_less);
}

void factor_vm::primitive_bignum_not()
{
	drepl(tag<bignum>(bignum_bitwise_not(untag<bignum>(dpeek()))));
}

void factor_vm::primitive_bignum_bitp()
{
	fixnum bit = to_fixnum(dpop());
	bignum *x = untag<bignum>(dpop());
	box_boolean(bignum_logbitp(bit,x));
}

void factor_vm::primitive_bignum_log2()
{
	drepl(tag<bignum>(bignum_integer_length(untag<bignum>(dpeek()))));
}

unsigned int factor_vm::bignum_producer(unsigned int digit)
{
	unsigned char *ptr = (unsigned char *)alien_offset(dpeek());
	return *(ptr + digit);
}

unsigned int bignum_producer(unsigned int digit, factor_vm *myvm)
{
	return myvm->bignum_producer(digit);
}

void factor_vm::primitive_byte_array_to_bignum()
{
	cell n_digits = array_capacity(untag_check<byte_array>(dpeek()));
	bignum * result = digit_stream_to_bignum(n_digits,factor::bignum_producer,0x100,0);
	drepl(tag<bignum>(result));
}

cell factor_vm::unbox_array_size()
{
	switch(tagged<object>(dpeek()).type())
	{
	case FIXNUM_TYPE:
		{
			fixnum n = untag_fixnum(dpeek());
			if(n >= 0 && n < (fixnum)array_size_max)
			{
				dpop();
				return n;
			}
			break;
		}
	case BIGNUM_TYPE:
		{
			bignum * zero = untag<bignum>(bignum_zero);
			bignum * max = cell_to_bignum(array_size_max);
			bignum * n = untag<bignum>(dpeek());
			if(bignum_compare(n,zero) != bignum_comparison_less
				&& bignum_compare(n,max) == bignum_comparison_less)
			{
				dpop();
				return bignum_to_cell(n);
			}
			break;
		}
	}

	general_error(ERROR_ARRAY_SIZE,dpop(),tag_fixnum(array_size_max),NULL);
	return 0; /* can't happen */
}

void factor_vm::primitive_fixnum_to_float()
{
	drepl(allot_float(fixnum_to_float(dpeek())));
}

void factor_vm::primitive_bignum_to_float()
{
	drepl(allot_float(bignum_to_float(dpeek())));
}

void factor_vm::primitive_str_to_float()
{
	byte_array *bytes = untag_check<byte_array>(dpeek());
	cell capacity = array_capacity(bytes);

	char *c_str = (char *)(bytes + 1);
	char *end = c_str;
	double f = strtod(c_str,&end);
	if(end == c_str + capacity - 1)
		drepl(allot_float(f));
	else
		drepl(F);
}

void factor_vm::primitive_float_to_str()
{
	byte_array *array = allot_byte_array(33);
	snprintf((char *)(array + 1),32,"%.16g",untag_float_check(dpop()));
	dpush(tag<byte_array>(array));
}

#define POP_FLOATS(x,y) \
	double y = untag_float(dpop()); \
	double x = untag_float(dpop());

void factor_vm::primitive_float_eq()
{
	POP_FLOATS(x,y);
	box_boolean(x == y);
}

void factor_vm::primitive_float_add()
{
	POP_FLOATS(x,y);
	box_double(x + y);
}

void factor_vm::primitive_float_subtract()
{
	POP_FLOATS(x,y);
	box_double(x - y);
}

void factor_vm::primitive_float_multiply()
{
	POP_FLOATS(x,y);
	box_double(x * y);
}

void factor_vm::primitive_float_divfloat()
{
	POP_FLOATS(x,y);
	box_double(x / y);
}

void factor_vm::primitive_float_mod()
{
	POP_FLOATS(x,y);
	box_double(fmod(x,y));
}

void factor_vm::primitive_float_less()
{
	POP_FLOATS(x,y);
	box_boolean(x < y);
}

void factor_vm::primitive_float_lesseq()
{
	POP_FLOATS(x,y);
	box_boolean(x <= y);
}

void factor_vm::primitive_float_greater()
{
	POP_FLOATS(x,y);
	box_boolean(x > y);
}

void factor_vm::primitive_float_greatereq()
{
	POP_FLOATS(x,y);
	box_boolean(x >= y);
}

void factor_vm::primitive_float_bits()
{
	box_unsigned_4(float_bits(untag_float_check(dpop())));
}

void factor_vm::primitive_bits_float()
{
	box_float(bits_float(to_cell(dpop())));
}

void factor_vm::primitive_double_bits()
{
	box_unsigned_8(double_bits(untag_float_check(dpop())));
}

void factor_vm::primitive_bits_double()
{
	box_double(bits_double(to_unsigned_8(dpop())));
}

fixnum factor_vm::to_fixnum(cell tagged)
{
	switch(TAG(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(untag<bignum>(tagged));
	default:
		type_error(FIXNUM_TYPE,tagged);
		return 0; /* can't happen */
	}
}

VM_C_API fixnum to_fixnum(cell tagged,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_fixnum(tagged);
}

cell factor_vm::to_cell(cell tagged)
{
	return (cell)to_fixnum(tagged);
}

VM_C_API cell to_cell(cell tagged, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_cell(tagged);
}

void factor_vm::box_signed_1(s8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_1(s8 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_signed_1(n);
}

void factor_vm::box_unsigned_1(u8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_1(u8 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_unsigned_1(n);
}

void factor_vm::box_signed_2(s16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_2(s16 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_signed_2(n);
}

void factor_vm::box_unsigned_2(u16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_2(u16 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_unsigned_2(n);
}

void factor_vm::box_signed_4(s32 n)
{
	dpush(allot_integer(n));
}

VM_C_API void box_signed_4(s32 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_signed_4(n);
}

void factor_vm::box_unsigned_4(u32 n)
{
	dpush(allot_cell(n));
}

VM_C_API void box_unsigned_4(u32 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_unsigned_4(n);
}

void factor_vm::box_signed_cell(fixnum integer)
{
	dpush(allot_integer(integer));
}

VM_C_API void box_signed_cell(fixnum integer,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_signed_cell(integer);
}

void factor_vm::box_unsigned_cell(cell cell)
{
	dpush(allot_cell(cell));
}

VM_C_API void box_unsigned_cell(cell cell,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_unsigned_cell(cell);
}

void factor_vm::box_signed_8(s64 n)
{
	if(n < fixnum_min || n > fixnum_max)
		dpush(tag<bignum>(long_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API void box_signed_8(s64 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_signed_8(n);
}

s64 factor_vm::to_signed_8(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case FIXNUM_TYPE:
		return untag_fixnum(obj);
	case BIGNUM_TYPE:
		return bignum_to_long_long(untag<bignum>(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return 0;
	}
}

VM_C_API s64 to_signed_8(cell obj,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_signed_8(obj);
}

void factor_vm::box_unsigned_8(u64 n)
{
	if(n > (u64)fixnum_max)
		dpush(tag<bignum>(ulong_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_8(u64 n,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_unsigned_8(n);
}

u64 factor_vm::to_unsigned_8(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case FIXNUM_TYPE:
		return untag_fixnum(obj);
	case BIGNUM_TYPE:
		return bignum_to_ulong_long(untag<bignum>(obj));
	default:
		type_error(BIGNUM_TYPE,obj);
		return 0;
	}
}

VM_C_API u64 to_unsigned_8(cell obj,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_unsigned_8(obj);
}
 
void factor_vm::box_float(float flo)
{
        dpush(allot_float(flo));
}

VM_C_API void box_float(float flo, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_float(flo);
}

float factor_vm::to_float(cell value)
{
	return untag_float_check(value);
}

VM_C_API float to_float(cell value,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_float(value);
}

void factor_vm::box_double(double flo)
{
        dpush(allot_float(flo));
}

VM_C_API void box_double(double flo,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_double(flo);
}

double factor_vm::to_double(cell value)
{
	return untag_float_check(value);
}

VM_C_API double to_double(cell value,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_double(value);
}

/* The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
overflow, they call these functions. */
inline void factor_vm::overflow_fixnum_add(fixnum x, fixnum y)
{
	drepl(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) + untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_add(fixnum x, fixnum y, factor_vm *myvm)
{
	PRIMITIVE_OVERFLOW_GETVM()->overflow_fixnum_add(x,y);
}

inline void factor_vm::overflow_fixnum_subtract(fixnum x, fixnum y)
{
	drepl(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) - untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_subtract(fixnum x, fixnum y, factor_vm *myvm)
{
	PRIMITIVE_OVERFLOW_GETVM()->overflow_fixnum_subtract(x,y);
}

inline void factor_vm::overflow_fixnum_multiply(fixnum x, fixnum y)
{
	bignum *bx = fixnum_to_bignum(x);
	GC_BIGNUM(bx);
	bignum *by = fixnum_to_bignum(y);
	GC_BIGNUM(by);
	drepl(tag<bignum>(bignum_multiply(bx,by)));
}

VM_ASM_API void overflow_fixnum_multiply(fixnum x, fixnum y, factor_vm *myvm)
{
	PRIMITIVE_OVERFLOW_GETVM()->overflow_fixnum_multiply(x,y);
}

}
