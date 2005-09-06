#include "../factor.h"

static void *null_dll;

void ffi_test_1(int x, int y, int z)
{
	fprintf(stderr,"%d %d %d\n",x,y,z);
}

void ffi_test_2(int x, float y, int z)
{
	fprintf(stderr,"%d %f %d\n",x,y,z);
}

int ffi_test_3(int x, int y, int z)
{
	return x + y * z;
}

float ffi_test_4(int x, float y, int z)
{
	return x + y * z;
}

void init_ffi(void)
{
	null_dll = dlopen(NULL,RTLD_LAZY);
}

void ffi_dlopen(DLL *dll, bool error)
{
	void *dllptr = dlopen(to_c_string(untag_string(dll->path)), RTLD_LAZY);

	if(dllptr == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,tag_object(
				from_c_string(dlerror())));
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
	void *sym = dlsym(handle,to_c_string(symbol));
	if(sym == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,tag_object(
				from_c_string(dlerror())));
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
			from_c_string(dlerror())));
	}
	dll->dll = NULL;
}
