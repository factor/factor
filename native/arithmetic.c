#include "factor.h"

FIXNUM to_fixnum(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(tagged);
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

#define CELL_TO_INTEGER(result) \
	FIXNUM _result = (result); \
	if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
		env.dt = tag_bignum(fixnum_to_bignum(_result)); \
	else \
		env.dt = tag_fixnum(_result);

#define BIGNUM_2_TO_INTEGER(result) \
	BIGNUM_2 _result = (result); \
	if(_result < FIXNUM_MIN || _result > FIXNUM_MAX) \
		env.dt = tag_bignum(bignum(_result)); \
	else \
		env.dt = tag_fixnum(_result);

/* ADDITION */
INLINE void add_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) + untag_fixnum_fast(y));
}

void add_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		+ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(add)

/* SUBTRACTION */
INLINE void subtract_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) - untag_fixnum_fast(y));
}

void subtract_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		- ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(subtract)

/* MULTIPLICATION */
INLINE void multiply_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		* (BIGNUM_2)untag_fixnum_fast(y));
}

void multiply_bignum(CELL x, CELL y)
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

void divmod_bignum(CELL x, CELL y)
{
	dpush(tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n)));
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(divmod)

/* MOD */
INLINE void mod_fixnum(CELL x, CELL y)
{
	env.dt = x % y;
}

void mod_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(mod)

/* AND */
INLINE void and_fixnum(CELL x, CELL y)
{
	env.dt = x & y;
}

void and_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		& ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(and)

/* OR */
INLINE void or_fixnum(CELL x, CELL y)
{
	env.dt = x | y;
}

void or_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		| ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(or)

/* XOR */
INLINE void xor_fixnum(CELL x, CELL y)
{
	env.dt = x ^ y;
}

void xor_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		^ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(xor)

/* SHIFTLEFT */
INLINE void shiftleft_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		<< (BIGNUM_2)untag_fixnum_fast(y));
}

void shiftleft_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		<< ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(shiftleft)

/* SHIFTRIGHT */
INLINE void shiftright_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		>> (BIGNUM_2)untag_fixnum_fast(y));
}

void shiftright_bignum(CELL x, CELL y)
{
	env.dt = tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		>> ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(shiftright)

/* LESS */
INLINE void less_fixnum(CELL x, CELL y)
{
	env.dt = tag_boolean((FIXNUM)x < (FIXNUM)y);
}

void less_bignum(CELL x, CELL y)
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

void lesseq_bignum(CELL x, CELL y)
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

void greater_bignum(CELL x, CELL y)
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

void greatereq_bignum(CELL x, CELL y)
{
	env.dt = tag_boolean(((BIGNUM*)UNTAG(x))->n
		>= ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(greatereq)
