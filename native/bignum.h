typedef long long BIGNUM_2;

typedef struct {
	CELL header;
	BIGNUM_2 n;
} BIGNUM;

/* untagged */
INLINE BIGNUM* allot_bignum()
{
	return (BIGNUM*)allot_object(BIGNUM_TYPE,sizeof(BIGNUM));
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

INLINE CELL tag_bignum(BIGNUM* untagged)
{
	return RETAG(untagged,OBJECT_TYPE);
}

void primitive_bignump(void);
