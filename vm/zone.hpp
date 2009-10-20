namespace factor
{

struct zone {
	/* offset of 'here' and 'end' is hardcoded in compiler backends */
	cell here;
	cell start;
	cell end;
	cell size;

	zone(cell size_, cell start_) : here(0), start(start_), end(start_ + size_), size(size_) {}

	inline bool contains_p(object *pointer)
	{
		return ((cell)pointer - start) < size;
	}

	inline object *allot(cell size)
	{
		cell h = here;
		here = h + align(size,data_alignment);
		return (object *)h;
	}

	cell next_object_after(cell scan)
	{
		cell size = ((object *)scan)->size();
		if(scan + size < here)
			return scan + size;
		else
			return 0;
	}
};

}
