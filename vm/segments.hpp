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

	explicit segment(cell size);
	~segment();
};

}
