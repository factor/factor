#include "factor.h"

void primitive_numberp(void)
{
	check_non_empty(env.dt);

	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		return T;
		break;
	default:
		return F;
		break;
	}
}

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

void primitive_to_fixnum(void)
{
	return tag_fixnum(to_fixnum(env.dt));
}

BIGNUM* to_bignum(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_bignum(tagged);
	case BIGNUM_TYPE:
		return tagged;
	default:
		type_error(BIGNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

void primitive_to_bignum(void)
{
	return tag_bignum(to_bignum(env.dt));
}

/* EQUALITY */
INLINE CELL number_eq_fixnum(CELL x, CELL y)
{
	return tag_boolean(x == y);
}

CELL number_eq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		== ((BIGNUM*)UNTAG(y))->n);
}

CELL number_eq_anytype(CELL x, CELL y)
{
	return F;
}

BINARY_OP(number_eq,true)

/* ADDITION */
INLINE CELL add_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) + untag_fixnum_fast(y));
}

CELL add_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		+ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(add,false)

/* SUBTRACTION */
INLINE CELL subtract_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) - untag_fixnum_fast(y));
}

CELL subtract_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		- ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(subtract,false)

/* MULTIPLICATION */
INLINE CELL multiply_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		* (BIGNUM_2)untag_fixnum_fast(y));
}

CELL multiply_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		* ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(multiply,false)

/* DIVMOD */
INLINE CELL divmod_fixnum(CELL x, CELL y)
{
	ldiv_t q = ldiv(x,y);
	/* division takes common factor of 8 out. */
	dpush(tag_fixnum(q.quot));
	return q.rem;
}

CELL divmod_bignum(CELL x, CELL y)
{
	dpush(tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n)));
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(divmod,false)

/* MOD */
INLINE CELL mod_fixnum(CELL x, CELL y)
{
	return x % y;
}

CELL mod_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(mod,false)

/* AND */
INLINE CELL and_fixnum(CELL x, CELL y)
{
	return x & y;
}

CELL and_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		& ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(and,false)

/* OR */
INLINE CELL or_fixnum(CELL x, CELL y)
{
	return x | y;
}

CELL or_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		| ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(or,false)

/* XOR */
INLINE CELL xor_fixnum(CELL x, CELL y)
{
	return x ^ y;
}

CELL xor_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		^ ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(xor,false)

/* SHIFTLEFT */
INLINE CELL shiftleft_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		<< (BIGNUM_2)untag_fixnum_fast(y));
}

CELL shiftleft_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		<< ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(shiftleft,false)

/* SHIFTRIGHT */
INLINE CELL shiftright_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		>> (BIGNUM_2)untag_fixnum_fast(y));
}

CELL shiftright_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		>> ((BIGNUM*)UNTAG(y))->n));
}

BINARY_OP(shiftright,false)

/* LESS */
INLINE CELL less_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x < (FIXNUM)y);
}

CELL less_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		< ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(less,false)

/* LESSEQ */
INLINE CELL lesseq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x <= (FIXNUM)y);
}

CELL lesseq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		<= ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(lesseq,false)

/* GREATER */
INLINE CELL greater_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x > (FIXNUM)y);
}

CELL greater_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		> ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(greater,false)

/* GREATEREQ */
INLINE CELL greatereq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x >= (FIXNUM)y);
}

CELL greatereq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		>= ((BIGNUM*)UNTAG(y))->n);
}

BINARY_OP(greatereq,false)
