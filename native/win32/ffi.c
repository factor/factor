#include "../factor.h"

void ffi_dlopen (DLL *dll)
{
#ifdef FFI
	HMODULE module;

	module = LoadLibrary(to_c_string(untag_string(dll->path)));

	if (!module)
		general_error(ERROR_FFI, tag_object(last_error()));

	dll->dll = module;
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}

void *ffi_dlsym (DLL *dll, F_STRING *symbol)
{
#ifdef FFI
	void *sym = GetProcAddress(dll ? (HMODULE)dll->dll : GetModuleHandle(NULL),
		to_c_string(symbol));

	if (!sym)
		general_error(ERROR_FFI, tag_object(last_error()));

	return sym;
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}

void ffi_dlclose (DLL *dll)
{
#ifdef FFI
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}