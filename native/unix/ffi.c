#include "../factor.h"

void ffi_dlopen(DLL* dll)
{
#ifdef FFI
	void* dllptr;
	
	dllptr = dlopen(to_c_string(untag_string(dll->path)), RTLD_LAZY);

	if(dllptr == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}

	dll->dll = dllptr;
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void *ffi_dlsym(DLL *dll, F_STRING *symbol)
{
#ifdef FFI
	void* sym = dlsym(dll ? dll->dll : NULL, to_c_string(symbol));
	if(sym == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	return sym;
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}


void ffi_dlclose(DLL *dll)
{
#ifdef FFI
	if(dlclose(dll->dll) == -1)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	dll->dll = NULL;
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}
