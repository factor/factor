#include "master.hpp"

namespace factor
{

inline void factor_vm::primitive_getenv()
{
	fixnum e = untag_fixnum(dpeek());
	drepl(userenv[e]);
}

PRIMITIVE_FORWARD(getenv)

inline void factor_vm::primitive_setenv()
{
	fixnum e = untag_fixnum(dpop());
	cell value = dpop();
	userenv[e] = value;
}

PRIMITIVE_FORWARD(setenv)

inline void factor_vm::primitive_exit()
{
	exit(to_fixnum(dpop()));
}

PRIMITIVE_FORWARD(exit)

inline void factor_vm::primitive_micros()
{
	box_unsigned_8(current_micros());
}

PRIMITIVE_FORWARD(micros)

inline void factor_vm::primitive_sleep()
{
	sleep_micros(to_cell(dpop()));
}

PRIMITIVE_FORWARD(sleep)

inline void factor_vm::primitive_set_slot()
{
	fixnum slot = untag_fixnum(dpop());
	object *obj = untag<object>(dpop());
	cell value = dpop();

	obj->slots()[slot] = value;
	write_barrier(obj);
}

PRIMITIVE_FORWARD(set_slot)

inline void factor_vm::primitive_load_locals()
{
	fixnum count = untag_fixnum(dpop());
	memcpy((cell *)(rs + sizeof(cell)),(cell *)(ds - sizeof(cell) * (count - 1)),sizeof(cell) * count);
	ds -= sizeof(cell) * count;
	rs += sizeof(cell) * count;
}

PRIMITIVE_FORWARD(load_locals)

cell factor_vm::clone_object(cell obj_)
{
	gc_root<object> obj(obj_,this);

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

inline void factor_vm::primitive_clone()
{
	drepl(clone_object(dpeek()));
}

PRIMITIVE_FORWARD(clone)

}
