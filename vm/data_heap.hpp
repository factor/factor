namespace factor
{

struct data_heap {
	cell start;

	cell young_size;
	cell aging_size;
	cell tenured_size;

	segment *seg;

	zone *nursery;
	aging_space *aging;
	aging_space *aging_semispace;
	tenured_space *tenured;
	tenured_space *tenured_semispace;

	card *cards;
	card *cards_end;

	card_deck *decks;
	card_deck *decks_end;
	
	explicit data_heap(cell young_size, cell aging_size, cell tenured_size);
	~data_heap();
	data_heap *grow(cell requested_size);
};

}
