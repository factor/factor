namespace factor
{

struct tenured_space_layout {
	cell block_size(object *block)
	{
		if(block->free_p())
		{
			free_heap_block *free_block = (free_heap_block *)block;
			return free_block->size();
		}
		else
			return block->size();
	}
};

struct tenured_space : zone {
	object_start_map starts;

	tenured_space(cell size, cell start) :
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
