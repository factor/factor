#include "../factor.h"

DLL *ffi_dlopen (F_STRING *path)
{
#ifdef FFI
	HMODULE module;
	DLL *dll;

	module = LoadLibrary(to_c_string(path));

	if (!module)
		general_error(ERROR_FFI, tag_object(last_error()));

	dll = allot_object(DLL_TYPE, sizeof(DLL));
	dll->dll = module;

	return dll;
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