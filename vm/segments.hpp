namespace factor
{

inline cell align_page(cell a)
{
	return align(a,getpagesize());
}

/* segments set up guard pages to check for under/overflow.
size must be a multiple of the page size */
struct segment {
	cell start;
	cell size;
	cell end;

	explicit segment(cell size, bool executable_p, bool canary_page_p);
	~segment();

	bool canary_p(cell addr)
	{
		return (addr >= start - 2*getpagesize() && addr < start - getpagesize());
	}

	bool underflow_p(cell addr)
	{
		return (addr >= start - getpagesize() && addr < start);
	}

	bool overflow_p(cell addr)
	{
		return (addr >= end && addr < end + getpagesize());
	}
};

}
