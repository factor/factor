namespace factor
{

struct tenured_space : free_list_allocator<object> {
	object_start_map starts;
	std::vector<object *> mark_stack;

	tenured_space(cell size, cell start) :
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

	object *first_allocated_block_after(object *block)
	{
		while(block != this->last_block() && block->free_p())
		{
			free_heap_block *free_block = (free_heap_block *)block;
			block = (object *)((cell)free_block + free_block->size());
		}

		if(block == this->last_block())
			return NULL;
		else
			return block;
	}

	cell first_object()
	{
		return (cell)first_allocated_block_after(this->first_block());
	}

	cell next_object_after(cell scan)
	{
		cell size = ((object *)scan)->size();
		object *next = (object *)(scan + size);
		return (cell)first_allocated_block_after(next);
	}

	void clear_mark_bits()
	{
		state.clear_mark_bits();
	}

	void clear_mark_stack()
	{
		mark_stack.clear();
	}

	bool marked_p(object *obj)
	{
		return this->state.marked_p(obj);
	}

	void mark_and_push(object *obj)
	{
		this->state.set_marked_p(obj);
		this->mark_stack.push_back(obj);
	}
};

}
