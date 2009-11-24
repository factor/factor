namespace factor
{

struct tenured_space : free_list_allocator<object> {
	object_start_map starts;

	explicit tenured_space(cell size, cell start) :
		free_list_allocator<object>(size,start), starts(size,start) {}

	object *allot(cell size)
	{
		object *obj = free_list_allocator<object>::allot(size);
		if(obj)
		{
			starts.record_object_start_offset(obj);
			return obj;
		}
		else
			return NULL;
	}

	cell first_object()
	{
		return (cell)next_allocated_block_after(this->first_block());
	}

	cell next_object_after(cell scan)
	{
		cell size = ((object *)scan)->size();
		object *next = (object *)(scan + size);
		return (cell)next_allocated_block_after(next);
	}

	void clear_mark_bits()
	{
		state.clear_mark_bits();
	}

	bool marked_p(object *obj)
	{
		return this->state.marked_p(obj);
	}

	void set_marked_p(object *obj)
	{
		this->state.set_marked_p(obj);
	}

	void sweep()
	{
		free_list_allocator<object>::sweep();
		starts.update_for_sweep(&this->state);
	}
};

}
