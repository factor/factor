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
