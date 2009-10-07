namespace factor
{

struct data_heap {
	cell young_size;
	cell aging_size;
	cell tenured_size;

	segment *seg;

	zone *nursery;
	aging_space *aging;
	aging_space *aging_semispace;
	tenured_space *tenured;
	tenured_space *tenured_semispace;

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
