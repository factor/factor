#include "factor.h"

#define BINARY_OP(x,y) \
	FIXNUM x, y; \
	y = env.dt; \
	type_check(FIXNUM_TYPE,y); \
	x = dpop(); \
	type_check(FIXNUM_TYPE,x);

void primitive_fixnump(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(TAG(env.dt) == FIXNUM_TYPE);
}

void primitive_divide(void)
{
	BINARY_OP(x,y);
	/* division takes common factor of 8 out. */
	env.dt = tag_fixnum(x / y);
}

void primitive_not(void)
{
	type_check(FIXNUM_TYPE,env.dt);
	env.dt = RETAG(UNTAG(~env.dt),FIXNUM_TYPE);
}
