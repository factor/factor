
#define FIXNUM_MAX (LONG_MAX >> TAG_BITS)
#define FIXNUM_MIN (LONG_MIN >> TAG_BITS)

#define FIXNUM long int /* unboxed */

INLINE FIXNUM untag_fixnum_fast(CELL tagged)
{
	return ((FIXNUM)tagged) >> TAG_BITS;
}

INLINE FIXNUM untag_fixnum(CELL tagged)
{
	type_check(FIXNUM_TYPE,tagged);
	return untag_fixnum_fast(tagged);
}

INLINE CELL tag_fixnum(FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

void primitive_fixnump(void);
void primitive_divide(void);
void primitive_mod(void);
void primitive_and(void);
void primitive_or(void);
void primitive_xor(void);
void primitive_not(void);
void primitive_shiftleft(void);
void primitive_shiftright(void);
