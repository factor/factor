#include "../factor.h"

void primitive_dlopen(void)
{
#ifdef FFI
	char* path;
	void* dllptr;
	DLL* dll;
	
	maybe_garbage_collection();
	
	path = unbox_c_string();
	dllptr = dlopen(path,RTLD_LAZY);

	if(dllptr == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}

	dll = allot_object(DLL_TYPE,sizeof(DLL));
	dll->dll = dllptr;
	dpush(tag_object(dll));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_dlsym(void)
{
#ifdef FFI
	DLL* dll = untag_dll(dpop());
	void* sym = dlsym(dll->dll,unbox_c_string());
	if(sym == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	dpush(tag_cell((CELL)sym));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_dlsym_self(void)
{
#if defined(FFI)
	void* sym = dlsym(NULL,unbox_c_string());
	if(sym == NULL)
	{
		general_error(ERROR_FFI,tag_object(
			from_c_string(dlerror())));
	}
	dpush(tag_cell((CELL)sym));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_dlclose(void)
{
#ifdef FFI
	DLL* dll = untag_dll(dpop());
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
