#define FIXNUM_MAX (LONG_MAX >> TAG_BITS)
#define FIXNUM_MIN (LONG_MIN >> TAG_BITS)

#define FIXNUM long int /* unboxed */

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

CELL number_eq_fixnum(FIXNUM x, FIXNUM y);
CELL add_fixnum(FIXNUM x, FIXNUM y);
CELL subtract_fixnum(FIXNUM x, FIXNUM y);
CELL multiply_fixnum(FIXNUM x, FIXNUM y);
FIXNUM gcd_fixnum(FIXNUM x, FIXNUM y);
CELL divide_fixnum(FIXNUM x, FIXNUM y);
CELL divint_fixnum(FIXNUM x, FIXNUM y);
CELL divfloat_fixnum(FIXNUM x, FIXNUM y);
CELL divmod_fixnum(FIXNUM x, FIXNUM y);
CELL mod_fixnum(FIXNUM x, FIXNUM y);
CELL and_fixnum(FIXNUM x, FIXNUM y);
CELL or_fixnum(FIXNUM x, FIXNUM y);
CELL xor_fixnum(FIXNUM x, FIXNUM y);
CELL shift_fixnum(FIXNUM x, FIXNUM y);
CELL less_fixnum(FIXNUM x, FIXNUM y);
CELL lesseq_fixnum(FIXNUM x, FIXNUM y);
CELL greater_fixnum(FIXNUM x, FIXNUM y);
CELL greatereq_fixnum(FIXNUM x, FIXNUM y);
CELL not_fixnum(FIXNUM n);
