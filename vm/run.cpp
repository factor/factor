#include "master.hpp"

namespace factor
{

void factor_vm::primitive_getenv()
{
	fixnum e = untag_fixnum(dpeek());
	drepl(special_objects[e]);
}

void factor_vm::primitive_setenv()
{
	fixnum e = untag_fixnum(dpop());
	cell value = dpop();
	special_objects[e] = value;
}

void factor_vm::primitive_exit()
{
	exit(to_fixnum(dpop()));
}

void factor_vm::primitive_micros()
{
	box_unsigned_8(current_micros());
}

void factor_vm::primitive_sleep()
{
	sleep_micros(to_cell(dpop()));
}

void factor_vm::primitive_set_slot()
{
	fixnum slot = untag_fixnum(dpop());
	object *obj = untag<object>(dpop());
	cell value = dpop();

	cell *slot_ptr = &obj->slots()[slot];
	*slot_ptr = value;
	write_barrier(slot_ptr);
}

void factor_vm::primitive_load_locals()
{
	fixnum count = untag_fixnum(dpop());
	memcpy((cell *)(rs + sizeof(cell)),(cell *)(ds - sizeof(cell) * (count - 1)),sizeof(cell) * count);
	ds -= sizeof(cell) * count;
	rs += sizeof(cell) * count;
}

cell factor_vm::clone_object(cell obj_)
{
	data_root<object> obj(obj_,this);

	if(immediate_p(obj.value()))
		return obj.value();
	else
	{
		cell size = object_size(obj.value());
		object *new_obj = allot_object(header(obj.type()),size);
		memcpy(new_obj,obj.untagged(),size);
		return tag_dynamic(new_obj);
	}
}

void factor_vm::primitive_clone()
{
	drepl(clone_object(dpeek()));
}

}
