CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE F_ARRAY* untag_bignum(CELL tagged)
{
	type_check(BIGNUM_TYPE,tagged);
	return (F_ARRAY*)UNTAG(tagged);
}

F_FIXNUM to_integer(CELL x);
void box_integer(F_FIXNUM integer);
void box_cell(CELL cell);
DLLEXPORT F_FIXNUM unbox_integer(void);
CELL unbox_cell(void);
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
void copy_bignum_constants(void);
CELL three_test(void* x, unsigned char r, unsigned char g, unsigned char b);

INLINE CELL tag_integer(F_FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_object(s48_long_to_bignum(x));
	else
		return tag_fixnum(x);
}

INLINE CELL tag_cell(CELL x)
{
	if(x > FIXNUM_MAX)
		return tag_object(s48_ulong_to_bignum(x));
	else
		return tag_fixnum(x);
}
