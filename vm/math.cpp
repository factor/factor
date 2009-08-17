#include "master.hpp"

namespace factor
{

cell bignum_zero;
cell bignum_pos_one;
cell bignum_neg_one;

inline void factorvm::vmprim_bignum_to_fixnum()
{
	drepl(tag_fixnum(bignum_to_fixnum(untag<bignum>(dpeek()))));
}

PRIMITIVE(bignum_to_fixnum)
{
	PRIMITIVE_GETVM()->vmprim_bignum_to_fixnum();
}

inline void factorvm::vmprim_float_to_fixnum()
{
	drepl(tag_fixnum(float_to_fixnum(dpeek())));
}

PRIMITIVE(float_to_fixnum)
{
	PRIMITIVE_GETVM()->vmprim_float_to_fixnum();
}

/* Division can only overflow when we are dividing the most negative fixnum
by -1. */
inline void factorvm::vmprim_fixnum_divint()
{
	fixnum y = untag_fixnum(dpop()); \
	fixnum x = untag_fixnum(dpeek());
	fixnum result = x / y;
	if(result == -fixnum_min)
		drepl(allot_integer(-fixnum_min));
	else
		drepl(tag_fixnum(result));
}

PRIMITIVE(fixnum_divint)
{
	PRIMITIVE_GETVM()->vmprim_fixnum_divint();
}

inline void factorvm::vmprim_fixnum_divmod()
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

PRIMITIVE(fixnum_divmod)
{
	PRIMITIVE_GETVM()->vmprim_fixnum_divmod();
}

/*
 * If we're shifting right by n bits, we won't overflow as long as none of the
 * high WORD_SIZE-TAG_BITS-n bits are set.
 */
inline fixnum factorvm::sign_mask(fixnum x)
{
	return x >> (WORD_SIZE - 1);
}

inline fixnum sign_mask(fixnum x)
{
	return vm->sign_mask(x);
}

inline fixnum factorvm::branchless_max(fixnum x, fixnum y)
{
	return (x - ((x - y) & sign_mask(x - y)));
}

inline fixnum branchless_max(fixnum x, fixnum y)
{
	return vm->branchless_max(x,y);
}

inline fixnum factorvm::branchless_abs(fixnum x)
{
	return (x ^ sign_mask(x)) - sign_mask(x);
}

inline fixnum branchless_abs(fixnum x)
{
	return vm->branchless_abs(x);
}

inline void factorvm::vmprim_fixnum_shift()
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

PRIMITIVE(fixnum_shift)
{
	PRIMITIVE_GETVM()->vmprim_fixnum_shift();
}

inline void factorvm::vmprim_fixnum_to_bignum()
{
	drepl(tag<bignum>(fixnum_to_bignum(untag_fixnum(dpeek()))));
}

PRIMITIVE(fixnum_to_bignum)
{
	PRIMITIVE_GETVM()->vmprim_fixnum_to_bignum();
}

inline void factorvm::vmprim_float_to_bignum()
{
	drepl(tag<bignum>(float_to_bignum(dpeek())));
}

PRIMITIVE(float_to_bignum)
{
	PRIMITIVE_GETVM()->vmprim_float_to_bignum();
}

#define POP_BIGNUMS(x,y) \
	bignum * y = untag<bignum>(dpop()); \
	bignum * x = untag<bignum>(dpop());

inline void factorvm::vmprim_bignum_eq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_equal_p(x,y));
}

PRIMITIVE(bignum_eq)
{
	PRIMITIVE_GETVM()->vmprim_bignum_eq();
}

inline void factorvm::vmprim_bignum_add()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_add(x,y)));
}

PRIMITIVE(bignum_add)
{
	PRIMITIVE_GETVM()->vmprim_bignum_add();
}

inline void factorvm::vmprim_bignum_subtract()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_subtract(x,y)));
}

PRIMITIVE(bignum_subtract)
{
	PRIMITIVE_GETVM()->vmprim_bignum_subtract();
}

inline void factorvm::vmprim_bignum_multiply()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_multiply(x,y)));
}

PRIMITIVE(bignum_multiply)
{
	PRIMITIVE_GETVM()->vmprim_bignum_multiply();
}

inline void factorvm::vmprim_bignum_divint()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_quotient(x,y)));
}

PRIMITIVE(bignum_divint)
{
	PRIMITIVE_GETVM()->vmprim_bignum_divint();
}

