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
