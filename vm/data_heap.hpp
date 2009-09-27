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
};

struct data_heap {
	segment *seg;

	cell young_size;
	cell aging_size;
	cell tenured_size;

	cell gen_count;

	zone *generations;
	zone *semispaces;

	char *allot_markers;
	char *allot_markers_end;

	char *cards;
	char *cards_end;

	char *decks;
	char *decks_end;
	
	/* the 0th generation is where new objects are allocated. */
	cell nursery() { return 0; }
	
	/* where objects hang around */
	cell aging() { return gen_count - 2; }
	
	/* the oldest generation */
	cell tenured() { return gen_count - 1; }
	
	bool have_aging_p() { return gen_count > 2; }

	data_heap(factor_vm *myvm, cell gen_count, cell young_size, cell aging_size, cell tenured_size);
	~data_heap();
};

static const cell max_gen_count = 3;

inline static bool in_zone(zone *z, object *pointer)
{
	return (cell)pointer >= z->start && (cell)pointer < z->end;
}


}