inline void factorvm::vmprim_bignum_divmod()
{
	bignum *q, *r;
	POP_BIGNUMS(x,y);
	bignum_divide(x,y,&q,&r);
	dpush(tag<bignum>(q));
	dpush(tag<bignum>(r));
}

PRIMITIVE(bignum_divmod)
{
	PRIMITIVE_GETVM()->vmprim_bignum_divmod();
}

inline void factorvm::vmprim_bignum_mod()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_remainder(x,y)));
}

PRIMITIVE(bignum_mod)
{
	PRIMITIVE_GETVM()->vmprim_bignum_mod();
}

inline void factorvm::vmprim_bignum_and()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_and(x,y)));
}

PRIMITIVE(bignum_and)
{
	PRIMITIVE_GETVM()->vmprim_bignum_and();
}

inline void factorvm::vmprim_bignum_or()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_ior(x,y)));
}

PRIMITIVE(bignum_or)
{
	PRIMITIVE_GETVM()->vmprim_bignum_or();
}

inline void factorvm::vmprim_bignum_xor()
{
	POP_BIGNUMS(x,y);
	dpush(tag<bignum>(bignum_bitwise_xor(x,y)));
}

PRIMITIVE(bignum_xor)
{
	PRIMITIVE_GETVM()->vmprim_bignum_xor();
}

inline void factorvm::vmprim_bignum_shift()
{
	fixnum y = untag_fixnum(dpop());
        bignum* x = untag<bignum>(dpop());
	dpush(tag<bignum>(bignum_arithmetic_shift(x,y)));
}

PRIMITIVE(bignum_shift)
{
	PRIMITIVE_GETVM()->vmprim_bignum_shift();
}

inline void factorvm::vmprim_bignum_less()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_less);
}

PRIMITIVE(bignum_less)
{
	PRIMITIVE_GETVM()->vmprim_bignum_less();
}

inline void factorvm::vmprim_bignum_lesseq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_greater);
}

PRIMITIVE(bignum_lesseq)
{
	PRIMITIVE_GETVM()->vmprim_bignum_lesseq();
}

inline void factorvm::vmprim_bignum_greater()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) == bignum_comparison_greater);
}

PRIMITIVE(bignum_greater)
{
	PRIMITIVE_GETVM()->vmprim_bignum_greater();
}

inline void factorvm::vmprim_bignum_greatereq()
{
	POP_BIGNUMS(x,y);
	box_boolean(bignum_compare(x,y) != bignum_comparison_less);
}

PRIMITIVE(bignum_greatereq)
{
	PRIMITIVE_GETVM()->vmprim_bignum_greatereq();
}

inline void factorvm::vmprim_bignum_not()
{
	drepl(tag<bignum>(bignum_bitwise_not(untag<bignum>(dpeek()))));
}

PRIMITIVE(bignum_not)
{
	PRIMITIVE_GETVM()->vmprim_bignum_not();
}

inline void factorvm::vmprim_bignum_bitp()
{
	fixnum bit = to_fixnum(dpop());
	bignum *x = untag<bignum>(dpop());
	box_boolean(bignum_logbitp(bit,x));
}

PRIMITIVE(bignum_bitp)
{
	PRIMITIVE_GETVM()->vmprim_bignum_bitp();
}

inline void factorvm::vmprim_bignum_log2()
{
	drepl(tag<bignum>(bignum_integer_length(untag<bignum>(dpeek()))));
}

PRIMITIVE(bignum_log2)
{
	PRIMITIVE_GETVM()->vmprim_bignum_log2();
}

unsigned int factorvm::bignum_producer(unsigned int digit)
{
	unsigned char *ptr = (unsigned char *)alien_offset(dpeek());
	return *(ptr + digit);
}

unsigned int bignum_producer(unsigned int digit)
{
	return vm->bignum_producer(digit);
}

inline void factorvm::vmprim_byte_array_to_bignum()
{
	cell n_digits = array_capacity(untag_check<byte_array>(dpeek()));
	bignum * result = factor::digit_stream_to_bignum(n_digits,factor::bignum_producer,0x100,0);
	drepl(tag<bignum>(result));
}

PRIMITIVE(byte_array_to_bignum)
{
	PRIMITIVE_GETVM()->vmprim_byte_array_to_bignum();
}

cell factorvm::unbox_array_size()
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

cell unbox_array_size()
{
	return vm->unbox_array_size();
}

inline void factorvm::vmprim_fixnum_to_float()
{
	drepl(allot_float(fixnum_to_float(dpeek())));
}

