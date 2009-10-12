namespace factor
{

struct zone {
	/* allocation pointer is 'here'; its offset is hardcoded in the
	compiler backends */
	cell start;
	cell here;
	cell size;
	cell end;

	zone(cell size_, cell start_) : start(start_), here(0), size(size_), end(start_ + size_) {}

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
