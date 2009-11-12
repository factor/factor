#include "master.hpp"

/* A tool to debug write barriers. Call check_data_heap() to ensure that all
cards that should be marked are actually marked. */

namespace factor
{

enum generation {
	nursery_generation,
	aging_generation,
	tenured_generation
};

inline generation generation_of(factor_vm *parent, object *obj)
{
	if(parent->data->nursery->contains_p(obj))
		return nursery_generation;
	else if(parent->data->aging->contains_p(obj))
		return aging_generation;
	else if(parent->data->tenured->contains_p(obj))
		return tenured_generation;
	else
	{
		critical_error("Bad object",(cell)obj);
		return (generation)-1;
	}
}

struct slot_checker {
	factor_vm *parent;
	object *obj;
	generation gen;

	explicit slot_checker(factor_vm *parent_, object *obj_, generation gen_) :
		parent(parent_), obj(obj_), gen(gen_) {}

	void check_write_barrier(cell *slot_ptr, generation target, char mask)
	{
		cell object_card_pointer = parent->cards_offset + ((cell)obj >> card_bits);
		cell slot_card_pointer = parent->cards_offset + ((cell)slot_ptr >> card_bits);
		char slot_card_value = *(char *)slot_card_pointer;
		if((slot_card_value & mask) != mask)
		{
			printf("card not marked\n");
			printf("source generation: %d\n",gen);
			printf("target generation: %d\n",target);
			printf("object: 0x%lx\n",(cell)obj);
			printf("object type: %ld\n",obj->type());
			printf("slot pointer: 0x%lx\n",(cell)slot_ptr);
			printf("slot value: 0x%lx\n",*slot_ptr);
			printf("card of object: 0x%lx\n",object_card_pointer);
			printf("card of slot: 0x%lx\n",slot_card_pointer);
			printf("\n");
			parent->factorbug();
		}
	}

	void operator()(cell *slot_ptr)
	{
		if(!immediate_p(*slot_ptr))
		{
			generation target = generation_of(parent,untag<object>(*slot_ptr));
			switch(gen)
			{
			case nursery_generation:
				break;
			case aging_generation:
				if(target == nursery_generation)
					check_write_barrier(slot_ptr,target,card_points_to_nursery);
				break;
			case tenured_generation:
				if(target == nursery_generation)
					check_write_barrier(slot_ptr,target,card_points_to_nursery);
				else if(target == aging_generation)
					check_write_barrier(slot_ptr,target,card_points_to_aging);
				break;
			}
		}
	}
};

struct object_checker {
	factor_vm *parent;

	explicit object_checker(factor_vm *parent_) : parent(parent_) {}

	void operator()(object *obj)
	{
		slot_checker checker(parent,obj,generation_of(parent,obj));
		obj->each_slot(checker);
	}
};

void factor_vm::check_data_heap()
{
	object_checker checker(this);
	each_object(checker);
}

}
