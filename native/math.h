#include "factor.h"

INLINE BIGNUM* fixnum_to_bignum(CELL n)
{
	return bignum((DCELL)untag_fixnum_fast(n));
}

INLINE FIXNUM bignum_to_fixnum(CELL tagged)
{
	return (FIXNUM)(untag_bignum(tagged)->n);
}
