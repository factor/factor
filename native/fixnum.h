INLINE FIXNUM untag_fixnum_fast(CELL tagged)
{
	return ((FIXNUM)tagged) >> TAG_BITS;
}

INLINE CELL tag_fixnum(FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

FIXNUM to_fixnum(CELL tagged);
void primitive_to_fixnum(void);

void primitive_fixnum_eq(void);
void primitive_fixnum_add(void);
void primitive_fixnum_subtract(void);
void primitive_fixnum_multiply(void);
void primitive_fixnum_divint(void);
void primitive_fixnum_divfloat(void);
void primitive_fixnum_divmod(void);
void primitive_fixnum_mod(void);
void primitive_fixnum_and(void);
void primitive_fixnum_or(void);
void primitive_fixnum_xor(void);
void primitive_fixnum_shift(void);
void primitive_fixnum_less(void);
void primitive_fixnum_lesseq(void);
void primitive_fixnum_greater(void);
void primitive_fixnum_greatereq(void);
void primitive_fixnum_not(void);
void box_signed_1(signed char integer);
void box_signed_2(signed short integer);
signed char unbox_signed_1(void);
signed short unbox_signed_2(void);
