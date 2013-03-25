namespace factor
{

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
/* Allocates memory */
inline object *factor_vm::allot_object(cell type, cell size)
{
#ifdef FACTOR_DEBUG
	FACTOR_ASSERT(!current_gc);
#endif

	/* If the object is smaller than the nursery, allocate it in the nursery,
	after a GC if needed */
	if(nursery.size > size)
	{
		/* If there is insufficient room, collect the nursery */
		if(nursery.here + size > nursery.end)
			primitive_minor_gc();

		object *obj = nursery.allot(size);

		obj->initialize(type);
		return obj;
	}
	/* If the object is bigger than the nursery, allocate it in
	tenured space */
	else
		return allot_large_object(type,size);
}

}
