#include "factor.h"

DLL* untag_dll(CELL tagged)
{
	DLL* dll = (DLL*)UNTAG(tagged);
	type_check(DLL_TYPE,tagged);
	if(dll->dll == NULL)
		general_error(ERROR_EXPIRED,tagged);
	return (DLL*)UNTAG(tagged);
}

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
#ifdef FFI
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

#ifdef FFI
CELL unbox_alien(void)
{
	return untag_alien(dpop())->ptr;
}

void box_alien(CELL ptr)
{
	ALIEN* alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	alien->ptr = ptr;
	alien->local = false;
	dpush(tag_object(alien));
}

INLINE CELL alien_pointer(void)
{
	FIXNUM offset = unbox_integer();
	ALIEN* alien = untag_alien(dpop());
	CELL ptr = alien->ptr;

	if(ptr == NULL)
		general_error(ERROR_EXPIRED,tag_object(alien));

	return ptr + offset;
}
#endif

void primitive_alien(void)
{
#ifdef FFI
	CELL ptr = unbox_integer();
	maybe_garbage_collection();
	box_alien(ptr);
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_local_alien(void)
{
#ifdef FFI
	CELL length = unbox_integer();
	ALIEN* alien;
	STRING* local;
	maybe_garbage_collection();
	alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	local = string(length / CHARS,'\0');
	alien->ptr = (CELL)local + sizeof(STRING);
	alien->local = true;
	dpush(tag_object(alien));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_alien_cell(void)
{
#ifdef FFI
	box_integer(get(alien_pointer()));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_set_alien_cell(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	CELL value = unbox_integer();
	put(ptr,value);
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_alien_4(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	box_integer(*(int*)ptr);
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_set_alien_4(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	CELL value = unbox_integer();
	*(int*)ptr = value;
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_alien_2(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	box_signed_2(*(uint16_t*)ptr);
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_set_alien_2(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	CELL value = unbox_signed_2();
	*(uint16_t*)ptr = value;
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_alien_1(void)
{
#ifdef FFI
	box_signed_1(bget(alien_pointer()));
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void primitive_set_alien_1(void)
{
#ifdef FFI
	CELL ptr = alien_pointer();
	BYTE value = value = unbox_signed_1();
	bput(ptr,value);
#else
	general_error(ERROR_FFI_DISABLED,F);
#endif
}

void fixup_dll(DLL* dll)
{
	dll->dll = NULL;
}

void fixup_alien(ALIEN* alien)
{
	alien->ptr = NULL;
}

void collect_alien(ALIEN* alien)
{
	if(alien->local && alien->ptr != NULL)
	{
		STRING* ptr = (STRING*)(alien->ptr - sizeof(STRING));
		ptr = copy_untagged_object(ptr,SSIZE(ptr));
		alien->ptr = (CELL)ptr + sizeof(STRING);
	}
}
