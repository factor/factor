CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE ARRAY* untag_bignum(CELL tagged)
{
	type_check(BIGNUM_TYPE,tagged);
	return (ARRAY*)UNTAG(tagged);
}

ARRAY* to_bignum(CELL tagged);
void primitive_to_bignum(void);
CELL number_eq_bignum(ARRAY* x, ARRAY* y);
CELL add_bignum(ARRAY* x, ARRAY* y);
CELL subtract_bignum(ARRAY* x, ARRAY* y);
CELL multiply_bignum(ARRAY* x, ARRAY* y);
CELL gcd_bignum(ARRAY* x, ARRAY* y);
CELL divide_bignum(ARRAY* x, ARRAY* y);
CELL divint_bignum(ARRAY* x, ARRAY* y);
CELL divfloat_bignum(ARRAY* x, ARRAY* y);
CELL divmod_bignum(ARRAY* x, ARRAY* y);
CELL mod_bignum(ARRAY* x, ARRAY* y);
CELL and_bignum(ARRAY* x, ARRAY* y);
CELL or_bignum(ARRAY* x, ARRAY* y);
CELL xor_bignum(ARRAY* x, ARRAY* y);
CELL shift_bignum(ARRAY* x, FIXNUM y);
CELL less_bignum(ARRAY* x, ARRAY* y);
CELL lesseq_bignum(ARRAY* x, ARRAY* y);
CELL greater_bignum(ARRAY* x, ARRAY* y);
CELL greatereq_bignum(ARRAY* x, ARRAY* y);
CELL not_bignum(ARRAY* x);
void copy_bignum_constants(void);
