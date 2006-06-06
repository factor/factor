INLINE F_FIXNUM untag_fixnum_fast(CELL tagged)
{
	return ((F_FIXNUM)tagged) >> TAG_BITS;
}

INLINE CELL tag_fixnum(F_FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

F_FIXNUM to_fixnum(CELL tagged);
void primitive_to_fixnum(void);

void primitive_fixnum_add(void);
void primitive_fixnum_subtract(void);
void primitive_fixnum_add_fast(void);
void primitive_fixnum_subtract_fast(void);
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
DLLEXPORT void box_signed_1(signed char integer);
DLLEXPORT void box_signed_2(signed short integer);
DLLEXPORT void box_unsigned_1(unsigned char integer);
DLLEXPORT void box_unsigned_2(unsigned short integer);
DLLEXPORT signed char unbox_signed_1(void);
DLLEXPORT signed short unbox_signed_2(void);
DLLEXPORT unsigned char unbox_unsigned_1(void);
DLLEXPORT unsigned short unbox_unsigned_2(void);
