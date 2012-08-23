#include "master.hpp"

namespace factor
{

void factor_vm::primitive_bignum_to_fixnum()
{
	ctx->replace(tag_fixnum(bignum_to_fixnum(untag<bignum>(ctx->peek()))));
}

void factor_vm::primitive_float_to_fixnum()
{
	ctx->replace(tag_fixnum(float_to_fixnum(ctx->peek())));
}

/* does not allocate, even though from_signed_cell can allocate */
/* Division can only overflow when we are dividing the most negative fixnum
by -1. */
void factor_vm::primitive_fixnum_divint()
{
	fixnum y = untag_fixnum(ctx->pop());
	fixnum x = untag_fixnum(ctx->peek());
	fixnum result = x / y;
	if(result == -fixnum_min)
		/* Does not allocate */
		ctx->replace(from_signed_cell(-fixnum_min));
	else
		ctx->replace(tag_fixnum(result));
}

/* does not allocate, even though from_signed_cell can allocate */
void factor_vm::primitive_fixnum_divmod()
{
	cell *s0 = (cell *)(ctx->datastack);
	cell *s1 = (cell *)(ctx->datastack - sizeof(cell));
	fixnum y = untag_fixnum(*s0);
	fixnum x = untag_fixnum(*s1);
	if(y == -1 && x == fixnum_min)
	{
		/* Does not allocate */
		*s1 = from_signed_cell(-fixnum_min);
		*s0 = tag_fixnum(0);
	}
	else
	{
		*s1 = tag_fixnum(x / y);
		*s0 = tag_fixnum(x % y);
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
	fixnum y = untag_fixnum(ctx->pop());
	fixnum x = untag_fixnum(ctx->peek());

	if(x == 0)
		return;
	else if(y < 0)
	{
		y = branchless_max(y,-WORD_SIZE + 1);
		ctx->replace(tag_fixnum(x >> -y));
		return;
	}
	else if(y < WORD_SIZE - TAG_BITS)
	{
		fixnum mask = -((fixnum)1 << (WORD_SIZE - 1 - TAG_BITS - y));
		if(!(branchless_abs(x) & mask))
		{
			ctx->replace(tag_fixnum(x << y));
			return;
		}
	}

	ctx->replace(tag<bignum>(bignum_arithmetic_shift(
		fixnum_to_bignum(x),y)));
}

void factor_vm::primitive_fixnum_to_bignum()
{
	ctx->replace(tag<bignum>(fixnum_to_bignum(untag_fixnum(ctx->peek()))));
}

void factor_vm::primitive_float_to_bignum()
{
	ctx->replace(tag<bignum>(float_to_bignum(ctx->peek())));
}

#define POP_BIGNUMS(x,y) \
	bignum * y = untag<bignum>(ctx->pop()); \
	bignum * x = untag<bignum>(ctx->pop());

void factor_vm::primitive_bignum_eq()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag_boolean(bignum_equal_p(x,y)));
}

void factor_vm::primitive_bignum_add()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_add(x,y)));
}

void factor_vm::primitive_bignum_subtract()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_subtract(x,y)));
}

void factor_vm::primitive_bignum_multiply()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_multiply(x,y)));
}

void factor_vm::primitive_bignum_divint()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_quotient(x,y)));
}

void factor_vm::primitive_bignum_divmod()
{
	bignum *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	ctx->push(tag<bignum>(q));
	ctx->push(tag<bignum>(r));
}

void factor_vm::primitive_bignum_mod()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_remainder(x,y)));
}

void factor_vm::primitive_bignum_gcd()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_gcd(x,y)));
}

void factor_vm::primitive_bignum_and()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_bitwise_and(x,y)));
}

void factor_vm::primitive_bignum_or()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_bitwise_ior(x,y)));
}

void factor_vm::primitive_bignum_xor()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag<bignum>(bignum_bitwise_xor(x,y)));
}

