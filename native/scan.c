#include "factor.h"

void primitive_begin_scan(void)
{
	heap_scan_ptr = active.base;
	heap_scan_end = active.here;
	heap_scan = true;
}

void primitive_next_object(void)
{
	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;
	CELL size, type;

	if(!heap_scan)
		general_error(ERROR_HEAP_SCAN,F);

	if(heap_scan_ptr >= heap_scan_end)
	{
		dpush(F);
		return;
	}
	
	if(headerp(value))
	{
		size = align8(untagged_object_size(heap_scan_ptr));
		type = untag_header(value);
	}
	else
	{
		size = CELLS * 2;
		type = CONS_TYPE;
	}

	heap_scan_ptr += size;

	if(type < HEADER_TYPE)
		dpush(RETAG(obj,type));
	else
		dpush(RETAG(obj,OBJECT_TYPE));
}

void primitive_end_scan(void)
{
	heap_scan = false;
}

void primitive_heap_stats(void)
{
	int instances[TYPE_COUNT], bytes[TYPE_COUNT];
	int i;
	CELL list = F;

	for(i = 0; i < TYPE_COUNT; i++)
		instances[i] = 0;

	for(i = 0; i < TYPE_COUNT; i++)
		bytes[i] = 0;

	begin_heap_scan();

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
