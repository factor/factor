#include "master.hpp"

/* make a new array with an initial element */
F_ARRAY *allot_array(CELL capacity, CELL fill_)
{
	gc_root<F_OBJECT> fill(fill_);
	gc_root<F_ARRAY> array(allot_array_internal<F_ARRAY>(capacity));

	if(fill.value() == tag_fixnum(0))
		memset((void*)AREF(array.untagged(),0),'\0',capacity * CELLS);
	else
	{
		/* No need for write barrier here. Either the object is in
		the nursery, or it was allocated directly in tenured space
		and the write barrier is already hit for us in that case. */
		CELL i;
		for(i = 0; i < capacity; i++)
			put(AREF(array.untagged(),i),fill.value());
	}
	return array.untagged();
}

/* push a new array on the stack */
void primitive_array(void)
{
	CELL initial = dpop();
	CELL size = unbox_array_size();
	dpush(tag_array(allot_array(size,initial)));
}

CELL allot_array_1(CELL obj_)
{
	gc_root<F_OBJECT> obj(obj_);
	gc_root<F_ARRAY> a(allot_array_internal<F_ARRAY>(1));
	set_array_nth(a.untagged(),0,obj.value());
	return a.value();
}

CELL allot_array_2(CELL v1_, CELL v2_)
{
	gc_root<F_OBJECT> v1(v1_);
	gc_root<F_OBJECT> v2(v2_);
	gc_root<F_ARRAY> a(allot_array_internal<F_ARRAY>(2));
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	return a.value();
}

CELL allot_array_4(CELL v1_, CELL v2_, CELL v3_, CELL v4_)
{
	gc_root<F_OBJECT> v1(v1_);
	gc_root<F_OBJECT> v2(v2_);
	gc_root<F_OBJECT> v3(v3_);
	gc_root<F_OBJECT> v4(v4_);
	gc_root<F_ARRAY> a(allot_array_internal<F_ARRAY>(4));
	set_array_nth(a.untagged(),0,v1.value());
	set_array_nth(a.untagged(),1,v2.value());
	set_array_nth(a.untagged(),2,v3.value());
	set_array_nth(a.untagged(),3,v4.value());
	return a.value();
}

void primitive_resize_array(void)
{
	F_ARRAY* array = untag_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_array(reallot_array(array,capacity)));
}

void growable_array::add(CELL elt_)
{
	gc_root<F_OBJECT> elt(elt_);
	if(count == array_capacity(array.untagged()))
		array = reallot_array(array.untagged(),count * 2);

	set_array_nth(array.untagged(),count++,elt.value());
}

void growable_array::trim()
{
	array = reallot_array(array.untagged(),count);
}
