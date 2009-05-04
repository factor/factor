namespace factor
{

extern cell bignum_zero;
extern cell bignum_pos_one;
extern cell bignum_neg_one;

#define cell_MAX (cell)(-1)
#define FIXNUM_MAX (((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)))
#define ARRAY_SIZE_MAX ((cell)1 << (WORD_SIZE - TAG_BITS - 2))

PRIMITIVE(fixnum_add);
PRIMITIVE(fixnum_subtract);
PRIMITIVE(fixnum_multiply);

PRIMITIVE(bignum_to_fixnum);
PRIMITIVE(float_to_fixnum);

PRIMITIVE(fixnum_divint);
PRIMITIVE(fixnum_divmod);
PRIMITIVE(fixnum_shift);

PRIMITIVE(fixnum_to_bignum);
PRIMITIVE(float_to_bignum);
PRIMITIVE(bignum_eq);
PRIMITIVE(bignum_add);
PRIMITIVE(bignum_subtract);
PRIMITIVE(bignum_multiply);
PRIMITIVE(bignum_divint);
PRIMITIVE(bignum_divmod);
PRIMITIVE(bignum_mod);
PRIMITIVE(bignum_and);
PRIMITIVE(bignum_or);
PRIMITIVE(bignum_xor);
PRIMITIVE(bignum_shift);
PRIMITIVE(bignum_less);
PRIMITIVE(bignum_lesseq);
PRIMITIVE(bignum_greater);
PRIMITIVE(bignum_greatereq);
PRIMITIVE(bignum_not);
PRIMITIVE(bignum_bitp);
PRIMITIVE(bignum_log2);
PRIMITIVE(byte_array_to_bignum);

inline static cell allot_integer(fixnum x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag<bignum>(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline static cell allot_cell(cell x)
{
	if(x > (cell)FIXNUM_MAX)
		return tag<bignum>(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

cell unbox_array_size(void);

inline static double untag_float(cell tagged)
{
	return untag<boxed_float>(tagged)->n;
}

inline static double untag_float_check(cell tagged)
{
	return untag_check<boxed_float>(tagged)->n;
}

inline static cell allot_float(double n)
{
	boxed_float *flo = allot<boxed_float>(sizeof(boxed_float));
	flo->n = n;
	return tag(flo);
}

inline static fixnum float_to_fixnum(cell tagged)
{
	return (fixnum)untag_float(tagged);
}

inline static bignum *float_to_bignum(cell tagged)
{
	return double_to_bignum(untag_float(tagged));
}

inline static double fixnum_to_float(cell tagged)
{
	return (double)untag_fixnum(tagged);
}

inline static double bignum_to_float(cell tagged)
{
	return bignum_to_double(untag<bignum>(tagged));
}

PRIMITIVE(fixnum_to_float);
PRIMITIVE(bignum_to_float);
PRIMITIVE(str_to_float);
PRIMITIVE(float_to_str);
PRIMITIVE(float_to_bits);

PRIMITIVE(float_eq);
PRIMITIVE(float_add);
PRIMITIVE(float_subtract);
PRIMITIVE(float_multiply);
PRIMITIVE(float_divfloat);
PRIMITIVE(float_mod);
PRIMITIVE(float_less);
PRIMITIVE(float_lesseq);
PRIMITIVE(float_greater);
PRIMITIVE(float_greatereq);

PRIMITIVE(float_bits);
PRIMITIVE(bits_float);
PRIMITIVE(double_bits);
PRIMITIVE(bits_double);

VM_C_API void box_float(float flo);
VM_C_API float to_float(cell value);
VM_C_API void box_double(double flo);
VM_C_API double to_double(cell value);

VM_C_API void box_signed_1(s8 n);
VM_C_API void box_unsigned_1(u8 n);
VM_C_API void box_signed_2(s16 n);
VM_C_API void box_unsigned_2(u16 n);
VM_C_API void box_signed_4(s32 n);
VM_C_API void box_unsigned_4(u32 n);
VM_C_API void box_signed_cell(fixnum integer);
VM_C_API void box_unsigned_cell(cell cell);
VM_C_API void box_signed_8(s64 n);
VM_C_API void box_unsigned_8(u64 n);

VM_C_API s64 to_signed_8(cell obj);
VM_C_API u64 to_unsigned_8(cell obj);

VM_C_API fixnum to_fixnum(cell tagged);
VM_C_API cell to_cell(cell tagged);

VM_ASM_API void overflow_fixnum_add(fixnum x, fixnum y);
VM_ASM_API void overflow_fixnum_subtract(fixnum x, fixnum y);
VM_ASM_API void overflow_fixnum_multiply(fixnum x, fixnum y);

}
