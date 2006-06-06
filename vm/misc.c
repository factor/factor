#include "factor.h"

void *safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(ptr == 0)
		fatal_error("malloc() failed", 0);
	return ptr;
}

void primitive_exit(void)
{
	exit(to_fixnum(dpop()));
}

void primitive_os_env(void)
{
	char *name, *value;

	maybe_gc(0);

	name = pop_char_string();
	value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_char_string(getenv(name));
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

#ifdef WIN32
// frees memory allocated by win32 api calls
char *buffer_to_c_string(char *buffer)
{
	int capacity = strlen(buffer);
	F_STRING *_c_str = allot_string(capacity / CHARS + 1);
	u8 *c_str = (u8*)(_c_str + 1);
	strcpy(c_str, buffer);
	LocalFree(buffer);
	return (char*)c_str;
}

F_STRING *get_error_message()
{
	DWORD id = GetLastError();
	return from_c_string(error_message(id));
}

char *error_message(DWORD id)
{
	char *buffer;
	int index;
	
	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		id,
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