void factor_vm::primitive_bignum_shift()
{
	fixnum y = untag_fixnum(ctx->pop());
	bignum* x = untag<bignum>(ctx->pop());
	ctx->push(tag<bignum>(bignum_arithmetic_shift(x,y)));
}

void factor_vm::primitive_bignum_less()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag_boolean(bignum_compare(x,y) == bignum_comparison_less));
}

void factor_vm::primitive_bignum_lesseq()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag_boolean(bignum_compare(x,y) != bignum_comparison_greater));
}

void factor_vm::primitive_bignum_greater()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag_boolean(bignum_compare(x,y) == bignum_comparison_greater));
}

void factor_vm::primitive_bignum_greatereq()
{
	POP_BIGNUMS(x,y);
	ctx->push(tag_boolean(bignum_compare(x,y) != bignum_comparison_less));
}

void factor_vm::primitive_bignum_not()
{
	ctx->replace(tag<bignum>(bignum_bitwise_not(untag<bignum>(ctx->peek()))));
}

void factor_vm::primitive_bignum_bitp()
{
	int bit = (int)to_fixnum(ctx->pop());
	bignum *x = untag<bignum>(ctx->pop());
	ctx->push(tag_boolean(bignum_logbitp(bit,x)));
}

void factor_vm::primitive_bignum_log2()
{
	ctx->replace(tag<bignum>(bignum_integer_length(untag<bignum>(ctx->peek()))));
}

/* allocates memory */
cell factor_vm::unbox_array_size_slow()
{
	if(tagged<object>(ctx->peek()).type() == BIGNUM_TYPE)
	{
		bignum *zero = untag<bignum>(bignum_zero);
		GC_BIGNUM(zero);
		bignum *max = cell_to_bignum(array_size_max);
		bignum *n = untag<bignum>(ctx->peek());
		if(bignum_compare(n,zero) != bignum_comparison_less
			&& bignum_compare(n,max) == bignum_comparison_less)
		{
			ctx->pop();
			return bignum_to_cell(n);
		}
	}

	general_error(ERROR_ARRAY_SIZE,ctx->pop(),tag_fixnum(array_size_max));
	return 0; /* can't happen */
}

void factor_vm::primitive_fixnum_to_float()
{
	ctx->replace(allot_float(fixnum_to_float(ctx->peek())));
}

void factor_vm::primitive_format_float()
{
	byte_array *array = allot_byte_array(100);
	char *format = alien_offset(ctx->pop());
	double value = untag_float_check(ctx->pop());
	SNPRINTF(array->data<char>(),99,format,value);
	ctx->push(tag<byte_array>(array));
}

#define POP_FLOATS(x,y) \
	double y = untag_float(ctx->pop()); \
	double x = untag_float(ctx->pop());

void factor_vm::primitive_float_eq()
{
	POP_FLOATS(x,y);
	ctx->push(tag_boolean(x == y));
}

void factor_vm::primitive_float_add()
{
	POP_FLOATS(x,y);
	ctx->push(allot_float(x + y));
}

void factor_vm::primitive_float_subtract()
{
	POP_FLOATS(x,y);
	ctx->push(allot_float(x - y));
}

void factor_vm::primitive_float_multiply()
{
	POP_FLOATS(x,y);
	ctx->push(allot_float(x * y));
}

void factor_vm::primitive_float_divfloat()
{
	POP_FLOATS(x,y);
	ctx->push(allot_float(x / y));
}

void factor_vm::primitive_float_less()
{
	POP_FLOATS(x,y);
	ctx->push(tag_boolean(x < y));
}

void factor_vm::primitive_float_lesseq()
{
	POP_FLOATS(x,y);
	ctx->push(tag_boolean(x <= y));
}

void factor_vm::primitive_float_greater()
{
	POP_FLOATS(x,y);
	ctx->push(tag_boolean(x > y));
}

void factor_vm::primitive_float_greatereq()
{
	POP_FLOATS(x,y);
	ctx->push(tag_boolean(x >= y));
}

