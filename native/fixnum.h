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

void primitive_fixnump(void);
void primitive_not(void);

FIXNUM to_fixnum(CELL tagged);
void primitive_to_fixnum(void);

CELL number_eq_fixnum(CELL x, CELL y);
CELL add_fixnum(CELL x, CELL y);
CELL subtract_fixnum(CELL x, CELL y);
CELL multiply_fixnum(CELL x, CELL y);
FIXNUM gcd_fixnum(FIXNUM x, FIXNUM y);
CELL divide_fixnum(CELL x, CELL y);
CELL divint_fixnum(CELL x, CELL y);
CELL divfloat_fixnum(CELL x, CELL y);
CELL divmod_fixnum(CELL x, CELL y);
CELL mod_fixnum(CELL x, CELL y);
CELL and_fixnum(CELL x, CELL y);
CELL or_fixnum(CELL x, CELL y);
CELL xor_fixnum(CELL x, CELL y);
CELL shift_fixnum(CELL x, FIXNUM y);
CELL less_fixnum(CELL x, CELL y);
CELL lesseq_fixnum(CELL x, CELL y);
CELL greater_fixnum(CELL x, CELL y);
CELL greatereq_fixnum(CELL x, CELL y);
CELL not_fixnum(CELL n);
