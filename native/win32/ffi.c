#include "../factor.h"

void primitive_dlopen (void)
{
#ifdef FFI
	char *path;
	HMODULE module;
	DLL *dll;

	maybe_garbage_collection();

	path = unbox_c_string();
	module = LoadLibrary(path);

	if (!module)
		general_error(ERROR_FFI, tag_object(last_error()));

	dll = allot_object(DLL_TYPE, sizeof(DLL));
	dll->dll = module;
	dpush(tag_object(dll));
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}

void primitive_dlsym (void)
{
#ifdef FFI
	DLL *dll = untag_dll(dpop());
	void *sym = GetProcAddress((HMODULE)dll->dll, unbox_c_string());


	if (!sym)
		general_error(ERROR_FFI, tag_object(last_error()));

	dpush(tag_cell((CELL)sym));
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}

void primitive_dlclose (void)
{
#ifdef FFI
	DLL *dll = untag_dll(dpop());
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}

void primitive_dlsym_self (void)
{
#ifdef FFI
	void *sym = GetProcAddress(GetModuleHandle(NULL), unbox_c_string());

	if(sym == NULL)
	{
		general_error(ERROR_FFI, tag_object(last_error()));
	}
	dpush(tag_cell((CELL)sym));
#else
	general_error(ERROR_FFI_DISABLED, F);
#endif
}
