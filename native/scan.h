/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* End of heap when walk was started; prevents infinite loop if
walk consing */
CELL heap_scan_end;

/* Begin iterating through the heap. This is not re-entrant. */
INLINE void begin_heap_scan(void)
{
	heap_scan_ptr = active.base;
}

INLINE CELL heap_step(CELL* size, CELL* type)
{
	CELL value = get(heap_scan_ptr);
	CELL obj = heap_scan_ptr;

	if(headerp(value))
	{
		*size = align8(untagged_object_size(heap_scan_ptr));
		*type = untag_header(value);
	}
	else
	{
		*size = CELLS * 2;
		*type = CONS_TYPE;
	}

	heap_scan_ptr += *size;

	if(*type < HEADER_TYPE)
		obj = RETAG(obj,*type);
	else
		obj = RETAG(obj,OBJECT_TYPE);

	return obj;
}

INLINE bool walk_donep(void)
{
	return (heap_scan_ptr >= active.here);
}

void primitive_heap_stats(void);
void primitive_instances(void);

void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);
