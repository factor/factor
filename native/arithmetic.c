#include "factor.h"

void primitive_numberp(void)
{
	check_non_empty(env.dt);

	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case RATIO_TYPE:
		env.dt = T;
		break;
	default:
		env.dt = F;
		break;
	}
}

FIXNUM to_fixnum(CELL tagged)
{
	RATIO* r;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_fixnum(divint(r->numerator,r->denominator));
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

void primitive_to_fixnum(void)
{
	env.dt = tag_fixnum(to_fixnum(env.dt));
}

BIGNUM* to_bignum(CELL tagged)
{
	RATIO* r;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_bignum(tagged);
	case BIGNUM_TYPE:
		return (BIGNUM*)UNTAG(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_bignum(divint(r->numerator,r->denominator));
	default:
		type_error(BIGNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_bignum(void)
{
	env.dt = tag_bignum(to_bignum(env.dt));
}

CELL to_integer(CELL tagged)
{
	RATIO* r;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		return tagged;
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return divint(r->numerator,r->denominator);
	default:
		type_error(FIXNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_integer(void)
{
	env.dt = to_integer(env.dt);
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

CELL number_eq_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return tag_boolean(
		untag_boolean(number_eq(rx->numerator,ry->numerator)) &&
		untag_boolean(number_eq(rx->denominator,ry->denominator)));
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

CELL add_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(add(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
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

CELL subtract_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(subtract(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
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

CELL multiply_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->numerator),
		multiply(rx->denominator,ry->denominator));
}

BINARY_OP(multiply,false)

FIXNUM gcd_fixnum(FIXNUM x, FIXNUM y)
{
	FIXNUM t;

	if(x < 0)
		x = -x;
	if(y < 0)
		y = -y;

	if(x > y)
	{
		t = x;
		x = y;
		y = t;
	}

	for(;;)
	{
		if(x == 0)
			return y;

		t = y % x;
		y = x;
		x = t;
	}
}

BIGNUM_2 gcd_bignum(BIGNUM_2 x, BIGNUM_2 y)
{
	BIGNUM_2 t;

	if(x < 0)
		x = -x;
	if(y < 0)
		y = -y;

	if(x > y)
	{
		t = x;
		x = y;
		y = t;
	}

	for(;;)
	{
		if(x == 0)
			return y;

		t = y % x;
		y = x;
		x = t;
	}
}

/* DIVISION */
INLINE CELL divide_fixnum(CELL x, CELL y)
{
	FIXNUM _x = untag_fixnum_fast(x);
	FIXNUM _y = untag_fixnum_fast(y);

	if(_y == 0)
	{
		/* FIXME */
		abort();
	}
	else if(_y < 0)
	{
		_x = -_x;
		_y = -_y;
	}

	FIXNUM gcd = gcd_fixnum(_x,_y);
	if(gcd != 1)
	{
		_x /= gcd;
		_y /= gcd;
	}

	if(_y == 1)
		return tag_fixnum(_x);
	else
		return tag_ratio(ratio(tag_fixnum(_x),tag_fixnum(_y)));
}

CELL divide_bignum(CELL x, CELL y)
{
	BIGNUM_2 _x = ((BIGNUM*)UNTAG(x))->n;
	BIGNUM_2 _y = ((BIGNUM*)UNTAG(y))->n;

	if(_y == 0)
	{
		/* FIXME */
		abort();
	}
	else if(_y < 0)
	{
		_x = -_x;
		_y = -_y;
	}

	BIGNUM_2 gcd = gcd_bignum(_x,_y);
	if(gcd != 1)
	{
		_x /= gcd;
		_y /= gcd;
	}

	if(_y == 1)
		return tag_object(bignum(_x));
	else
	{
		return tag_ratio(ratio(
			tag_bignum(bignum(_x)),
			tag_bignum(bignum(_y))));
	}
}

CELL divide_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator));
}

BINARY_OP(divide,false)

/* DIVINT */
INLINE CELL divint_fixnum(CELL x, CELL y)
{
	/* division takes common factor of 8 out. */
	return tag_fixnum(x / y);
}

CELL divint_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n));
}

CELL divint_ratio(CELL x, CELL y)
{
	return F;
}

BINARY_OP(divint,false)

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

CELL divmod_ratio(CELL x, CELL y)
{
	return F;
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

CELL mod_ratio(CELL x, CELL y)
{
	return F;
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

CELL and_ratio(CELL x, CELL y)
{
	return F;
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

CELL or_ratio(CELL x, CELL y)
{
	return F;
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

CELL xor_ratio(CELL x, CELL y)
{
	return F;
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

CELL shiftleft_ratio(CELL x, CELL y)
{
	return F;
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

CELL shiftright_ratio(CELL x, CELL y)
{
	return F;
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

CELL less_ratio(CELL x, CELL y)
{
	return F;
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

CELL lesseq_ratio(CELL x, CELL y)
{
	return F;
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

CELL greater_ratio(CELL x, CELL y)
{
	return F;
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

CELL greatereq_ratio(CELL x, CELL y)
{
	return F;
}

BINARY_OP(greatereq,false)
