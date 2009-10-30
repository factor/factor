namespace factor
{

struct data_heap {
	cell start;

	cell young_size;
	cell aging_size;
	cell tenured_size;

	cell promotion_threshold;

	segment *seg;

	nursery_space *nursery;
	aging_space *aging;
	aging_space *aging_semispace;
	tenured_space *tenured;

	card *cards;
	card *cards_end;

	card_deck *decks;
	card_deck *decks_end;
	
	explicit data_heap(cell young_size, cell aging_size, cell tenured_size, cell promotion_threshold);
	~data_heap();
	data_heap *grow(cell requested_size);
	template<typename Generation> void clear_cards(Generation *gen);
	template<typename Generation> void clear_decks(Generation *gen);
	void reset_generation(nursery_space *gen);
	void reset_generation(aging_space *gen);
	void reset_generation(tenured_space *gen);
};

struct data_heap_room {
	cell nursery_size;
	cell nursery_occupied;
	cell nursery_free;
	cell aging_size;
	cell aging_occupied;
	cell aging_free;
	cell tenured_size;
	cell tenured_occupied;
	cell tenured_total_free;
	cell tenured_contiguous_free;
	cell tenured_free_block_count;
	cell cards;
	cell decks;
	cell mark_stack;
};

}
