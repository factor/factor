#include "../factor.h"

DLL *ffi_dlopen(F_STRING *path)
{
#ifdef FFI
	void* dllptr;
	DLL* dll;
	
	dllptr = dlopen(to_c_string(path), RTLD_LAZY);

	if(dllptr == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}

	dll = allot_object(DLL_TYPE,sizeof(DLL));
	dll->dll = dllptr;
	return dll;
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
