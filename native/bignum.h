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
CELL number_eq_bignum(CELL x, CELL y);
CELL add_bignum(CELL x, CELL y);
CELL subtract_bignum(CELL x, CELL y);
CELL multiply_bignum(CELL x, CELL y);
BIGNUM_2 gcd_bignum(BIGNUM_2 x, BIGNUM_2 y);
CELL divide_bignum(CELL x, CELL y);
CELL divint_bignum(CELL x, CELL y);
CELL divfloat_bignum(CELL x, CELL y);
CELL divmod_bignum(CELL x, CELL y);
CELL mod_bignum(CELL x, CELL y);
CELL and_bignum(CELL x, CELL y);
CELL or_bignum(CELL x, CELL y);
CELL xor_bignum(CELL x, CELL y);
CELL shiftleft_bignum(CELL x, CELL y);
CELL shiftright_bignum(CELL x, CELL y);
CELL less_bignum(CELL x, CELL y);
CELL lesseq_bignum(CELL x, CELL y);
CELL greater_bignum(CELL x, CELL y);
CELL greatereq_bignum(CELL x, CELL y);
CELL not_bignum(CELL x);
