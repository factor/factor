#include "factor.h"

RATIO* ratio(CELL numerator, CELL denominator)
{
	RATIO* ratio = (RATIO*)allot(sizeof(RATIO));
	ratio->numerator = numerator;
	ratio->denominator = denominator;
	return ratio;
}

void primitive_ratiop(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(RATIO_TYPE,env.dt));
}

void primitive_numerator(void)
{
	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		/* No op */
		break;
	case RATIO_TYPE:
		env.dt = untag_ratio(env.dt)->numerator;
		break;
	default:
		type_error(RATIO_TYPE,env.dt);
		break;
	}
}

void primitive_denominator(void)
{
	switch(type_of(env.dt))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		env.dt = tag_fixnum(1);
		break;
	case RATIO_TYPE:
		env.dt = untag_ratio(env.dt)->denominator;
		break;
	default:
		type_error(RATIO_TYPE,env.dt);
		break;
	}
}

CELL number_eq_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return tag_boolean(
		untag_boolean(number_eq(rx->numerator,ry->numerator)) &&
		untag_boolean(number_eq(rx->denominator,ry->denominator)));
}

CELL add_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(add(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
}

CELL subtract_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(subtract(multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator)),
		multiply(rx->denominator,ry->denominator));
}

CELL multiply_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->numerator),
		multiply(rx->denominator,ry->denominator));
}

CELL divide_ratio(CELL x, CELL y)
{
	RATIO* rx = (RATIO*)UNTAG(x);
	RATIO* ry = (RATIO*)UNTAG(y);
	return divide(
		multiply(rx->numerator,ry->denominator),
		multiply(rx->denominator,ry->numerator));
}

CELL less_ratio(CELL x, CELL y)
{
	return F;
}

CELL lesseq_ratio(CELL x, CELL y)
{
	return F;
}

CELL greater_ratio(CELL x, CELL y)
{
	return F;
}

CELL greatereq_ratio(CELL x, CELL y)
{
	return F;
}
