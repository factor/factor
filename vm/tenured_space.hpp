namespace factor
{

struct tenured_space : bump_allocator {
	object_start_map starts;

	tenured_space(cell size, cell start) :
		bump_allocator(size,start), starts(size,start) {}

	object *allot(cell size)
	{
		if(here + size > end) return NULL;

		object *obj = bump_allocator::allot(size);
		starts.record_object_start_offset(obj);
		return obj;
	}
};

}
