CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE F_ARRAY* untag_bignum_fast(CELL tagged)
{
	return (F_ARRAY*)UNTAG(tagged);
}

INLINE CELL tag_bignum(F_ARRAY* bignum)
{
	return RETAG(bignum,BIGNUM_TYPE);
}

CELL to_cell(CELL x);
F_ARRAY* to_bignum(CELL tagged);
void primitive_to_bignum(void);
void primitive_bignum_eq(void);
void primitive_bignum_add(void);
void primitive_bignum_subtract(void);
void primitive_bignum_multiply(void);
void primitive_bignum_divint(void);
void primitive_bignum_divfloat(void);
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

INLINE CELL tag_integer(F_FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_bignum(s48_long_to_bignum(x));
	else
		return tag_fixnum(x);
}

INLINE CELL tag_cell(CELL x)
{
	if(x > FIXNUM_MAX)
		return tag_bignum(s48_ulong_to_bignum(x));
	else
		return tag_fixnum(x);
}

/* FFI calls this */
DLLEXPORT void box_signed_cell(F_FIXNUM integer);
DLLEXPORT F_FIXNUM unbox_signed_cell(void);

DLLEXPORT void box_unsigned_cell(CELL cell);
DLLEXPORT F_FIXNUM unbox_unsigned_cell(void);

DLLEXPORT void box_signed_4(s32 n);
DLLEXPORT s32 unbox_signed_4(void);

DLLEXPORT void box_unsigned_4(u32 n);
DLLEXPORT u32 unbox_unsigned_4(void);

DLLEXPORT void box_signed_8(s64 n);
DLLEXPORT s64 unbox_signed_8(void);

DLLEXPORT void box_unsigned_8(u64 n);
DLLEXPORT u64 unbox_unsigned_8(void);
