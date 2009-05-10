#include "master.hpp"

factor::cell userenv[USER_ENV];

namespace factor
{

cell T;

PRIMITIVE(getenv)
{
	fixnum e = untag_fixnum(dpeek());
	drepl(userenv[e]);
}

PRIMITIVE(setenv)
{
	fixnum e = untag_fixnum(dpop());
	cell value = dpop();
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
	fixnum slot = untag_fixnum(dpop());
	object *obj = untag<object>(dpop());
	cell value = dpop();

	obj->slots()[slot] = value;
	write_barrier(obj);
}

PRIMITIVE(load_locals)
{
	fixnum count = untag_fixnum(dpop());
	memcpy((cell *)(rs + sizeof(cell)),(cell *)(ds - sizeof(cell) * (count - 1)),sizeof(cell) * count);
	ds -= sizeof(cell) * count;
	rs += sizeof(cell) * count;
}

static cell clone_object(cell obj_)
{
	gc_root<object> obj(obj_);

	if(immediate_p(obj.value()))
		return obj.value();
	else
	{
		cell size = object_size(obj.value());
		object *new_obj = allot_object(obj.type(),size);
		memcpy(new_obj,obj.untagged(),size);
		return tag_dynamic(new_obj);
	}
}

PRIMITIVE(clone)
{
	drepl(clone_object(dpeek()));
}

}
