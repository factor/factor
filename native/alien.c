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

	switch(type_of(object))
	{
	case BYTE_ARRAY_TYPE:
		array = untag_byte_array_fast(object);
		return array + 1;
	case ALIEN_TYPE:
		alien = untag_alien_fast(object);
		if(alien->expired)
			general_error(ERROR_EXPIRED,object,F,true);
		return alien_offset(alien->alien) + alien->displacement;
	case F_TYPE:
		return NULL;
	default:
		type_error(ALIEN_TYPE,object);
		return (void*)-1; /* can't happen */
	}
}

/* pop an object representing a C pointer */
void *unbox_alien(void)
{
	return alien_offset(dpop());
}

/* pop ( alien n ) from datastack, return alien's address plus n */
INLINE void *alien_pointer(void)
{
	F_FIXNUM offset = unbox_signed_cell();
	return unbox_alien() + offset;
}

/* make an alien */
ALIEN *make_alien(CELL delegate, CELL displacement)
{
	ALIEN *alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	alien->alien = delegate;
	alien->displacement = displacement;
	alien->expired = false;
	return alien;
}

/* make an alien and push */
void box_alien(CELL ptr)
{
	if(ptr == 0)
		dpush(F);
	else
		dpush(tag_object(make_alien(F,ptr)));
}

/* make an alien pointing at an offset of another alien */
void primitive_displaced_alien(void)
{
	CELL alien;
	CELL displacement;
	maybe_gc(sizeof(ALIEN));
	alien = dpop();
	displacement = unbox_unsigned_cell();
	if(alien == F && displacement == 0)
		dpush(F);
	else
		dpush(tag_object(make_alien(alien,displacement)));
}

/* address of an object representing a C pointer */
void primitive_alien_address(void)
{
	box_unsigned_cell((CELL)alien_offset(dpop()));
}

/* image loading */
void fixup_alien(ALIEN *d)
{
	data_fixup(&d->alien);
	d->expired = true;
}

/* GC */
void collect_alien(ALIEN *d)
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
DEF_ALIEN_SLOT(signed_1,u8,signed_1)
DEF_ALIEN_SLOT(unsigned_1,u8,unsigned_1)
DEF_ALIEN_SLOT(float,float,float)
DEF_ALIEN_SLOT(double,double,double)

/* for FFI calls passing structs by value */
void unbox_value_struct(void *dest, CELL size)
{
	memcpy(dest,unbox_alien(),size);
}

/* for FFI callbacks receiving structs by value */
void box_value_struct(void *src, CELL size)
{
	F_ARRAY *array = byte_array(size);
	memcpy(array + 1,src,size);
	dpush(tag_object(array));
}
