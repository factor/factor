#include "master.hpp"

/* gets the address of an object representing a C pointer, with the
intention of storing the pointer across code which may potentially GC. */
char *pinned_alien_offset(CELL object)
{
	switch(tagged<F_OBJECT>(object).type())
	{
	case ALIEN_TYPE:
		F_ALIEN *alien = untag<F_ALIEN>(object);
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

/* make an alien */
CELL allot_alien(CELL delegate_, CELL displacement)
{
	gc_root<F_OBJECT> delegate(delegate_);
	gc_root<F_ALIEN> alien(allot<F_ALIEN>(sizeof(F_ALIEN)));

	if(delegate.type_p(ALIEN_TYPE))
	{
		tagged<F_ALIEN> delegate_alien = delegate.as<F_ALIEN>();
		displacement += delegate_alien->displacement;
		alien->alien = delegate_alien->alien;
	}
	else
		alien->alien = delegate.value();

	alien->displacement = displacement;
	alien->expired = F;

	return alien.value();
}

/* make an alien pointing at an offset of another alien */
PRIMITIVE(displaced_alien)
{
	CELL alien = dpop();
	CELL displacement = to_cell(dpop());

	if(alien == F && displacement == 0)
		dpush(F);
	else
	{
		switch(tagged<F_OBJECT>(alien).type())
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
PRIMITIVE(alien_address)
{
	box_unsigned_cell((CELL)pinned_alien_offset(dpop()));
}

/* pop ( alien n ) from datastack, return alien's address plus n */
static void *alien_pointer(void)
{
	F_FIXNUM offset = to_fixnum(dpop());
	return unbox_alien() + offset;
}

/* define words to read/write values at an alien address */
#define DEFINE_ALIEN_ACCESSOR(name,type,boxer,to) \
	PRIMITIVE(alien_##name) \
	{ \
		boxer(*(type*)alien_pointer()); \
	} \
	PRIMITIVE(set_alien_##name) \
	{ \
		type *ptr = (type *)alien_pointer(); \
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

/* open a native library and push a handle */
PRIMITIVE(dlopen)
{
	gc_root<F_BYTE_ARRAY> path(dpop());
	path.untag_check();
	gc_root<F_DLL> dll(allot<F_DLL>(sizeof(F_DLL)));
	dll->path = path.value();
	ffi_dlopen(dll.untagged());
	dpush(dll.value());
}

/* look up a symbol in a native library */
PRIMITIVE(dlsym)
{
	gc_root<F_OBJECT> dll(dpop());
	gc_root<F_BYTE_ARRAY> name(dpop());
	dll.untag_check();
	name.untag_check();

	F_CHAR *sym = (F_CHAR *)(name.untagged() + 1);

	if(dll.value() == F)
		box_alien(ffi_dlsym(NULL,sym));
	else
	{
		tagged<F_DLL> d = dll.as<F_DLL>();
		if(d->dll == NULL)
			dpush(F);
		else
			box_alien(ffi_dlsym(d.untagged(),sym));
	}
}

/* close a native library handle */
PRIMITIVE(dlclose)
{
	ffi_dlclose(untag_check<F_DLL>(dpop()));
}

PRIMITIVE(dll_validp)
{
	CELL dll = dpop();
	if(dll == F)
		dpush(T);
	else
		dpush(tagged<F_DLL>(dll)->dll == NULL ? F : T);
}

/* gets the address of an object representing a C pointer */
VM_C_API char *alien_offset(CELL object)
{
	switch(tagged<F_OBJECT>(object).type())
	{
	case BYTE_ARRAY_TYPE:
		F_BYTE_ARRAY *byte_array = untag<F_BYTE_ARRAY>(object);
		return (char *)(byte_array + 1);
	case ALIEN_TYPE:
		F_ALIEN *alien = untag<F_ALIEN>(object);
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

/* pop an object representing a C pointer */
VM_C_API char *unbox_alien(void)
{
	return alien_offset(dpop());
}

/* make an alien and push */
VM_C_API void box_alien(void *ptr)
{
	if(ptr == NULL)
		dpush(F);
	else
		dpush(allot_alien(F,(CELL)ptr));
}

/* for FFI calls passing structs by value */
VM_C_API void to_value_struct(CELL src, void *dest, CELL size)
{
	memcpy(dest,alien_offset(src),size);
}

/* for FFI callbacks receiving structs by value */
VM_C_API void box_value_struct(void *src, CELL size)
{
	F_BYTE_ARRAY *array = allot_byte_array(size);
	memcpy(array + 1,src,size);
	dpush(tag<F_BYTE_ARRAY>(array));
}

/* On some x86 OSes, structs <= 8 bytes are returned in registers. */
VM_C_API void box_small_struct(CELL x, CELL y, CELL size)
{
	CELL data[2];
	data[0] = x;
	data[1] = y;
	box_value_struct(data,size);
}

/* On OS X/PPC, complex numbers are returned in registers. */
VM_C_API void box_medium_struct(CELL x1, CELL x2, CELL x3, CELL x4, CELL size)
{
	CELL data[4];
	data[0] = x1;
	data[1] = x2;
	data[2] = x3;
	data[3] = x4;
	box_value_struct(data,size);
}
