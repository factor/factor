#include "factor.h"

void primitive_heap_stats(void)
{
	int instances[TYPE_COUNT], bytes[TYPE_COUNT];
	int i;
	CELL list = F;

	for(i = 0; i < TYPE_COUNT; i++)
		instances[i] = 0;

	for(i = 0; i < TYPE_COUNT; i++)
		bytes[i] = 0;

	begin_heap_walk();

	for(;;)
	{
		CELL size, type;
		heap_step(&size,&type);

		if(walk_donep())
			break;

		instances[type]++;
		bytes[type] += size;
	}

	for(i = TYPE_COUNT - 1; i >= 0; i--)
	{
		list = cons(
			cons(tag_fixnum(instances[i]),tag_fixnum(bytes[i])),
			list);
	}

	dpush(list);
}

void primitive_instances(void)
{
	CELL list = F;
	CELL search_type = to_fixnum(dpop());
	CELL here = active.here;

	primitive_gc();

	begin_heap_walk();
	
	for(;;)
	{
		CELL size, type;
		CELL obj = heap_step(&size,&type);

		if(walk_donep())
			break;

		/* don't want an infinite loop if we ask for a list of all
		conses in the image! */
		if(heap_walk_ptr >= here)
			break;

		if(search_type == type)
			list = cons(obj,list);
	}

	dpush(list);
}
