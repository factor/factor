#include "../factor.h"

void init_ffi (void)
{
}

void ffi_dlopen (DLL *dll, bool error)
{
	HMODULE module;
	char *path = to_c_string(untag_string(dll->path));

	module = LoadLibrary(path);

	if (!module)
	{
		if(error)
			general_error(ERROR_FFI, tag_object(last_error()));
		else
			return;
	}

	dll->dll = module;
}

void *ffi_dlsym (DLL *dll, F_STRING *symbol, bool error)
{
	void *sym = GetProcAddress(dll ? (HMODULE)dll->dll : GetModuleHandle(NULL),
		to_c_string(symbol));

	if (!sym)
	{
		if(error)
			general_error(ERROR_FFI, tag_object(last_error()));
		else
			return NULL;
	}

	return sym;
}

void ffi_dlclose (DLL *dll)
{
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
}