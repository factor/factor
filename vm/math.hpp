namespace factor
{

extern CELL bignum_zero;
extern CELL bignum_pos_one;
extern CELL bignum_neg_one;

#define CELL_MAX (CELL)(-1)
#define FIXNUM_MAX (((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)))
#define ARRAY_SIZE_MAX ((CELL)1 << (WORD_SIZE - TAG_BITS - 2))

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

inline static CELL allot_integer(F_FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag<F_BIGNUM>(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline static CELL allot_cell(CELL x)
{
	if(x > (CELL)FIXNUM_MAX)
		return tag<F_BIGNUM>(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

CELL unbox_array_size(void);

inline static double untag_float(CELL tagged)
{
	return untag<F_FLOAT>(tagged)->n;
}

inline static double untag_float_check(CELL tagged)
{
	return untag_check<F_FLOAT>(tagged)->n;
}

inline static CELL allot_float(double n)
{
	F_FLOAT *flo = allot<F_FLOAT>(sizeof(F_FLOAT));
	flo->n = n;
	return tag(flo);
}

inline static F_FIXNUM float_to_fixnum(CELL tagged)
{
	return (F_FIXNUM)untag_float(tagged);
}

inline static F_BIGNUM *float_to_bignum(CELL tagged)
{
	return double_to_bignum(untag_float(tagged));
}

inline static double fixnum_to_float(CELL tagged)
{
	return (double)untag_fixnum(tagged);
}

inline static double bignum_to_float(CELL tagged)
{
	return bignum_to_double(untag<F_BIGNUM>(tagged));
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
VM_C_API float to_float(CELL value);
VM_C_API void box_double(double flo);
VM_C_API double to_double(CELL value);

VM_C_API void box_signed_1(s8 n);
VM_C_API void box_unsigned_1(u8 n);
VM_C_API void box_signed_2(s16 n);
VM_C_API void box_unsigned_2(u16 n);
VM_C_API void box_signed_4(s32 n);
VM_C_API void box_unsigned_4(u32 n);
VM_C_API void box_signed_cell(F_FIXNUM integer);
VM_C_API void box_unsigned_cell(CELL cell);
VM_C_API void box_signed_8(s64 n);
VM_C_API void box_unsigned_8(u64 n);

VM_C_API s64 to_signed_8(CELL obj);
VM_C_API u64 to_unsigned_8(CELL obj);

VM_C_API F_FIXNUM to_fixnum(CELL tagged);
VM_C_API CELL to_cell(CELL tagged);

VM_ASM_API void overflow_fixnum_add(F_FIXNUM x, F_FIXNUM y);
VM_ASM_API void overflow_fixnum_subtract(F_FIXNUM x, F_FIXNUM y);
VM_ASM_API void overflow_fixnum_multiply(F_FIXNUM x, F_FIXNUM y);

}
