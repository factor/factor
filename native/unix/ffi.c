#include "../factor.h"

static void *null_dll;

void init_ffi(void)
{
	null_dll = dlopen(NULL,RTLD_LAZY);
}

void ffi_dlopen(DLL *dll, bool error)
{
	void *dllptr = dlopen(to_c_string(untag_string(dll->path),true), RTLD_LAZY);

	if(dllptr == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,tag_object(
				from_c_string(dlerror())),true);
		}
		else
			dll->dll = NULL;

		return;
	}

	dll->dll = dllptr;
}

void *ffi_dlsym(DLL *dll, F_STRING *symbol, bool error)
{
	void *handle = (dll == NULL ? null_dll : dll->dll);
	void *sym = dlsym(handle,to_c_string(symbol,true));
	if(sym == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,tag_object(
				from_c_string(dlerror())),true);
		}

		return NULL;
	}
	return sym;
}

void ffi_dlclose(DLL *dll)
{
	if(dlclose(dll->dll))
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())),true);
	}
	dll->dll = NULL;
}
