#include "master.hpp"

CELL userenv[USER_ENV];
CELL T;

PRIMITIVE(getenv)
{
	F_FIXNUM e = untag_fixnum(dpeek());
	drepl(userenv[e]);
}

PRIMITIVE(setenv)
{
	F_FIXNUM e = untag_fixnum(dpop());
	CELL value = dpop();
	userenv[e] = value;
}

PRIMITIVE(exit)
{
	exit(to_fixnum(dpop()));
}

PRIMITIVE(micros)
{
	box_unsigned_8(current_micros());
}

PRIMITIVE(sleep)
{
	sleep_micros(to_cell(dpop()));
}

PRIMITIVE(set_slot)
{
	F_FIXNUM slot = untag_fixnum(dpop());
	F_OBJECT *object = untag<F_OBJECT>(dpop());
	CELL value = dpop();

	object->slots()[slot] = value;
	write_barrier(object);
}

PRIMITIVE(load_locals)
{
	F_FIXNUM count = untag_fixnum(dpop());
	memcpy((CELL *)(rs + CELLS),(CELL *)(ds - CELLS * (count - 1)),CELLS * count);
	ds -= CELLS * count;
	rs += CELLS * count;
}

static CELL clone_object(CELL object_)
{
	gc_root<F_OBJECT> object(object_);

	if(immediate_p(object.value()))
		return object.value();
	else
	{
		CELL size = object_size(object.value());
		F_OBJECT *new_obj = allot_object(object.type(),size);
		memcpy(new_obj,object.untagged(),size);
		return tag_dynamic(new_obj);
	}
}

PRIMITIVE(clone)
{
	drepl(clone_object(dpeek()));
}
