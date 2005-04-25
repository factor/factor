#include "../factor.h"

void ffi_dlopen(DLL* dll)
{
	void* dllptr;
	
	dllptr = dlopen(to_c_string(untag_string(dll->path)), RTLD_LAZY);

	if(dllptr == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}

	dll->dll = dllptr;
}

void *ffi_dlsym(DLL *dll, F_STRING *symbol)
{
	void* sym = dlsym(dll ? dll->dll : NULL, to_c_string(symbol));
	if(sym == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	return sym;
}


void ffi_dlclose(DLL *dll)
{
	if(dlclose(dll->dll) == -1)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	dll->dll = NULL;
}
