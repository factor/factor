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
// frees memory allocated by win32 api calls
char *buffer_to_c_string(char *buffer)
{
	int i;
	int capacity = strlen(buffer);
	F_STRING *_c_str = allot_string(capacity / CHARS + 1);
	BYTE *c_str = (BYTE*)(_c_str + 1);
	for(i = 0; i < capacity; i++)
		c_str[i] = buffer[i];
	c_str[capacity] = '\0';
	LocalFree(buffer);
	return (char*)c_str;
}

char *last_error()
{
	char *buffer;
	int index;
	DWORD dw = GetLastError();
	
	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		dw,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &buffer,
		0, NULL);

	// strip whitespace from end
	index = strlen(buffer) - 1;
	while(index >= 0 && isspace(buffer[index]))
		buffer[index--] = 0;
	
	return buffer_to_c_string(buffer);
}
#endif
