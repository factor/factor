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
			if(to_boolean(ptr->expired))
				general_error(ERROR_EXPIRED,obj,false_object,NULL);
			if(to_boolean(ptr->base))
				type_error(ALIEN_TYPE,obj);
			else
				return (char *)ptr->address;
		}
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,obj);
		return NULL; /* can't happen */
	}
}

VM_C_API char *pinned_alien_offset(cell obj, factor_vm *parent)
{
	return parent->pinned_alien_offset(obj);
}

/* make an alien */
cell factor_vm::allot_alien(cell delegate_, cell displacement)
{
	if(delegate_ == false_object && displacement == 0)
		return false_object;

	data_root<object> delegate(delegate_,this);
	data_root<alien> new_alien(allot<alien>(sizeof(alien)),this);

	if(delegate.type_p(ALIEN_TYPE))
	{
		tagged<alien> delegate_alien = delegate.as<alien>();
		displacement += delegate_alien->displacement;
		new_alien->base = delegate_alien->base;
	}
	else
		new_alien->base = delegate.value();

	new_alien->displacement = displacement;
	new_alien->expired = false_object;
	new_alien->update_address();

	return new_alien.value();
}

cell factor_vm::allot_alien(void *address)
{
	return allot_alien(false_object,(cell)address);
}

VM_C_API cell allot_alien(void *address, factor_vm *vm)
{
	return vm->allot_alien(address);
}

/* make an alien pointing at an offset of another alien */
void factor_vm::primitive_displaced_alien()
{
	cell alien = ctx->pop();
	cell displacement = to_cell(ctx->pop());

	switch(tagged<object>(alien).type())
	{
	case BYTE_ARRAY_TYPE:
	case ALIEN_TYPE:
	case F_TYPE:
		ctx->push(allot_alien(alien,displacement));
		break;
	default:
		type_error(ALIEN_TYPE,alien);
		break;
	}
}

/* address of an object representing a C pointer. Explicitly throw an error
if the object is a byte array, as a sanity check. */
void factor_vm::primitive_alien_address()
{
	ctx->push(allot_cell((cell)pinned_alien_offset(ctx->pop())));
}

/* pop ( alien n ) from datastack, return alien's address plus n */
void *factor_vm::alien_pointer()
{
	fixnum offset = to_fixnum(ctx->pop());
	return alien_offset(ctx->pop()) + offset;
}

/* define words to read/write values at an alien address */
#define DEFINE_ALIEN_ACCESSOR(name,type,from,to) \
	VM_C_API void primitive_alien_##name(factor_vm *parent) \
	{ \
		parent->ctx->push(from(*(type*)(parent->alien_pointer()),parent)); \
	} \
	VM_C_API void primitive_set_alien_##name(factor_vm *parent) \
	{ \
		type *ptr = (type *)parent->alien_pointer(); \
		type value = (type)to(parent->ctx->pop(),parent); \
		*ptr = value; \
	}

EACH_ALIEN_PRIMITIVE(DEFINE_ALIEN_ACCESSOR)

/* open a native library and push a handle */
void factor_vm::primitive_dlopen()
{
	data_root<byte_array> path(ctx->pop(),this);
	path.untag_check(this);
	data_root<dll> library(allot<dll>(sizeof(dll)),this);
	library->path = path.value();
	ffi_dlopen(library.untagged());
	ctx->push(library.value());
}

/* look up a symbol in a native library */
void factor_vm::primitive_dlsym()
{
	data_root<object> library(ctx->pop(),this);
	data_root<byte_array> name(ctx->pop(),this);
	name.untag_check(this);

	symbol_char *sym = name->data<symbol_char>();

	if(to_boolean(library.value()))
	{
		dll *d = untag_check<dll>(library.value());

		if(d->handle == NULL)
			ctx->push(false_object);
		else
			ctx->push(allot_alien(ffi_dlsym(d,sym)));
	}
	else
		ctx->push(allot_alien(ffi_dlsym(NULL,sym)));
}

/* close a native library handle */
void factor_vm::primitive_dlclose()
{
	dll *d = untag_check<dll>(ctx->pop());
	if(d->handle != NULL)
		ffi_dlclose(d);
}

void factor_vm::primitive_dll_validp()
{
	cell library = ctx->pop();
	if(to_boolean(library))
		ctx->push(tag_boolean(untag_check<dll>(library)->handle != NULL));
	else
		ctx->push(true_object);
}

/* gets the address of an object representing a C pointer */
char *factor_vm::alien_offset(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case BYTE_ARRAY_TYPE:
		return untag<byte_array>(obj)->data<char>();
	case ALIEN_TYPE:
		return (char *)untag<alien>(obj)->address;
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,obj);
		return NULL; /* can't happen */
	}
}

VM_C_API char *alien_offset(cell obj, factor_vm *parent)
{
	return parent->alien_offset(obj);
}

/* For FFI calls passing structs by value. Cannot allocate */
void factor_vm::to_value_struct(cell src, void *dest, cell size)
{
	memcpy(dest,alien_offset(src),size);
}

VM_C_API void to_value_struct(cell src, void *dest, cell size, factor_vm *parent)
{
	return parent->to_value_struct(src,dest,size);
}

/* For FFI callbacks receiving structs by value */
cell factor_vm::from_value_struct(void *src, cell size)
{
	byte_array *bytes = allot_byte_array(size);
	memcpy(bytes->data<void>(),src,size);
	return tag<byte_array>(bytes);
}

VM_C_API cell from_value_struct(void *src, cell size, factor_vm *parent)
{
	return parent->from_value_struct(src,size);
}

/* On some x86 OSes, structs <= 8 bytes are returned in registers. */
cell factor_vm::from_small_struct(cell x, cell y, cell size)
{
	cell data[2];
	data[0] = x;
	data[1] = y;
	return from_value_struct(data,size);
}

VM_C_API cell from_small_struct(cell x, cell y, cell size, factor_vm *parent)
{
	return parent->from_small_struct(x,y,size);
}

/* On OS X/PPC, complex numbers are returned in registers. */
cell factor_vm::from_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size)
{
	cell data[4];
	data[0] = x1;
	data[1] = x2;
	data[2] = x3;
	data[3] = x4;
	return from_value_struct(data,size);
}

VM_C_API cell from_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size, factor_vm *parent)
{
	return parent->from_medium_struct(x1, x2, x3, x4, size);
}

}
