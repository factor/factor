#define CELL_MAX (CELL)(-1)
#define FIXNUM_MAX (((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)))
#define ARRAY_SIZE_MAX ((CELL)1 << (WORD_SIZE - TAG_BITS - 2))

DLLEXPORT F_FIXNUM to_fixnum(CELL tagged);
DLLEXPORT CELL to_cell(CELL tagged);

void primitive_bignum_to_fixnum(void);
void primitive_float_to_fixnum(void);

void primitive_fixnum_add(void);
void primitive_fixnum_subtract(void);
void primitive_fixnum_multiply(void);

DLLEXPORT F_FASTCALL void overflow_fixnum_add(F_FIXNUM x, F_FIXNUM y);
DLLEXPORT F_FASTCALL void overflow_fixnum_subtract(F_FIXNUM x, F_FIXNUM y);
DLLEXPORT F_FASTCALL void overflow_fixnum_multiply(F_FIXNUM x, F_FIXNUM y);

void primitive_fixnum_divint(void);
void primitive_fixnum_divmod(void);
void primitive_fixnum_shift(void);

CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE CELL tag_bignum(F_ARRAY* bignum)
{
	return RETAG(bignum,BIGNUM_TYPE);
}

void primitive_fixnum_to_bignum(void);
void primitive_float_to_bignum(void);
void primitive_bignum_eq(void);
void primitive_bignum_add(void);
void primitive_bignum_subtract(void);
void primitive_bignum_multiply(void);
void primitive_bignum_divint(void);
void primitive_bignum_divmod(void);
void primitive_bignum_mod(void);
void primitive_bignum_and(void);
void primitive_bignum_or(void);
void primitive_bignum_xor(void);
void primitive_bignum_shift(void);
void primitive_bignum_less(void);
void primitive_bignum_lesseq(void);
void primitive_bignum_greater(void);
void primitive_bignum_greatereq(void);
void primitive_bignum_not(void);
void primitive_bignum_bitp(void);
void primitive_bignum_log2(void);
void primitive_byte_array_to_bignum(void);

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

void primitive_fixnum_to_float(void);
void primitive_bignum_to_float(void);
void primitive_str_to_float(void);
void primitive_float_to_str(void);
void primitive_float_to_bits(void);

void primitive_float_eq(void);
void primitive_float_add(void);
void primitive_float_subtract(void);
void primitive_float_multiply(void);
void primitive_float_divfloat(void);
void primitive_float_mod(void);
void primitive_float_less(void);
void primitive_float_lesseq(void);
void primitive_float_greater(void);
void primitive_float_greatereq(void);

void primitive_float_bits(void);
void primitive_bits_float(void);
void primitive_double_bits(void);
void primitive_bits_double(void);
