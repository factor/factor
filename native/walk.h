/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_walk_ptr;

/* Begin iterating through the heap. This is not re-entrant. */
INLINE void begin_heap_walk(void)
{
	heap_walk_ptr = active.base;
}

INLINE bool heap_step(CELL* size, CELL* type)
{
	CELL value = get(heap_walk_ptr);
	CELL obj = heap_walk_ptr;

	if(headerp(value))
	{
		*size = align8(untagged_object_size(heap_walk_ptr));
		*type = untag_header(value);
	}
	else
	{
		*size = CELLS * 2;
		*type = CONS_TYPE;
	}

	heap_walk_ptr += *size;

	if(*type < HEADER_TYPE)
		obj = RETAG(obj,*type);
	else
		obj = RETAG(obj,OBJECT_TYPE);

	return obj;
}

INLINE bool walk_donep(void)
{
	return (heap_walk_ptr >= active.here);
}

void primitive_heap_stats(void);
void primitive_instances(void);
