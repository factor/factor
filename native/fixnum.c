#include "factor.h"

void primitive_fixnump(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(TAG(env.dt) == FIXNUM_TYPE);
}

void primitive_not(void)
{
	type_check(FIXNUM_TYPE,env.dt);
	env.dt = RETAG(UNTAG(~env.dt),FIXNUM_TYPE);
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

CELL number_eq_fixnum(CELL x, CELL y)
{
	return tag_boolean(x == y);
}

CELL add_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) + untag_fixnum_fast(y));
}

CELL subtract_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) - untag_fixnum_fast(y));
}

CELL multiply_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		* (BIGNUM_2)untag_fixnum_fast(y));
}

CELL divint_fixnum(CELL x, CELL y)
{
	/* division takes common factor of 8 out. */
	return tag_fixnum(x / y);
}

CELL divmod_fixnum(CELL x, CELL y)
{
	ldiv_t q = ldiv(x,y);
	/* division takes common factor of 8 out. */
	dpush(tag_fixnum(q.quot));
	return q.rem;
}

CELL mod_fixnum(CELL x, CELL y)
{
	return x % y;
}

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

CELL divide_fixnum(CELL x, CELL y)
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

CELL and_fixnum(CELL x, CELL y)
{
	return x & y;
}

CELL or_fixnum(CELL x, CELL y)
{
	return x | y;
}

CELL xor_fixnum(CELL x, CELL y)
{
	return x ^ y;
}

CELL shiftleft_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		<< (BIGNUM_2)untag_fixnum_fast(y));
}

CELL shiftright_fixnum(CELL x, CELL y)
{
	BIGNUM_2_TO_INTEGER((BIGNUM_2)untag_fixnum_fast(x)
		>> (BIGNUM_2)untag_fixnum_fast(y));
}

CELL less_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x < (FIXNUM)y);
}

CELL lesseq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x <= (FIXNUM)y);
}

CELL greater_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x > (FIXNUM)y);
}

CELL greatereq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x >= (FIXNUM)y);
}
