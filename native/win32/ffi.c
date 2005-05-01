#include "../factor.h"

void init_ffi (void)
{
}

void ffi_dlopen (DLL *dll)
{
	HMODULE module;
	char *path = to_c_string(untag_string(dll->path));

	module = LoadLibrary(path);

	if (!module)
		general_error(ERROR_FFI, tag_object(last_error()));

	dll->dll = module;
}

void *ffi_dlsym (DLL *dll, F_STRING *symbol)
{
	void *sym = GetProcAddress(dll ? (HMODULE)dll->dll : GetModuleHandle(NULL),
		to_c_string(symbol));

	if (!sym)
		general_error(ERROR_FFI, tag_object(last_error()));

	return sym;
}

void ffi_dlclose (DLL *dll)
{
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
}