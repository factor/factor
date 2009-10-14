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
		here = h + align8(size);
		return (object *)h;
	}
};

}
