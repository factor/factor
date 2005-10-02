#include "factor.h"

void primitive_exit(void)
{
	exit(to_fixnum(dpop()));
}

void primitive_os_env(void)
{
	char *name, *value;

	maybe_gc(0);

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
	maybe_gc(0);
	dpush(tag_bignum(s48_long_long_to_bignum(current_millis())));
}

void primitive_random_int(void)
{
	maybe_gc(0);
	dpush(tag_bignum(s48_long_to_bignum(rand())));
}

#ifdef WIN32
F_STRING *last_error()
{
	char *buffer;
	int len;
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

	// strip \r\n
	len = strlen(buffer);
	if(len > 2 && isspace(buffer[len - 2]))
		buffer[len - 2] = 0;
	if(len > 1 && isspace(buffer[len - 1]))
		buffer[len - 1] = 0;

	error = from_c_string(buffer);
	LocalFree(buffer);

	return error;
}
#endif
