#include "factor.h"

void primitive_bignump(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(BIGNUM_TYPE,env.dt));
}
