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

#ifdef WIN32
s64 current_millis(void)
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32) - EPOCH_OFFSET) 
		/ 10000;
}
#else
s64 current_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	return (s64)t.tv_sec * 1000 + t.tv_usec/1000;
}
#endif

void primitive_millis(void)
{
	maybe_garbage_collection();
	dpush(tag_bignum(s48_long_long_to_bignum(current_millis())));
}

void primitive_init_random(void)
{
	srand((unsigned)time(NULL));
}

void primitive_random_int(void)
{
	maybe_garbage_collection();
	dpush(tag_bignum(s48_long_to_bignum(rand())));
}

#ifdef WIN32
F_STRING *last_error()
{
	char *buffer;
	F_STRING *error;
	DWORD dw = GetLastError();
	
	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		dw,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &buffer,
		0, NULL);

	error = from_c_string(buffer);
	LocalFree(buffer);

	return error;
}
#endif
