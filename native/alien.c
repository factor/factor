#include "factor.h"

/* test if alien is no longer valid (it survived an image save/load) */
void primitive_expired(void)
{
	CELL object = dpeek();

	if(type_of(object) == ALIEN_TYPE)
	{
		ALIEN *alien = untag_alien_fast(object);
		drepl(tag_boolean(alien->expired));
	}
	else if(object == F)
		drepl(T);
	else
		drepl(F);
}

/* gets the address of an object representing a C pointer */
void *alien_offset(CELL object)
{
	ALIEN *alien;
	F_ARRAY *array;
	DISPLACED_ALIEN *d;

	switch(type_of(object))
	{
	case ALIEN_TYPE:
		alien = untag_alien_fast(object);
		if(alien->expired)
			general_error(ERROR_EXPIRED,object,true);
		return alien->ptr;
	case BYTE_ARRAY_TYPE:
		array = untag_byte_array_fast(object);
		return array + 1;
	case DISPLACED_ALIEN_TYPE:
		d = untag_displaced_alien_fast(object);
		return alien_offset(d->alien) + d->displacement;
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,object);
		return (void*)-1; /* can't happen */
	}
}

/* pop ( alien n ) from datastack, return alien's address plus n */
INLINE void *alien_pointer(void)
{
	F_FIXNUM offset = unbox_signed_cell();
	return alien_offset(dpop()) + offset;
}

/* pop an object representing a C pointer */
void *unbox_alien(void)
{
	return alien_offset(dpop());
}

/* make an alien */
ALIEN *alien(void* ptr)
{
	ALIEN* alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	alien->ptr = ptr;
	alien->expired = false;
	return alien;
}

/* make an alien and push */
void box_alien(void *ptr)
{
	if(ptr == NULL)
		dpush(F);
	else
		dpush(tag_object(alien(ptr)));
}

/* make an alien form an address on the stack */
void primitive_alien(void)
{
	void* ptr = (void*)unbox_signed_cell();
	maybe_gc(sizeof(ALIEN));
	box_alien(ptr);
}

/* make an alien pointing at an offset of another alien */
void primitive_displaced_alien(void)
{
	CELL alien;
	CELL displacement;
	DISPLACED_ALIEN* d;
	maybe_gc(sizeof(DISPLACED_ALIEN));
	alien = dpop();
	displacement = unbox_unsigned_cell();
	d = allot_object(DISPLACED_ALIEN_TYPE,sizeof(DISPLACED_ALIEN));
	d->alien = alien;
	d->displacement = displacement;
	dpush(tag_object(d));
}

/* address of an object representing a C pointer */
void primitive_alien_address(void)
{
	box_unsigned_cell((CELL)alien_offset(dpop()));
}

/* convert C string at address to Factor string */
void primitive_alien_to_string(void)
{
	maybe_gc(0);
	drepl(tag_object(from_c_string(alien_offset(dpeek()))));
}

/* convert Factor string to C string allocated in the Factor heap */
void primitive_string_to_alien(void)
{
	maybe_gc(0);
	drepl(tag_object(string_to_alien(untag_string(dpeek()),true)));
}

/* expire aliens when loading the image */
void fixup_alien(ALIEN *alien)
{
	alien->expired = true;
}

/* image loading */
void fixup_displaced_alien(DISPLACED_ALIEN *d)
{
	data_fixup(&d->alien);
}

/* GC */
void collect_displaced_alien(DISPLACED_ALIEN *d)
{
	copy_handle(&d->alien);
}

/* define words to read/write numericals values at an alien address */
#define DEF_ALIEN_SLOT(name,type,boxer) \
void primitive_alien_##name (void) \
{ \
	box_##boxer (*(type*)alien_pointer()); \
} \
void primitive_set_alien_##name (void) \
{ \
	type* ptr = alien_pointer(); \
	type value = unbox_##boxer(); \
	*ptr = value; \
}

DEF_ALIEN_SLOT(signed_cell,F_FIXNUM,signed_cell)
DEF_ALIEN_SLOT(unsigned_cell,CELL,unsigned_cell)
DEF_ALIEN_SLOT(signed_8,s64,signed_8)
DEF_ALIEN_SLOT(unsigned_8,u64,unsigned_8)
DEF_ALIEN_SLOT(signed_4,s32,signed_4)
DEF_ALIEN_SLOT(unsigned_4,u32,unsigned_4)
DEF_ALIEN_SLOT(signed_2,s16,signed_2)
DEF_ALIEN_SLOT(unsigned_2,u16,unsigned_2)
DEF_ALIEN_SLOT(signed_1,BYTE,signed_1)
DEF_ALIEN_SLOT(unsigned_1,BYTE,unsigned_1)
DEF_ALIEN_SLOT(float,float,float)
DEF_ALIEN_SLOT(double,double,double)

/* for FFI calls passing structs by value */
void unbox_value_struct(void *dest, CELL size)
{
	memcpy(dest,unbox_alien(),size);
}
