namespace factor
{

static const cell free_list_count = 32;

struct free_heap_block
{
	cell header;

	bool free_p() const
	{
		return header & 1 == 1;
	}

	cell size() const
	{
		return header & ~7;
	}

	void make_free(cell size)
	{
		header = size | 1;
	}
};

struct block_size_compare {
	bool operator()(free_heap_block *a, free_heap_block *b)
	{
		return a->size() < b->size();
	}
};

typedef std::multiset<free_heap_block *, block_size_compare> large_block_set;

struct free_list {
	std::vector<free_heap_block *> small_blocks[free_list_count];
	large_block_set large_blocks;
	cell free_block_count;
	cell free_space;

	void clear_free_list();
	void initial_free_list(cell start, cell end, cell occupied);
	void add_to_free_list(free_heap_block *block);
	free_heap_block *find_free_block(cell size);
	free_heap_block *split_free_block(free_heap_block *block, cell size);
	bool can_allot_p(cell size);
	cell largest_free_block();
};

}
