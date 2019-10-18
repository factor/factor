#include "master.hpp"

namespace factor
{

array *factor_vm::allot_array(cell capacity, cell fill_)
{
	data_root<object> fill(fill_,this);
	array *new_array = allot_uninitialized_array<array>(capacity);
	memset_cell(new_array->data(),fill.value(),capacity * sizeof(cell));
	return new_array;
}

void factor_vm::primitive_array()
{
	data_root<object> fill(ctx->pop(),this);
	cell capacity = unbox_array_size();
	array *new_array = allot_uninitialized_array<array>(capacity);
	memset_cell(new_array->data(),fill.value(),capacity * sizeof(cell));
	ctx->push(tag<array>(new_array));
}

cell factor_vm::allot_array_1(cell obj_)
{
	data_root<object> obj(obj_,this);
	data_root<array> a(allot_uninitialized_array<array>(1),this);
	set_array_nth(a.untagged(),0,obj.value());
	return a.value();
}

cell factor_vm::allot_array_2(cell v1_, cell v2_)
{
	data_root<object> v1(v1_,this);
	data_root<object> v2(v2_,this);
	data_root<array> a(allot_uninitialized_array<array>(2),this);
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	return a.value();
}

cell factor_vm::allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_)
{
	data_root<object> v1(v1_,this);
	data_root<object> v2(v2_,this);
	data_root<object> v3(v3_,this);
	data_root<object> v4(v4_,this);
	data_root<array> a(allot_uninitialized_array<array>(4),this);
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	set_array_nth(a.untagged(),2,v3.value());
	set_array_nth(a.untagged(),3,v4.value());
	return a.value();
}

void factor_vm::primitive_resize_array()
{
	data_root<array> a(ctx->pop(),this);
	a.untag_check(this);
	cell capacity = unbox_array_size();
	ctx->push(tag<array>(reallot_array(a.untagged(),capacity)));
}

cell factor_vm::std_vector_to_array(std::vector<cell> &elements)
{
	cell element_count = elements.size();
	data_roots.push_back(data_root_range(&elements[0],element_count));

	tagged<array> objects(allot_uninitialized_array<array>(element_count));
	memcpy(objects->data(),&elements[0],element_count * sizeof(cell));

	data_roots.pop_back();

	return objects.value();
}

void growable_array::add(cell elt_)
{
	factor_vm *parent = elements.parent;
	data_root<object> elt(elt_,parent);
	if(count == array_capacity(elements.untagged()))
		elements = parent->reallot_array(elements.untagged(),count * 2);

	parent->set_array_nth(elements.untagged(),count++,elt.value());
}

void growable_array::append(array *elts_)
{
	factor_vm *parent = elements.parent;
	data_root<array> elts(elts_,parent);
	cell capacity = array_capacity(elts.untagged());
	if(count + capacity > array_capacity(elements.untagged()))
	{
		elements = parent->reallot_array(elements.untagged(),
			(count + capacity) * 2);
	}

	for(cell index = 0; index < capacity; index++)
		parent->set_array_nth(elements.untagged(),count++,array_nth(elts.untagged(),index));
}

void growable_array::trim()
{
	factor_vm *parent = elements.parent;
	elements = parent->reallot_array(elements.untagged(),count);
}

}
