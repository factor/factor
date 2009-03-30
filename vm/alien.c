#include "master.h"

/* gets the address of an object representing a C pointer */
void *alien_offset(CELL object)
{
	F_ALIEN *alien;
	F_BYTE_ARRAY *byte_array;

	switch(type_of(object))
	{
	case BYTE_ARRAY_TYPE:
		byte_array = untag_object(object);
		return byte_array + 1;
	case ALIEN_TYPE:
		alien = untag_object(object);
		if(alien->expired != F)
			general_error(ERROR_EXPIRED,object,F,NULL);
		return alien_offset(alien->alien) + alien->displacement;
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,object);
		return NULL; /* can't happen */
	}
}

/* gets the address of an object representing a C pointer, with the
intention of storing the pointer across code which may potentially GC. */
void *pinned_alien_offset(CELL object)
{
	F_ALIEN *alien;

	switch(type_of(object))
	{
	case ALIEN_TYPE:
		alien = untag_object(object);
		if(alien->expired != F)
			general_error(ERROR_EXPIRED,object,F,NULL);
		return pinned_alien_offset(alien->alien) + alien->displacement;
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,object);
		return NULL; /* can't happen */
	}
}

/* pop an object representing a C pointer */
void *unbox_alien(void)
{
	return alien_offset(dpop());
}

/* make an alien */
CELL allot_alien(CELL delegate, CELL displacement)
{
	REGISTER_ROOT(delegate);
	F_ALIEN *alien = allot_object(ALIEN_TYPE,sizeof(F_ALIEN));
	UNREGISTER_ROOT(delegate);

	if(type_of(delegate) == ALIEN_TYPE)
	{
		F_ALIEN *delegate_alien = untag_object(delegate);
		displacement += delegate_alien->displacement;
		alien->alien = delegate_alien->alien;
	}
	else
		alien->alien = delegate;

	alien->displacement = displacement;
	alien->expired = F;
	return tag_object(alien);
}

/* make an alien and push */
void box_alien(void *ptr)
{
	if(ptr == NULL)
		dpush(F);
	else
		dpush(allot_alien(F,(CELL)ptr));
}

/* make an alien pointing at an offset of another alien */
void primitive_displaced_alien(void)
{
	CELL alien = dpop();
	CELL displacement = to_cell(dpop());

	if(alien == F && displacement == 0)
		dpush(F);
	else
	{
		switch(type_of(alien))
		{
		case BYTE_ARRAY_TYPE:
		case ALIEN_TYPE:
		case F_TYPE:
			dpush(allot_alien(alien,displacement));
			break;
		default:
			type_error(ALIEN_TYPE,alien);
			break;
		}
	}
}

/* address of an object representing a C pointer. Explicitly throw an error
if the object is a byte array, as a sanity check. */
void primitive_alien_address(void)
{
	box_unsigned_cell((CELL)pinned_alien_offset(dpop()));
}

/* pop ( alien n ) from datastack, return alien's address plus n */
INLINE void *alien_pointer(void)
{
	F_FIXNUM offset = to_fixnum(dpop());
	return unbox_alien() + offset;
}

/* define words to read/write values at an alien address */
#define DEFINE_ALIEN_ACCESSOR(name,type,boxer,to) \
	void primitive_alien_##name(void) \
	{ \
		boxer(*(type*)alien_pointer()); \
	} \
	void primitive_set_alien_##name(void) \
	{ \
		type* ptr = alien_pointer(); \
		type value = to(dpop()); \
		*ptr = value; \
	}

DEFINE_ALIEN_ACCESSOR(signed_cell,F_FIXNUM,box_signed_cell,to_fixnum)
DEFINE_ALIEN_ACCESSOR(unsigned_cell,CELL,box_unsigned_cell,to_cell)
DEFINE_ALIEN_ACCESSOR(signed_8,s64,box_signed_8,to_signed_8)
DEFINE_ALIEN_ACCESSOR(unsigned_8,u64,box_unsigned_8,to_unsigned_8)
DEFINE_ALIEN_ACCESSOR(signed_4,s32,box_signed_4,to_fixnum)
DEFINE_ALIEN_ACCESSOR(unsigned_4,u32,box_unsigned_4,to_cell)
DEFINE_ALIEN_ACCESSOR(signed_2,s16,box_signed_2,to_fixnum)
DEFINE_ALIEN_ACCESSOR(unsigned_2,u16,box_unsigned_2,to_cell)
DEFINE_ALIEN_ACCESSOR(signed_1,s8,box_signed_1,to_fixnum)
DEFINE_ALIEN_ACCESSOR(unsigned_1,u8,box_unsigned_1,to_cell)
DEFINE_ALIEN_ACCESSOR(float,float,box_float,to_float)
DEFINE_ALIEN_ACCESSOR(double,double,box_double,to_double)
DEFINE_ALIEN_ACCESSOR(cell,void *,box_alien,pinned_alien_offset)

/* for FFI calls passing structs by value */
void to_value_struct(CELL src, void *dest, CELL size)
{
	memcpy(dest,alien_offset(src),size);
}

/* for FFI callbacks receiving structs by value */
void box_value_struct(void *src, CELL size)
{
	F_BYTE_ARRAY *array = allot_byte_array(size);
	memcpy(array + 1,src,size);
	dpush(tag_object(array));
}

/* On some x86 OSes, structs <= 8 bytes are returned in registers. */
void box_small_struct(CELL x, CELL y, CELL size)
{
	CELL data[2];
	data[0] = x;
	data[1] = y;
	box_value_struct(data,size);
}

/* On OS X/PPC, complex numbers are returned in registers. */
void box_medium_struct(CELL x1, CELL x2, CELL x3, CELL x4, CELL size)
{
	CELL data[4];
	data[0] = x1;
	data[1] = x2;
	data[2] = x3;
	data[3] = x4;
	box_value_struct(data,size);
}

/* open a native library and push a handle */
void primitive_dlopen(void)
{
	CELL path = tag_object(string_to_native_alien(
		untag_string(dpop())));
	REGISTER_ROOT(path);
	F_DLL* dll = allot_object(DLL_TYPE,sizeof(F_DLL));
	UNREGISTER_ROOT(path);
	dll->path = path;
	ffi_dlopen(dll);
	dpush(tag_object(dll));
}

/* look up a symbol in a native library */
void primitive_dlsym(void)
{
	CELL dll = dpop();
	REGISTER_ROOT(dll);
	F_SYMBOL *sym = unbox_symbol_string();
	UNREGISTER_ROOT(dll);

	F_DLL *d;

	if(dll == F)
		box_alien(ffi_dlsym(NULL,sym));
	else
	{
		d = untag_dll(dll);
		if(d->dll == NULL)
			dpush(F);
		else
			box_alien(ffi_dlsym(d,sym));
	}
}

/* close a native library handle */
void primitive_dlclose(void)
{
	ffi_dlclose(untag_dll(dpop()));
}

void primitive_dll_validp(void)
{
	CELL dll = dpop();
	if(dll == F)
		dpush(T);
	else
	{
		F_DLL *d = untag_dll(dll);
		dpush(d->dll == NULL ? F : T);
	}
}
