#include "master.hpp"

factor::cell userenv[USER_ENV];

namespace factor
{


inline void factorvm::vmprim_getenv()
{
	fixnum e = untag_fixnum(dpeek());
	drepl(userenv[e]);
}

PRIMITIVE(getenv)
{
	PRIMITIVE_GETVM()->vmprim_getenv();
}

inline void factorvm::vmprim_setenv()
{
	fixnum e = untag_fixnum(dpop());
	cell value = dpop();
	userenv[e] = value;
}

PRIMITIVE(setenv)
{
	PRIMITIVE_GETVM()->vmprim_setenv();
}

inline void factorvm::vmprim_exit()
{
	exit(to_fixnum(dpop()));
}

PRIMITIVE(exit)
{
	PRIMITIVE_GETVM()->vmprim_exit();
}

inline void factorvm::vmprim_micros()
{
	box_unsigned_8(current_micros());
}

PRIMITIVE(micros)
{
	PRIMITIVE_GETVM()->vmprim_micros();
}

inline void factorvm::vmprim_sleep()
{
	sleep_micros(to_cell(dpop()));
}

PRIMITIVE(sleep)
{
	PRIMITIVE_GETVM()->vmprim_sleep();
}

inline void factorvm::vmprim_set_slot()
{
	fixnum slot = untag_fixnum(dpop());
	object *obj = untag<object>(dpop());
	cell value = dpop();

	obj->slots()[slot] = value;
	write_barrier(obj);
}

PRIMITIVE(set_slot)
{
	PRIMITIVE_GETVM()->vmprim_set_slot();
}

inline void factorvm::vmprim_load_locals()
{
	fixnum count = untag_fixnum(dpop());
	memcpy((cell *)(rs + sizeof(cell)),(cell *)(ds - sizeof(cell) * (count - 1)),sizeof(cell) * count);
	ds -= sizeof(cell) * count;
	rs += sizeof(cell) * count;
}

PRIMITIVE(load_locals)
{
	PRIMITIVE_GETVM()->vmprim_load_locals();
}

cell factorvm::clone_object(cell obj_)
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

inline void factorvm::vmprim_clone()
{
	drepl(clone_object(dpeek()));
}

PRIMITIVE(clone)
{
	PRIMITIVE_GETVM()->vmprim_clone();
}

}
