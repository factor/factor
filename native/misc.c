#include "factor.h"

void primitive_exit(void)
{
	exit(to_fixnum(dpop()));
}

void primitive_os_env(void)
{
	char *name, *value;

	maybe_garbage_collection();

	name = unbox_c_string();
	value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_c_string(getenv(name));
}

void primitive_eq(void)
{
	box_boolean(dpop() == dpop());
}

long long current_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	return (long long)t.tv_sec * 1000 + t.tv_usec/1000;
}

void primitive_millis(void)
{
	maybe_garbage_collection();
	dpush(tag_object(s48_long_long_to_bignum(current_millis())));
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
	maybe_garbage_collection();
	dpush(tag_object(s48_long_to_bignum(random())));
}
