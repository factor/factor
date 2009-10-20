namespace factor
{

struct aging_space : zone {
	object_start_map starts;

	aging_space(cell size, cell start) :
		zone(size,start), starts(size,start) {}

	object *allot(cell size)
	{
		if(here + size > end) return NULL;

		object *obj = zone::allot(size);
		starts.record_object_start_offset(obj);
		return obj;
	}
};

}