PRIMITIVE(fixnum_to_float)
{
	PRIMITIVE_GETVM()->vmprim_fixnum_to_float();
}

inline void factorvm::vmprim_bignum_to_float()
{
	drepl(allot_float(bignum_to_float(dpeek())));
}

PRIMITIVE(bignum_to_float)
{
	PRIMITIVE_GETVM()->vmprim_bignum_to_float();
}

inline void factorvm::vmprim_str_to_float()
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

PRIMITIVE(str_to_float)
{
	PRIMITIVE_GETVM()->vmprim_str_to_float();
}

inline void factorvm::vmprim_float_to_str()
{
	byte_array *array = allot_byte_array(33);
	snprintf((char *)(array + 1),32,"%.16g",untag_float_check(dpop()));
	dpush(tag<byte_array>(array));
}

PRIMITIVE(float_to_str)
{
	PRIMITIVE_GETVM()->vmprim_float_to_str();
}

#define POP_FLOATS(x,y) \
	double y = untag_float(dpop()); \
	double x = untag_float(dpop());

inline void factorvm::vmprim_float_eq()
{
	POP_FLOATS(x,y);
	box_boolean(x == y);
}

PRIMITIVE(float_eq)
{
	PRIMITIVE_GETVM()->vmprim_float_eq();
}

inline void factorvm::vmprim_float_add()
{
	POP_FLOATS(x,y);
	box_double(x + y);
}

PRIMITIVE(float_add)
{
	PRIMITIVE_GETVM()->vmprim_float_add();
}

inline void factorvm::vmprim_float_subtract()
{
	POP_FLOATS(x,y);
	box_double(x - y);
}

PRIMITIVE(float_subtract)
{
	PRIMITIVE_GETVM()->vmprim_float_subtract();
}

inline void factorvm::vmprim_float_multiply()
{
	POP_FLOATS(x,y);
	box_double(x * y);
}

PRIMITIVE(float_multiply)
{
	PRIMITIVE_GETVM()->vmprim_float_multiply();
}

inline void factorvm::vmprim_float_divfloat()
{
	POP_FLOATS(x,y);
	box_double(x / y);
}

PRIMITIVE(float_divfloat)
{
	PRIMITIVE_GETVM()->vmprim_float_divfloat();
}

inline void factorvm::vmprim_float_mod()
{
	POP_FLOATS(x,y);
	box_double(fmod(x,y));
}

PRIMITIVE(float_mod)
{
	PRIMITIVE_GETVM()->vmprim_float_mod();
}

inline void factorvm::vmprim_float_less()
{
	POP_FLOATS(x,y);
	box_boolean(x < y);
}

PRIMITIVE(float_less)
{
	PRIMITIVE_GETVM()->vmprim_float_less();
}

inline void factorvm::vmprim_float_lesseq()
{
	POP_FLOATS(x,y);
	box_boolean(x <= y);
}

PRIMITIVE(float_lesseq)
{
	PRIMITIVE_GETVM()->vmprim_float_lesseq();
}

inline void factorvm::vmprim_float_greater()
{
	POP_FLOATS(x,y);
	box_boolean(x > y);
}

PRIMITIVE(float_greater)
{
	PRIMITIVE_GETVM()->vmprim_float_greater();
}

inline void factorvm::vmprim_float_greatereq()
{
	POP_FLOATS(x,y);
	box_boolean(x >= y);
}

PRIMITIVE(float_greatereq)
{
	PRIMITIVE_GETVM()->vmprim_float_greatereq();
}

inline void factorvm::vmprim_float_bits()
{
	box_unsigned_4(float_bits(untag_float_check(dpop())));
}

PRIMITIVE(float_bits)
{
	PRIMITIVE_GETVM()->vmprim_float_bits();
}

inline void factorvm::vmprim_bits_float()
{
	box_float(bits_float(to_cell(dpop())));
}

PRIMITIVE(bits_float)
{
	PRIMITIVE_GETVM()->vmprim_bits_float();
}

inline void factorvm::vmprim_double_bits()
{
	box_unsigned_8(double_bits(untag_float_check(dpop())));
}

PRIMITIVE(double_bits)
{
	PRIMITIVE_GETVM()->vmprim_double_bits();
}

inline void factorvm::vmprim_bits_double()
{
	box_double(bits_double(to_unsigned_8(dpop())));
}

PRIMITIVE(bits_double)
{
	PRIMITIVE_GETVM()->vmprim_bits_double();
}

