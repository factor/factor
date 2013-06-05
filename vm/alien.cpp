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
				general_error(ERROR_EXPIRED,obj,false_object);
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

/* make an alien */
/* Allocates memory */
cell factor_vm::allot_alien(cell delegate_, cell displacement)
{
	if(displacement == 0)
		return delegate_;

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

/* Allocates memory */
cell factor_vm::allot_alien(void *address)
{
	return allot_alien(false_object,(cell)address);
}

/* make an alien pointing at an offset of another alien */
/* Allocates memory */
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
/* Allocates memory (from_unsigned_cell can allocate) */
void factor_vm::primitive_alien_address()
{
	ctx->replace(from_unsigned_cell((cell)pinned_alien_offset(ctx->peek())));
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
		parent->ctx->push(parent->from(*(type*)(parent->alien_pointer()))); \
	} \
	VM_C_API void primitive_set_alien_##name(factor_vm *parent) \
	{ \
		type *ptr = (type *)parent->alien_pointer(); \
		type value = (type)parent->to(parent->ctx->pop()); \
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
/* Allocates memory */
void factor_vm::primitive_dlsym()
{
	data_root<object> library(ctx->pop(),this);
	data_root<byte_array> name(ctx->peek(),this);
	name.untag_check(this);

	symbol_char *sym = name->data<symbol_char>();

	if(to_boolean(library.value()))
	{
		dll *d = untag_check<dll>(library.value());

		if(d->handle == NULL)
			ctx->replace(false_object);
		else
			ctx->replace(allot_alien(ffi_dlsym(d,sym)));
	}
	else
		ctx->replace(allot_alien(ffi_dlsym(NULL,sym)));
}

/* look up a symbol in a native library */
/* Allocates memory */
void factor_vm::primitive_dlsym_raw()
{
	data_root<object> library(ctx->pop(),this);
	data_root<byte_array> name(ctx->peek(),this);
	name.untag_check(this);

	symbol_char *sym = name->data<symbol_char>();

	if(to_boolean(library.value()))
	{
		dll *d = untag_check<dll>(library.value());

		if(d->handle == NULL)
			ctx->replace(false_object);
		else
			ctx->replace(allot_alien(ffi_dlsym_raw(d,sym)));
	}
	else
		ctx->replace(allot_alien(ffi_dlsym_raw(NULL,sym)));
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
	cell library = ctx->peek();
	if(to_boolean(library))
		ctx->replace(tag_boolean(untag_check<dll>(library)->handle != NULL));
	else
		ctx->replace(true_object);
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

}