/* Allocates memory */
void factor_vm::primitive_float_bits()
{
	ctx->push(from_unsigned_cell(float_bits((float)untag_float_check(ctx->pop()))));
}

/* Allocates memory */
void factor_vm::primitive_bits_float()
{
	ctx->push(allot_float(bits_float((u32)to_cell(ctx->pop()))));
}

void factor_vm::primitive_double_bits()
{
	ctx->push(from_unsigned_8(double_bits(untag_float_check(ctx->pop()))));
}

void factor_vm::primitive_bits_double()
{
	ctx->push(allot_float(bits_double(to_unsigned_8(ctx->pop()))));
}

/* Cannot allocate */
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

VM_C_API fixnum to_fixnum(cell tagged, factor_vm *parent)
{
	return parent->to_fixnum(tagged);
}

cell factor_vm::to_cell(cell tagged)
{
	return (cell)to_fixnum(tagged);
}

VM_C_API cell to_cell(cell tagged, factor_vm *parent)
{
	return parent->to_cell(tagged);
}

/* Allocates memory */
VM_C_API cell from_signed_cell(fixnum integer, factor_vm *parent)
{
	return parent->from_signed_cell(integer);
}

/* Allocates memory */
VM_C_API cell from_unsigned_cell(cell integer, factor_vm *parent)
{
	return parent->from_unsigned_cell(integer);
}

/* Allocates memory */
cell factor_vm::from_signed_8(s64 n)
{
	if(n < fixnum_min || n > fixnum_max)
		return tag<bignum>(long_long_to_bignum(n));
	else
		return tag_fixnum((fixnum)n);
}

VM_C_API cell from_signed_8(s64 n, factor_vm *parent)
{
	return parent->from_signed_8(n);
}

/* Cannot allocate */
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

VM_C_API s64 to_signed_8(cell obj, factor_vm *parent)
{
	return parent->to_signed_8(obj);
}

cell factor_vm::from_unsigned_8(u64 n)
{
	if(n > (u64)fixnum_max)
		return tag<bignum>(ulong_long_to_bignum(n));
	else
		return tag_fixnum((fixnum)n);
}

VM_C_API cell from_unsigned_8(u64 n, factor_vm *parent)
{
	return parent->from_unsigned_8(n);
}

/* Cannot allocate */
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

VM_C_API u64 to_unsigned_8(cell obj, factor_vm *parent)
{
	return parent->to_unsigned_8(obj);
}
 
/* Cannot allocate */
float factor_vm::to_float(cell value)
{
	return (float)untag_float_check(value);
}

/* Cannot allocate */
double factor_vm::to_double(cell value)
{
	return untag_float_check(value);
}

/* The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
overflow, they call these functions. */
inline void factor_vm::overflow_fixnum_add(fixnum x, fixnum y)
{
	ctx->replace(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) + untag_fixnum(y))));
}

VM_C_API void overflow_fixnum_add(fixnum x, fixnum y, factor_vm *parent)
{
	parent->overflow_fixnum_add(x,y);
}

inline void factor_vm::overflow_fixnum_subtract(fixnum x, fixnum y)
{
	ctx->replace(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) - untag_fixnum(y))));
}

VM_C_API void overflow_fixnum_subtract(fixnum x, fixnum y, factor_vm *parent)
{
	parent->overflow_fixnum_subtract(x,y);
}

inline void factor_vm::overflow_fixnum_multiply(fixnum x, fixnum y)
{
	bignum *bx = fixnum_to_bignum(x);
	GC_BIGNUM(bx);
	bignum *by = fixnum_to_bignum(y);
	GC_BIGNUM(by);
	ctx->replace(tag<bignum>(bignum_multiply(bx,by)));
}

VM_C_API void overflow_fixnum_multiply(fixnum x, fixnum y, factor_vm *parent)
{
	parent->overflow_fixnum_multiply(x,y);
}

}
