typedef long long BIGNUM_2;

typedef struct {
	CELL header;
	CELL capacity;
	CELL sign;
	CELL fill; /* bad */
	BIGNUM_2 n;
} BIGNUM;

/* untagged */
INLINE BIGNUM* allot_bignum()
{
	/* Bignums are really retrofitted arrays */
	return (BIGNUM*)allot_array(BIGNUM_TYPE,4);
}

/* untagged */
INLINE BIGNUM* bignum(BIGNUM_2 n)
{
	BIGNUM* bignum = allot_bignum();
	bignum->n = n;
	return bignum;
}

INLINE BIGNUM* untag_bignum(CELL tagged)
{
	type_check(BIGNUM_TYPE,tagged);
	return (BIGNUM*)UNTAG(tagged);
}

void primitive_bignump(void);
BIGNUM* to_bignum(CELL tagged);
void primitive_to_bignum(void);
CELL number_eq_bignum(BIGNUM* x, BIGNUM* y);
CELL add_bignum(BIGNUM* x, BIGNUM* y);
CELL subtract_bignum(BIGNUM* x, BIGNUM* y);
CELL multiply_bignum(BIGNUM* x, BIGNUM* y);
BIGNUM_2 gcd_bignum(BIGNUM_2 x, BIGNUM_2 y);
CELL divide_bignum(BIGNUM* x, BIGNUM* y);
CELL divint_bignum(BIGNUM* x, BIGNUM* y);
CELL divfloat_bignum(BIGNUM* x, BIGNUM* y);
CELL divmod_bignum(BIGNUM* x, BIGNUM* y);
CELL mod_bignum(BIGNUM* x, BIGNUM* y);
CELL and_bignum(BIGNUM* x, BIGNUM* y);
CELL or_bignum(BIGNUM* x, BIGNUM* y);
CELL xor_bignum(BIGNUM* x, BIGNUM* y);
CELL shiftleft_bignum(BIGNUM* x, BIGNUM* y);
CELL shiftright_bignum(BIGNUM* x, BIGNUM* y);
CELL less_bignum(BIGNUM* x, BIGNUM* y);
CELL lesseq_bignum(BIGNUM* x, BIGNUM* y);
CELL greater_bignum(BIGNUM* x, BIGNUM* y);
CELL greatereq_bignum(BIGNUM* x, BIGNUM* y);
CELL not_bignum(BIGNUM* x);
