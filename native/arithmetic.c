#include "factor.h"

/* ADDITION */
INLINE void add_fixnum(CELL x, CELL y)
{
	FIXNUM result = untag_fixnum_fast(x) + untag_fixnum_fast(y);
	if(result < FIXNUM_MIN || result > FIXNUM_MAX)
		env.dt = tag_bignum(fixnum_to_bignum(result));
	else
		env.dt = tag_fixnum(result);
}

INLINE void add_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		+ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(add)

/* SUBTRACTION */
INLINE void subtract_fixnum(CELL x, CELL y)
{
	FIXNUM result = untag_fixnum_fast(x) - untag_fixnum_fast(y);
	if(result < FIXNUM_MIN || result > FIXNUM_MAX)
		env.dt = tag_bignum(fixnum_to_bignum(result));
	else
		env.dt = tag_fixnum(result);
}

INLINE void subtract_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		- ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(subtract)

/* MULTIPLICATION */
INLINE void multiply_fixnum(CELL x, CELL y)
{
	BIGNUM_2 result = (BIGNUM_2)untag_fixnum_fast(x)
		* (BIGNUM_2)untag_fixnum_fast(y);
	if(result < FIXNUM_MIN || result > FIXNUM_MAX)
		env.dt = tag_bignum(bignum(result));
	else
		env.dt = tag_fixnum(result);
}

INLINE void multiply_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		* ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(multiply)

/* DIVMOD */
INLINE void divmod_fixnum(CELL x, CELL y)
{
	ldiv_t q = ldiv(x,y);
	/* division takes common factor of 8 out. */
	dpush(tag_fixnum(q.quot));
	env.dt = q.rem;
}

INLINE void divmod_bignum(CELL x, CELL y)
{
	dpush(tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n)));
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(divmod)

/* LESS */
INLINE void less_fixnum(CELL x, CELL y)
{
	env.dt = tag_boolean((FIXNUM)x < (FIXNUM)y);
}

INLINE void less_bignum(CELL x, CELL y)
{
	env.dt = tag_boolean(((BIGNUM*)UNTAG(x))->n
		< ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(less)

/* LESSEQ */
INLINE void lesseq_fixnum(CELL x, CELL y)
{
	env.dt = tag_boolean((FIXNUM)x <= (FIXNUM)y);
}

INLINE void lesseq_bignum(CELL x, CELL y)
{
	env.dt = tag_boolean(((BIGNUM*)UNTAG(x))->n
		<= ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(lesseq)

/* GREATER */
INLINE void greater_fixnum(CELL x, CELL y)
{
	env.dt = tag_boolean((FIXNUM)x > (FIXNUM)y);
}

INLINE void greater_bignum(CELL x, CELL y)
{
	env.dt = tag_boolean(((BIGNUM*)UNTAG(x))->n
		> ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(greater)

/* GREATEREQ */
INLINE void greatereq_fixnum(CELL x, CELL y)
{
	env.dt = tag_boolean((FIXNUM)x >= (FIXNUM)y);
}

INLINE void greatereq_bignum(CELL x, CELL y)
{
	env.dt = tag_boolean(((BIGNUM*)UNTAG(x))->n
		>= ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(greatereq)