fixnum factorvm::to_fixnum(cell tagged)
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

VM_C_API fixnum to_fixnum(cell tagged)
{
	return vm->to_fixnum(tagged);
}

cell factorvm::to_cell(cell tagged)
{
	return (cell)to_fixnum(tagged);
}

VM_C_API cell to_cell(cell tagged)
{
	return vm->to_cell(tagged);
}

void factorvm::box_signed_1(s8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_1(s8 n)
{
	return vm->box_signed_1(n);
}

void factorvm::box_unsigned_1(u8 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_1(u8 n)
{
	return vm->box_unsigned_1(n);
}

void factorvm::box_signed_2(s16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_signed_2(s16 n)
{
	return vm->box_signed_2(n);
}

void factorvm::box_unsigned_2(u16 n)
{
	dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_2(u16 n)
{
	return vm->box_unsigned_2(n);
}

void factorvm::box_signed_4(s32 n)
{
	dpush(allot_integer(n));
}

VM_C_API void box_signed_4(s32 n)
{
	return vm->box_signed_4(n);
}

void factorvm::box_unsigned_4(u32 n)
{
	dpush(allot_cell(n));
}

VM_C_API void box_unsigned_4(u32 n)
{
	return vm->box_unsigned_4(n);
}

void factorvm::box_signed_cell(fixnum integer)
{
	dpush(allot_integer(integer));
}

VM_C_API void box_signed_cell(fixnum integer)
{
	return vm->box_signed_cell(integer);
}

void factorvm::box_unsigned_cell(cell cell)
{
	dpush(allot_cell(cell));
}

VM_C_API void box_unsigned_cell(cell cell)
{
	return vm->box_unsigned_cell(cell);
}

void factorvm::box_signed_8(s64 n)
{
	if(n < fixnum_min || n > fixnum_max)
		dpush(tag<bignum>(long_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API void box_signed_8(s64 n)
{
	return vm->box_signed_8(n);
}

s64 factorvm::to_signed_8(cell obj)
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

VM_C_API s64 to_signed_8(cell obj)
{
	return vm->to_signed_8(obj);
}

void factorvm::box_unsigned_8(u64 n)
{
	if(n > (u64)fixnum_max)
		dpush(tag<bignum>(ulong_long_to_bignum(n)));
	else
		dpush(tag_fixnum(n));
}

VM_C_API void box_unsigned_8(u64 n)
{
	return vm->box_unsigned_8(n);
}

u64 factorvm::to_unsigned_8(cell obj)
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

VM_C_API u64 to_unsigned_8(cell obj)
{
	return vm->to_unsigned_8(obj);
}

void factorvm::box_float(float flo)
{
        dpush(allot_float(flo));
}

VM_C_API void box_float(float flo)
{
	return vm->box_float(flo);
}

float factorvm::to_float(cell value)
{
	return untag_float_check(value);
}

VM_C_API float to_float(cell value)
{
	return vm->to_float(value);
}

void factorvm::box_double(double flo)
{
        dpush(allot_float(flo));
}

VM_C_API void box_double(double flo)
{
	return vm->box_double(flo);
}

double factorvm::to_double(cell value)
{
	return untag_float_check(value);
}

VM_C_API double to_double(cell value)
{
	return vm->to_double(value);
}

/* The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
overflow, they call these functions. */
void factorvm::overflow_fixnum_add(fixnum x, fixnum y)
{
	drepl(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) + untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_add(fixnum x, fixnum y)
{
	return vm->overflow_fixnum_add(x,y);
}

void factorvm::overflow_fixnum_subtract(fixnum x, fixnum y)
{
	drepl(tag<bignum>(fixnum_to_bignum(
		untag_fixnum(x) - untag_fixnum(y))));
}

VM_ASM_API void overflow_fixnum_subtract(fixnum x, fixnum y)
{
	return vm->overflow_fixnum_subtract(x,y);
}

void factorvm::overflow_fixnum_multiply(fixnum x, fixnum y)
{
	bignum *bx = fixnum_to_bignum(x);
	GC_BIGNUM(bx);
	bignum *by = fixnum_to_bignum(y);
	GC_BIGNUM(by);
	drepl(tag<bignum>(bignum_multiply(bx,by)));
}

VM_ASM_API void overflow_fixnum_multiply(fixnum x, fixnum y)
{
	return vm->overflow_fixnum_multiply(x,y);
}

}
