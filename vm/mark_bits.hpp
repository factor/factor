namespace factor
{

const int forwarding_granularity = 128;

template<typename Block, int Granularity> struct mark_bits {
	cell start;
	cell size;
	cell bits_size;
	unsigned int *marked;
	unsigned int *freed;
	cell forwarding_size;
	cell *forwarding;

	void clear_mark_bits()
	{
		memset(marked,0,bits_size * sizeof(unsigned int));
	}

	void clear_free_bits()
	{
		memset(freed,0,bits_size * sizeof(unsigned int));
	}

	void clear_forwarding()
	{
		memset(forwarding,0,forwarding_size * sizeof(cell));
	}

	explicit mark_bits(cell start_, cell size_) :
		start(start_),
		size(size_),
		bits_size(size / Granularity / 32),
		marked(new unsigned int[bits_size]),
		freed(new unsigned int[bits_size]),
		forwarding_size(size / Granularity / forwarding_granularity),
		forwarding(new cell[forwarding_size])
	{
		clear_mark_bits();
		clear_free_bits();
		clear_forwarding();
	}

	~mark_bits()
	{
		delete[] marked;
		marked = NULL;
		delete[] freed;
		freed = NULL;
		delete[] forwarding;
		forwarding = NULL;
	}

	std::pair<cell,cell> bitmap_deref(Block *address)
	{
		cell word_number = (((cell)address - start) / Granularity);
		cell word_index = (word_number >> 5);
		cell word_shift = (word_number & 31);

#ifdef FACTOR_DEBUG
		assert(word_index < bits_size);
#endif

		return std::make_pair(word_index,word_shift);
	}

	bool bitmap_elt(unsigned int *bits, Block *address)
	{
		std::pair<cell,cell> pair = bitmap_deref(address);
		return (bits[pair.first] & (1 << pair.second)) != 0;
	}

	void set_bitmap_elt(unsigned int *bits, Block *address, bool flag)
	{
		std::pair<cell,cell> pair = bitmap_deref(address);
		if(flag)
			bits[pair.first] |= (1 << pair.second);
		else
			bits[pair.first] &= ~(1 << pair.second);
	}

	bool is_marked_p(Block *address)
	{
		return bitmap_elt(marked,address);
	}

	void set_marked_p(Block *address, bool marked_p)
	{
		set_bitmap_elt(marked,address,marked_p);
	}

	bool is_free_p(Block *address)
	{
		return bitmap_elt(freed,address);
	}

	void set_free_p(Block *address, bool free_p)
	{
		set_bitmap_elt(freed,address,free_p);
	}
};

}
