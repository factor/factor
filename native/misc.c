#include "factor.h"

void primitive_exit(void)
{
	exit(to_fixnum(env.dt));
}

void primitive_os_env(void)
{
	char* name = to_c_string(untag_string(env.dt));
	char* value = getenv(name);
	if(value == NULL)
		env.dt = F;
	else
		env.dt = tag_object(from_c_string(getenv(name)));
}

void primitive_eq(void)
{
	check_non_empty(env.dt);
	check_non_empty(dpeek());
	env.dt = tag_boolean(dpop() == env.dt);
}

void primitive_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	dpush(env.dt);
	env.dt = tag_object(bignum(t.tv_sec * 1000 + t.tv_usec/1000));
}

void primitive_init_random(void)
{
#ifdef HAVE_SRANDOMDEV
	srandomdev();
#else
	struct timeval t;
	gettimeofday(&t,NULL);
	srandom(t.tv_sec);
#endif
}

void primitive_random_int(void)
{
	dpush(env.dt);
	env.dt = tag_object(bignum(random()));
}
