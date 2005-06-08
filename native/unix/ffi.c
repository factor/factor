#include "../factor.h"

static void *null_dll;

void init_ffi(void)
{
	null_dll = dlopen(NULL,RTLD_LAZY);
}

void ffi_dlopen(DLL *dll)
{
	void *dllptr = dlopen(to_c_string(untag_string(dll->path)), RTLD_LAZY);

	if(dllptr == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}

	dll->dll = dllptr;
}

void *ffi_dlsym(DLL *dll, F_STRING *symbol)
{
	void *handle = (dll == NULL ? null_dll : dll->dll);
	void *sym = dlsym(handle,to_c_string(symbol));
	if(sym == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	return sym;
}


void ffi_dlclose(DLL *dll)
{
	if(dlclose(dll->dll) != NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	dll->dll = NULL;
}
