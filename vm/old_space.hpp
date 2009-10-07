namespace factor
{

struct old_space : zone {
	card *allot_markers;
	card *allot_markers_end;

	old_space(cell size_, cell start_) : zone(size_,start_)
	{
		cell cards_size = size_ >> card_bits;
		allot_markers = new card[cards_size];
		allot_markers_end = allot_markers + cards_size;
	}

	~old_space()
	{
		delete[] allot_markers;
	}

	card *addr_to_allot_marker(object *a)
	{
		return (card *)((((cell)a - start) >> card_bits) + (cell)allot_markers);
	}

	/* we need to remember the first object allocated in the card */
	void record_allocation(object *obj)
	{
		card *ptr = addr_to_allot_marker(obj);
		if(*ptr == invalid_allot_marker)
			*ptr = ((cell)obj & addr_card_mask);
	}

	cell card_offset(cell address)
	{
		return allot_markers[(address - start) >> card_bits];
	}

	object *allot(cell size)
	{
		if(here + size > end) return NULL;

		object *obj = zone::allot(size);
		record_allocation(obj);
		return obj;
	}

	void clear_allot_markers()
	{
		memset(allot_markers,invalid_allot_marker,size >> card_bits);
	}

	/* object *next_object_after(object *ptr)
	{
		cell size = untagged_object_size(ptr);
		if((cell)ptr + size < end)
			return (object *)((cell)ptr + size);
		else
			return NULL;
	} */
};

}
