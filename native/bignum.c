#include "factor.h"

void primitive_bignump(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(BIGNUM_TYPE,env.dt));
}

BIGNUM* to_bignum(CELL tagged)
{
	RATIO* r;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return fixnum_to_bignum(tagged);
	case BIGNUM_TYPE:
		return (BIGNUM*)UNTAG(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_bignum(divint(r->numerator,r->denominator));
	case FLOAT_TYPE:
		f = (FLOAT*)UNTAG(tagged);
		return bignum((BIGNUM_2)f->n);
	default:
		type_error(BIGNUM_TYPE,tagged);
		return NULL; /* can't happen */
	}
}

void primitive_to_bignum(void)
{
	env.dt = tag_object(to_bignum(env.dt));
}

CELL number_eq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		== ((BIGNUM*)UNTAG(y))->n);
}

CELL add_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		+ ((BIGNUM*)UNTAG(y))->n));
}

CELL subtract_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		- ((BIGNUM*)UNTAG(y))->n));
}

CELL multiply_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		* ((BIGNUM*)UNTAG(y))->n));
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

CELL divide_bignum(CELL x, CELL y)
{
	BIGNUM_2 _x = ((BIGNUM*)UNTAG(x))->n;
	BIGNUM_2 _y = ((BIGNUM*)UNTAG(y))->n;
	BIGNUM_2 gcd;

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

	gcd = gcd_bignum(_x,_y);
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
			tag_object(bignum(_x)),
			tag_object(bignum(_y))));
	}
}

CELL divint_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n));
}

CELL divfloat_bignum(CELL x, CELL y)
{
	BIGNUM_2 _x = ((BIGNUM*)UNTAG(x))->n;
	BIGNUM_2 _y = ((BIGNUM*)UNTAG(y))->n;
	return tag_object(make_float((double)_x / (double)_y));
}

CELL divmod_bignum(CELL x, CELL y)
{
	dpush(tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		/ ((BIGNUM*)UNTAG(y))->n)));
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

CELL mod_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		% ((BIGNUM*)UNTAG(y))->n));
}

CELL and_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		& ((BIGNUM*)UNTAG(y))->n));
}

CELL or_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		| ((BIGNUM*)UNTAG(y))->n));
}

CELL xor_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		^ ((BIGNUM*)UNTAG(y))->n));
}

CELL shiftleft_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		<< ((BIGNUM*)UNTAG(y))->n));
}

CELL shiftright_bignum(CELL x, CELL y)
{
	return tag_object(bignum(((BIGNUM*)UNTAG(x))->n
		>> ((BIGNUM*)UNTAG(y))->n));
}

CELL less_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		< ((BIGNUM*)UNTAG(y))->n);
}

CELL lesseq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		<= ((BIGNUM*)UNTAG(y))->n);
}

CELL greater_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		> ((BIGNUM*)UNTAG(y))->n);
}

CELL greatereq_bignum(CELL x, CELL y)
{
	return tag_boolean(((BIGNUM*)UNTAG(x))->n
		>= ((BIGNUM*)UNTAG(y))->n);
}
