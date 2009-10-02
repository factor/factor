#include "master.hpp"

namespace factor
{

/* gets the address of an object representing a C pointer, with the
intention of storing the pointer across code which may potentially GC. */
char *factor_vm::pinned_alien_offset(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case ALIEN_TYPE:
		{
			alien *ptr = untag<alien>(obj);
			if(ptr->expired != F)
				general_error(ERROR_EXPIRED,obj,F,NULL);
			return pinned_alien_offset(ptr->alien) + ptr->displacement;
		}
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,obj);
		return NULL; /* can't happen */
	}
}

/* make an alien */
cell factor_vm::allot_alien(cell delegate_, cell displacement)
{
	gc_root<object> delegate(delegate_,this);
	gc_root<alien> new_alien(allot<alien>(sizeof(alien)),this);

	if(delegate.type_p(ALIEN_TYPE))
	{
		tagged<alien> delegate_alien = delegate.as<alien>();
		displacement += delegate_alien->displacement;
		new_alien->alien = delegate_alien->alien;
	}
	else
		new_alien->alien = delegate.value();

	new_alien->displacement = displacement;
	new_alien->expired = F;

	return new_alien.value();
}

/* make an alien pointing at an offset of another alien */
void factor_vm::primitive_displaced_alien()
{
	cell alien = dpop();
	cell displacement = to_cell(dpop());

	if(alien == F && displacement == 0)
		dpush(F);
	else
	{
		switch(tagged<object>(alien).type())
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
void factor_vm::primitive_alien_address()
{
	box_unsigned_cell((cell)pinned_alien_offset(dpop()));
}

/* pop ( alien n ) from datastack, return alien's address plus n */
void *factor_vm::alien_pointer()
{
	fixnum offset = to_fixnum(dpop());
	return unbox_alien() + offset;
}

/* define words to read/write values at an alien address */
#define DEFINE_ALIEN_ACCESSOR(name,type,boxer,to) \
	PRIMITIVE(alien_##name) \
	{ \
		PRIMITIVE_GETVM()->boxer(*(type*)PRIMITIVE_GETVM()->alien_pointer());	\
	} \
	PRIMITIVE(set_alien_##name) \
	{ \
		type *ptr = (type *)PRIMITIVE_GETVM()->alien_pointer(); \
		type value = PRIMITIVE_GETVM()->to(dpop()); \
		*ptr = value; \
	}

DEFINE_ALIEN_ACCESSOR(signed_cell,fixnum,box_signed_cell,to_fixnum)
DEFINE_ALIEN_ACCESSOR(unsigned_cell,cell,box_unsigned_cell,to_cell)
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
void factor_vm::primitive_dlopen()
{
	gc_root<byte_array> path(dpop(),this);
	path.untag_check(this);
	gc_root<dll> library(allot<dll>(sizeof(dll)),this);
	library->path = path.value();
	ffi_dlopen(library.untagged());
	dpush(library.value());
}

/* look up a symbol in a native library */
void factor_vm::primitive_dlsym()
{
	gc_root<object> library(dpop(),this);
	gc_root<byte_array> name(dpop(),this);
	name.untag_check(this);

	symbol_char *sym = name->data<symbol_char>();

	if(library.value() == F)
		box_alien(ffi_dlsym(NULL,sym));
	else
	{
		dll *d = untag_check<dll>(library.value());

		if(d->dll == NULL)
			dpush(F);
		else
			box_alien(ffi_dlsym(d,sym));
	}
}

/* close a native library handle */
void factor_vm::primitive_dlclose()
{
	dll *d = untag_check<dll>(dpop());
	if(d->dll != NULL)
		ffi_dlclose(d);
}

void factor_vm::primitive_dll_validp()
{
	cell library = dpop();
	if(library == F)
		dpush(T);
	else
		dpush(untag_check<dll>(library)->dll == NULL ? F : T);
}

/* gets the address of an object representing a C pointer */
char *factor_vm::alien_offset(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case BYTE_ARRAY_TYPE:
		return untag<byte_array>(obj)->data<char>();
	case ALIEN_TYPE:
		{
			alien *ptr = untag<alien>(obj);
			if(ptr->expired != F)
				general_error(ERROR_EXPIRED,obj,F,NULL);
			return alien_offset(ptr->alien) + ptr->displacement;
		}
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,obj);
		return NULL; /* can't happen */
	}
}

VM_C_API char *alien_offset(cell obj, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->alien_offset(obj);
}

/* pop an object representing a C pointer */
char *factor_vm::unbox_alien()
{
	return alien_offset(dpop());
}

VM_C_API char *unbox_alien(factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->unbox_alien();
}

/* make an alien and push */
void factor_vm::box_alien(void *ptr)
{
	if(ptr == NULL)
		dpush(F);
	else
		dpush(allot_alien(F,(cell)ptr));
}

VM_C_API void box_alien(void *ptr, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_alien(ptr);
}

/* for FFI calls passing structs by value */
void factor_vm::to_value_struct(cell src, void *dest, cell size)
{
	memcpy(dest,alien_offset(src),size);
}

VM_C_API void to_value_struct(cell src, void *dest, cell size, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_value_struct(src,dest,size);
}

/* for FFI callbacks receiving structs by value */
void factor_vm::box_value_struct(void *src, cell size)
{
	byte_array *bytes = allot_byte_array(size);
	memcpy(bytes->data<void>(),src,size);
	dpush(tag<byte_array>(bytes));
}

VM_C_API void box_value_struct(void *src, cell size,factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_value_struct(src,size);
}

/* On some x86 OSes, structs <= 8 bytes are returned in registers. */
void factor_vm::box_small_struct(cell x, cell y, cell size)
{
	cell data[2];
	data[0] = x;
	data[1] = y;
	box_value_struct(data,size);
}

VM_C_API void box_small_struct(cell x, cell y, cell size, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_small_struct(x,y,size);
}

/* On OS X/PPC, complex numbers are returned in registers. */
void factor_vm::box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size)
{
	cell data[4];
	data[0] = x1;
	data[1] = x2;
	data[2] = x3;
	data[3] = x4;
	box_value_struct(data,size);
}

VM_C_API void box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_medium_struct(x1, x2, x3, x4, size);
}

void factor_vm::primitive_vm_ptr()
{
	box_alien(this);
}

}
