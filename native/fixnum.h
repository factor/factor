#define FIXNUM int /* unboxed */

INLINE FIXNUM untag_fixnum(CELL tagged)
{
	type_check(FIXNUM_TYPE,tagged);
	return ((FIXNUM)tagged) >> TAG_BITS;
}

INLINE CELL tag_fixnum(FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

void primitive_fixnump(void);
void primitive_add(void);
void primitive_subtract(void);
void primitive_multiply(void);
void primitive_divide(void);
void primitive_mod(void);
void primitive_divmod(void);
void primitive_and(void);
void primitive_or(void);
void primitive_xor(void);
void primitive_not(void);
void primitive_shiftleft(void);
void primitive_shiftright(void);
void primitive_less(void);
void primitive_lesseq(void);
void primitive_greater(void);
void primitive_greatereq(void);
