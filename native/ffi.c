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

void* unbox_alien(void)
{
	return untag_alien(dpop())->ptr;
}

void box_alien(void* ptr)
{
	ALIEN* alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	alien->ptr = ptr;
	alien->local = false;
	dpush(tag_object(alien));
}

INLINE void* alien_pointer(void)
{
	F_FIXNUM offset = unbox_integer();
	ALIEN* alien = untag_alien(dpop());
	void* ptr = alien->ptr;

	if(ptr == NULL)
		general_error(ERROR_EXPIRED,tag_object(alien));

	return ptr + offset;
}

void primitive_alien(void)
{
	void* ptr = (void*)unbox_integer();
	maybe_garbage_collection();
	box_alien(ptr);
}

void primitive_local_alien(void)
{
	F_FIXNUM length = unbox_integer();
	ALIEN* alien;
	F_STRING* local;
	if(length < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(length));
	maybe_garbage_collection();
	alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	local = string(length / CHARS,'\0');
	alien->ptr = (void*)(local + 1);
	alien->local = true;
	dpush(tag_object(alien));
}

void primitive_local_alienp(void)
{
	box_boolean(untag_alien(dpop())->local);
}

void primitive_alien_address(void)
{
	box_cell((CELL)untag_alien(dpop())->ptr);
}

void primitive_alien_cell(void)
{
	box_integer(*(int*)alien_pointer());
}

void primitive_set_alien_cell(void)
{
	CELL* ptr = alien_pointer();
	CELL value = unbox_integer();
	*ptr = value;
}

void primitive_alien_4(void)
{
	int* ptr = alien_pointer();
	box_integer(*ptr);
}

void primitive_set_alien_4(void)
{
	int* ptr = alien_pointer();
	int value = unbox_integer();
	*ptr = value;
}

void primitive_alien_2(void)
{
	u16* ptr = alien_pointer();
	box_signed_2(*ptr);
}

void primitive_set_alien_2(void)
{
	u16* ptr = alien_pointer();
	CELL value = unbox_signed_2();
	*ptr = value;
}

void primitive_alien_1(void)
{
	box_signed_1(*(BYTE*)alien_pointer());
}

void primitive_set_alien_1(void)
{
	BYTE* ptr = alien_pointer();
	BYTE value = value = unbox_signed_1();
	*ptr = value;
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

void fixup_alien(ALIEN* alien)
{
	alien->ptr = NULL;
}

void collect_alien(ALIEN* alien)
{
	if(alien->local && alien->ptr != NULL)
	{
		F_STRING* ptr = (F_STRING*)(alien->ptr - sizeof(F_STRING));
		ptr = copy_untagged_object(ptr,SSIZE(ptr));
		alien->ptr = (void*)(ptr + 1);
	}
}
