namespace factor
{

struct zone {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends */
	cell start;
	cell here;
	cell size;
	cell end;

	cell init_zone(cell size_, cell start_)
	{
		size = size_;
		start = here = start_;
		end = start_ + size_;
		return end;
	}

	inline bool contains_p(object *pointer)
	{
		return ((cell)pointer - start) < size;
	}

	inline object *allot(cell size)
	{
		cell h = here;
		here = h + align8(size);
		return (object *)h;
	}
};

}
