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
	template<typename Generation> void clear_cards(Generation *gen);
	template<typename Generation> void clear_decks(Generation *gen);
	template<typename Generation> void reset_generation(Generation *gen);
};

template<typename Generation> void data_heap::clear_cards(Generation *gen)
{
	cell first_card = addr_to_card(gen->start - start);
	cell last_card = addr_to_card(gen->end - start);
	memset(&cards[first_card],0,last_card - first_card);
}

template<typename Generation> void data_heap::clear_decks(Generation *gen)
{
	cell first_deck = addr_to_deck(gen->start - start);
	cell last_deck = addr_to_deck(gen->end - start);
	memset(&decks[first_deck],0,last_deck - first_deck);
}

/* After garbage collection, any generations which are now empty need to have
their allocation pointers and cards reset. */
template<typename Generation> void data_heap::reset_generation(Generation *gen)
{
	gen->here = gen->start;

	clear_cards(gen);
	clear_decks(gen);
	gen->starts.clear_object_start_offsets();
}

}
