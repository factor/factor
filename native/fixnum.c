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

void primitive_add(void)
{
	BINARY_OP(x,y);
	env.dt = x + y;
}

void primitive_subtract(void)
{
	BINARY_OP(x,y);
	env.dt = x - y;
}

void primitive_multiply(void)
{
	BINARY_OP(x,y);
	env.dt = (x >> TAG_BITS) * y;
}

void primitive_divide(void)
{
	BINARY_OP(x,y);
	/* division takes common factor of 8 out. */
	env.dt = tag_fixnum(x / y);
}

void primitive_mod(void)
{
	BINARY_OP(x,y);
	env.dt = x % y;
}

void primitive_divmod(void)
{
	BINARY_OP(x,y);
	dpush(tag_fixnum(x / y));
	/* division takes common factor of 8 out. */
	env.dt = x % y;
}

void primitive_and(void)
{
	BINARY_OP(x,y);
	env.dt = x & y;
}

void primitive_or(void)
{
	BINARY_OP(x,y);
	env.dt = x | y;
}

void primitive_xor(void)
{
	BINARY_OP(x,y);
	env.dt = x ^ y;
}

void primitive_not(void)
{
	type_check(FIXNUM_TYPE,env.dt);
	env.dt = RETAG(~env.dt,FIXNUM_TYPE);
}

void primitive_shiftleft(void)
{
	BINARY_OP(x,y);
	env.dt = UNTAG(x >> (y >> TAG_BITS));
}

void primitive_shiftright(void)
{
	BINARY_OP(x,y);
	env.dt = x << (y >> TAG_BITS);
}

void primitive_less(void)
{
	BINARY_OP(x,y);
	env.dt = tag_boolean(x < y);
}

void primitive_lesseq(void)
{
	BINARY_OP(x,y);
	env.dt = tag_boolean(x <= y);
}

void primitive_greater(void)
{
	BINARY_OP(x,y);
	env.dt = tag_boolean(x > y);
}

void primitive_greatereq(void)
{
	BINARY_OP(x,y);
	env.dt = tag_boolean(x >= y);
}
