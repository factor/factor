#include "factor.h"

void primitive_dlopen(void)
{
	DLL* dll;
	F_STRING* path;

	maybe_gc(sizeof(DLL));

	path = untag_string(dpop());
	dll = allot_object(DLL_TYPE,sizeof(DLL));
	dll->path = tag_object(path);
	ffi_dlopen(dll,true);

	dpush(tag_object(dll));
}

void primitive_dlsym(void)
{
	CELL dll;
	F_STRING *sym;
	DLL *d;

	maybe_gc(0);

	dll = dpop();
	sym = untag_string(dpop());
	
	if(dll == F)
		d = NULL;
	else
	{
		d = untag_dll(dll);
		if(d->dll == NULL)
			general_error(ERROR_EXPIRED,dll);
	}

	dpush(tag_cell((CELL)ffi_dlsym(d,sym,true)));
}

void primitive_dlclose(void)
{
	ffi_dlclose(untag_dll(dpop()));
}

void fixup_dll(DLL* dll)
{
	data_fixup(&dll->path);
	ffi_dlopen(dll,false);
}

void collect_dll(DLL* dll)
{
	copy_handle(&dll->path);
}
