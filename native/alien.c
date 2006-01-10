#include "factor.h"

void primitive_expired(void)
{
	CELL object = dpeek();

	if(type_of(object) == ALIEN_TYPE)
	{
		ALIEN *alien = untag_alien_fast(object);
		drepl(tag_boolean(alien->expired));
	}
	else
		drepl(F);
}

void* alien_offset(CELL object)
{
	ALIEN *alien;
	F_ARRAY *array;
	DISPLACED_ALIEN *d;

	switch(type_of(object))
	{
	case ALIEN_TYPE:
		alien = untag_alien_fast(object);
		if(alien->expired)
			general_error(ERROR_EXPIRED,object);
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

INLINE void* alien_pointer(void)
{
	F_FIXNUM offset = unbox_signed_cell();
	return alien_offset(dpop()) + offset;
}

void* unbox_alien(void)
{
	return alien_offset(dpop());
}

ALIEN* alien(void* ptr)
{
	ALIEN* alien = allot_object(ALIEN_TYPE,sizeof(ALIEN));
	alien->ptr = ptr;
	alien->expired = false;
	return alien;
}

void box_alien(void *ptr)
{
	if(ptr == NULL)
		dpush(F);
	else
		dpush(tag_object(alien(ptr)));
}

void primitive_alien(void)
{
	void* ptr = (void*)unbox_signed_cell();
	maybe_gc(sizeof(ALIEN));
	box_alien(ptr);
}

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

void primitive_alien_address(void)
{
	box_unsigned_cell((CELL)alien_offset(dpop()));
}

void primitive_alien_to_string(void)
{
	maybe_gc(0);
	drepl(tag_object(from_c_string(alien_offset(dpeek()))));
}

void primitive_string_to_alien(void)
{
	maybe_gc(0);
	drepl(tag_object(string_to_alien(untag_string(dpeek()),true)));
}

void fixup_alien(ALIEN* alien)
{
	alien->expired = true;
}

void fixup_displaced_alien(DISPLACED_ALIEN* d)
{
	data_fixup(&d->alien);
}

void collect_displaced_alien(DISPLACED_ALIEN* d)
{
	copy_handle(&d->alien);
}

#define DEF_ALIEN_SLOT(name,type,boxer) \
void primitive_alien_##name (void) \
{ \
	box_##boxer (*(type*)alien_pointer()); \
} \
void primitive_set_alien_##name (void) \
{ \
	type* ptr = alien_pointer(); \
	type value = unbox_##boxer (); \
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
