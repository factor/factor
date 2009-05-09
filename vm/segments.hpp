namespace factor
{

struct segment {
	cell start;
	cell size;
	cell end;
};

inline static cell align_page(cell a)
{
	return align(a,getpagesize());
}

}
