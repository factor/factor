#define CELL_MAX (CELL)(-1)
#define FIXNUM_MAX (((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)))
#define ARRAY_SIZE_MAX ((CELL)1 << (WORD_SIZE - TAG_BITS - 2))

DLLEXPORT F_FIXNUM to_fixnum(CELL tagged);
DLLEXPORT CELL to_cell(CELL tagged);

DECLARE_PRIMITIVE(bignum_to_fixnum);
DECLARE_PRIMITIVE(float_to_fixnum);

DECLARE_PRIMITIVE(fixnum_add);
DECLARE_PRIMITIVE(fixnum_subtract);
DECLARE_PRIMITIVE(fixnum_add_fast);
DECLARE_PRIMITIVE(fixnum_subtract_fast);
DECLARE_PRIMITIVE(fixnum_multiply);
DECLARE_PRIMITIVE(fixnum_multiply_fast);
DECLARE_PRIMITIVE(fixnum_divint);
DECLARE_PRIMITIVE(fixnum_divmod);
DECLARE_PRIMITIVE(fixnum_mod);
DECLARE_PRIMITIVE(fixnum_and);
DECLARE_PRIMITIVE(fixnum_or);
DECLARE_PRIMITIVE(fixnum_xor);
DECLARE_PRIMITIVE(fixnum_shift);
DECLARE_PRIMITIVE(fixnum_less);
DECLARE_PRIMITIVE(fixnum_lesseq);
DECLARE_PRIMITIVE(fixnum_greater);
DECLARE_PRIMITIVE(fixnum_greatereq);
DECLARE_PRIMITIVE(fixnum_not);

CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE CELL tag_bignum(F_ARRAY* bignum)
{
	return RETAG(bignum,BIGNUM_TYPE);
}

DECLARE_PRIMITIVE(fixnum_to_bignum);
DECLARE_PRIMITIVE(float_to_bignum);
DECLARE_PRIMITIVE(bignum_eq);
DECLARE_PRIMITIVE(bignum_add);
DECLARE_PRIMITIVE(bignum_subtract);
DECLARE_PRIMITIVE(bignum_multiply);
DECLARE_PRIMITIVE(bignum_divint);
DECLARE_PRIMITIVE(bignum_divmod);
DECLARE_PRIMITIVE(bignum_mod);
DECLARE_PRIMITIVE(bignum_and);
DECLARE_PRIMITIVE(bignum_or);
DECLARE_PRIMITIVE(bignum_xor);
DECLARE_PRIMITIVE(bignum_shift);
DECLARE_PRIMITIVE(bignum_less);
DECLARE_PRIMITIVE(bignum_lesseq);
DECLARE_PRIMITIVE(bignum_greater);
DECLARE_PRIMITIVE(bignum_greatereq);
DECLARE_PRIMITIVE(bignum_not);
DECLARE_PRIMITIVE(bignum_bitp);
DECLARE_PRIMITIVE(bignum_log2);
DECLARE_PRIMITIVE(byte_array_to_bignum);

INLINE CELL allot_integer(F_FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_bignum(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

INLINE CELL allot_cell(CELL x)
{
	if(x > (CELL)FIXNUM_MAX)
		return tag_bignum(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

/* FFI calls this */
DLLEXPORT void box_signed_1(s8 n);
DLLEXPORT void box_unsigned_1(u8 n);
DLLEXPORT void box_signed_2(s16 n);
DLLEXPORT void box_unsigned_2(u16 n);
DLLEXPORT void box_signed_4(s32 n);
DLLEXPORT void box_unsigned_4(u32 n);
DLLEXPORT void box_signed_cell(F_FIXNUM integer);
DLLEXPORT void box_unsigned_cell(CELL cell);
DLLEXPORT void box_signed_8(s64 n);
DLLEXPORT s64 to_signed_8(CELL obj);

DLLEXPORT void box_unsigned_8(u64 n);
DLLEXPORT u64 to_unsigned_8(CELL obj);

CELL unbox_array_size(void);

DECLARE_PRIMITIVE(from_fraction);

INLINE double untag_float_fast(CELL tagged)
{
	return ((F_FLOAT*)UNTAG(tagged))->n;
}

INLINE double untag_float(CELL tagged)
{
	type_check(FLOAT_TYPE,tagged);
	return untag_float_fast(tagged);
}

INLINE CELL allot_float(double n)
{
	F_FLOAT* flo = allot_object(FLOAT_TYPE,sizeof(F_FLOAT));
	flo->n = n;
	return RETAG(flo,FLOAT_TYPE);
}

INLINE F_FIXNUM float_to_fixnum(CELL tagged)
{
	return (F_FIXNUM)untag_float_fast(tagged);
}

INLINE F_ARRAY *float_to_bignum(CELL tagged)
{
	return double_to_bignum(untag_float_fast(tagged));
}

INLINE double fixnum_to_float(CELL tagged)
{
	return (double)untag_fixnum_fast(tagged);
}

INLINE double bignum_to_float(CELL tagged)
{
	return bignum_to_double(untag_object(tagged));
}

DLLEXPORT void box_float(float flo);
DLLEXPORT float to_float(CELL value);
DLLEXPORT void box_double(double flo);
DLLEXPORT double to_double(CELL value);

DECLARE_PRIMITIVE(fixnum_to_float);
DECLARE_PRIMITIVE(bignum_to_float);
DECLARE_PRIMITIVE(str_to_float);
DECLARE_PRIMITIVE(float_to_str);
DECLARE_PRIMITIVE(float_to_bits);

DECLARE_PRIMITIVE(float_eq);
DECLARE_PRIMITIVE(float_add);
DECLARE_PRIMITIVE(float_subtract);
DECLARE_PRIMITIVE(float_multiply);
DECLARE_PRIMITIVE(float_divfloat);
DECLARE_PRIMITIVE(float_mod);
DECLARE_PRIMITIVE(float_less);
DECLARE_PRIMITIVE(float_lesseq);
DECLARE_PRIMITIVE(float_greater);
DECLARE_PRIMITIVE(float_greatereq);

DECLARE_PRIMITIVE(float_bits);
DECLARE_PRIMITIVE(bits_float);
DECLARE_PRIMITIVE(double_bits);
DECLARE_PRIMITIVE(bits_double);

DECLARE_PRIMITIVE(from_rect);
