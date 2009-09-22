#include "master.hpp"

namespace factor
{

/* make a new array with an initial element */
array *factorvm::allot_array(cell capacity, cell fill_)
{
	gc_root<object> fill(fill_,this);
	gc_root<array> new_array(allot_array_internal<array>(capacity),this);

	if(fill.value() == tag_fixnum(0))
		memset(new_array->data(),'\0',capacity * sizeof(cell));
	else
	{
		/* No need for write barrier here. Either the object is in
		the nursery, or it was allocated directly in tenured space
		and the write barrier is already hit for us in that case. */
		cell i;
		for(i = 0; i < capacity; i++)
			new_array->data()[i] = fill.value();
	}
	return new_array.untagged();
}


/* push a new array on the stack */
inline void factorvm::vmprim_array()
{
	cell initial = dpop();
	cell size = unbox_array_size();
	dpush(tag<array>(allot_array(size,initial)));
}

PRIMITIVE(array)
{
	PRIMITIVE_GETVM()->vmprim_array();
}

cell factorvm::allot_array_1(cell obj_)
{
	gc_root<object> obj(obj_,this);
	gc_root<array> a(allot_array_internal<array>(1),this);
	set_array_nth(a.untagged(),0,obj.value());
	return a.value();
}


cell factorvm::allot_array_2(cell v1_, cell v2_)
{
	gc_root<object> v1(v1_,this);
	gc_root<object> v2(v2_,this);
	gc_root<array> a(allot_array_internal<array>(2),this);
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	return a.value();
}


cell factorvm::allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_)
{
	gc_root<object> v1(v1_,this);
	gc_root<object> v2(v2_,this);
	gc_root<object> v3(v3_,this);
	gc_root<object> v4(v4_,this);
	gc_root<array> a(allot_array_internal<array>(4),this);
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	set_array_nth(a.untagged(),2,v3.value());
	set_array_nth(a.untagged(),3,v4.value());
	return a.value();
}


inline void factorvm::vmprim_resize_array()
{
	array* a = untag_check<array>(dpop());
	cell capacity = unbox_array_size();
	dpush(tag<array>(reallot_array(a,capacity)));
}

PRIMITIVE(resize_array)
{
	PRIMITIVE_GETVM()->vmprim_resize_array();
}

void growable_array::add(cell elt_)
{
	factorvm* myvm = elements.myvm;
	gc_root<object> elt(elt_,myvm);
	if(count == array_capacity(elements.untagged()))
		elements = myvm->reallot_array(elements.untagged(),count * 2);

	myvm->set_array_nth(elements.untagged(),count++,elt.value());
}

void growable_array::trim()
{
	factorvm *myvm = elements.myvm;
	elements = myvm->reallot_array(elements.untagged(),count);
}

}
