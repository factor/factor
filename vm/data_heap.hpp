namespace factor
{

/* generational copying GC divides memory into zones */
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

struct data_heap {
	segment *seg;

	cell young_size;
	cell aging_size;
	cell tenured_size;

	zone *generations;
	zone *semispaces;

	char *allot_markers;
	char *allot_markers_end;

	char *cards;
	char *cards_end;

	char *decks;
	char *decks_end;
	
	explicit data_heap(factor_vm *myvm, cell young_size, cell aging_size, cell tenured_size);
	~data_heap();
};

static const cell nursery_gen = 0;
static const cell aging_gen = 1;
static const cell tenured_gen = 2;
static const cell gen_count = 3;

}
