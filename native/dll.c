#include "factor.h"

void primitive_dlopen(void)
{
	DLL* dll;
	F_STRING* path;

	maybe_garbage_collection();

	path = untag_string(dpop());
	dll = allot_object(DLL_TYPE,sizeof(DLL));
	dll->path = tag_object(path);
	ffi_dlopen(dll);

	dpush(tag_object(dll));
}

void primitive_dlsym(void)
{
	CELL dll;
	F_STRING* sym;

	maybe_garbage_collection();

	dll = dpop();
	sym = untag_string(dpop());

	dpush(tag_cell((CELL)ffi_dlsym(
		dll == F ? NULL : untag_dll(dll),
		sym)));
}

void primitive_dlclose(void)
{
	maybe_garbage_collection();
	ffi_dlclose(untag_dll(dpop()));
}

DLL* untag_dll(CELL tagged)
{
	DLL* dll = (DLL*)UNTAG(tagged);
	type_check(DLL_TYPE,tagged);
	if(dll->dll == NULL)
		general_error(ERROR_EXPIRED,tagged);
	return (DLL*)UNTAG(tagged);
}

void fixup_dll(DLL* dll)
{
	data_fixup(&dll->path);
	ffi_dlopen(dll);
}

void collect_dll(DLL* dll)
{
	COPY_OBJECT(dll->path);
}
