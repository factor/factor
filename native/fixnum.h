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
void primitive_divide(void);
void primitive_not(void);
