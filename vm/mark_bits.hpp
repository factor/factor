namespace factor
{

const int mark_bits_granularity = sizeof(cell) * 8;
const int mark_bits_mask = sizeof(cell) * 8 - 1;

template<typename Block> struct mark_bits {
	cell size;
	cell start;
	cell bits_size;
	cell *marked;
	cell *forwarding;

	void clear_mark_bits()
	{
		memset(marked,0,bits_size * sizeof(cell));
	}

	void clear_forwarding()
	{
		memset(forwarding,0,bits_size * sizeof(cell));
	}

	explicit mark_bits(cell size_, cell start_) :
		size(size_),
		start(start_),
		bits_size(size / data_alignment / mark_bits_granularity),
		marked(new cell[bits_size]),
		forwarding(new cell[bits_size])
	{
		clear_mark_bits();
		clear_forwarding();
	}

	~mark_bits()
	{
		delete[] marked;
		marked = NULL;
		delete[] forwarding;
		forwarding = NULL;
	}

	cell block_line(Block *address)
	{
		return (((cell)address - start) / data_alignment);
	}

	Block *line_block(cell line)
	{
		return (Block *)(line * data_alignment + start);
	}

	std::pair<cell,cell> bitmap_deref(Block *address)
	{
		cell line_number = block_line(address);
		cell word_index = (line_number / mark_bits_granularity);
		cell word_shift = (line_number & mark_bits_mask);
		return std::make_pair(word_index,word_shift);
	}

	bool bitmap_elt(cell *bits, Block *address)
	{
		std::pair<cell,cell> position = bitmap_deref(address);
		return (bits[position.first] & ((cell)1 << position.second)) != 0;
	}

	Block *next_block_after(Block *block)
	{
		return (Block *)((cell)block + block->size());
	}

	void set_bitmap_range(cell *bits, Block *address)
	{
		std::pair<cell,cell> start = bitmap_deref(address);
		std::pair<cell,cell> end = bitmap_deref(next_block_after(address));

		cell start_mask = ((cell)1 << start.second) - 1;
		cell end_mask = ((cell)1 << end.second) - 1;

		if(start.first == end.first)
			bits[start.first] |= start_mask ^ end_mask;
		else
		{
#ifdef FACTOR_DEBUG
			assert(start.first < bits_size);
#endif
			bits[start.first] |= ~start_mask;

			for(cell index = start.first + 1; index < end.first; index++)
				bits[index] = (cell)-1;

			if(end_mask != 0)
			{
#ifdef FACTOR_DEBUG
				assert(end.first < bits_size);
#endif
				bits[end.first] |= end_mask;
			}
		}
	}

	bool marked_p(Block *address)
	{
		return bitmap_elt(marked,address);
	}

	void set_marked_p(Block *address)
	{
		set_bitmap_range(marked,address);
	}

	/* The eventual destination of a block after compaction is just the number
	of marked blocks before it. Live blocks must be marked on entry. */
	void compute_forwarding()
	{
		cell accum = 0;
		for(cell index = 0; index < bits_size; index++)
		{
			forwarding[index] = accum;
			accum += popcount(marked[index]);
		}
	}

	/* We have the popcount for every mark_bits_granularity entries; look
	up and compute the rest */
	Block *forward_block(Block *original)
	{
#ifdef FACTOR_DEBUG
		assert(marked_p(original));
#endif
		std::pair<cell,cell> position = bitmap_deref(original);

		cell approx_popcount = forwarding[position.first];
		cell mask = ((cell)1 << position.second) - 1;

		cell new_line_number = approx_popcount + popcount(marked[position.first] & mask);
		Block *new_block = line_block(new_line_number);
#ifdef FACTOR_DEBUG
		assert(new_block <= original);
#endif
		return new_block;
	}

	Block *next_unmarked_block_after(Block *original)
	{
		std::pair<cell,cell> position = bitmap_deref(original);
		cell bit_index = position.second;

		for(cell index = position.first; index < bits_size; index++)
		{
			cell mask = ((fixnum)marked[index] >> bit_index);
			if(~mask)
			{
				/* Found an unmarked block on this page.
				Stop, it's hammer time */
				cell clear_bit = rightmost_clear_bit(mask);
				return line_block(index * mark_bits_granularity + bit_index + clear_bit);
			}
			else
			{
				/* No unmarked blocks on this page.
				Keep looking */
				bit_index = 0;
			}
		}

		/* No unmarked blocks were found */
		return (Block *)(this->start + this->size);
	}

	Block *next_marked_block_after(Block *original)
	{
		std::pair<cell,cell> position = bitmap_deref(original);
		cell bit_index = position.second;

		for(cell index = position.first; index < bits_size; index++)
		{
			cell mask = (marked[index] >> bit_index);
			if(mask)
			{
				/* Found an marked block on this page.
				Stop, it's hammer time */
				cell set_bit = rightmost_set_bit(mask);
				return line_block(index * mark_bits_granularity + bit_index + set_bit);
			}
			else
			{
				/* No marked blocks on this page.
				Keep looking */
				bit_index = 0;
			}
		}

		/* No marked blocks were found */
		return (Block *)(this->start + this->size);
	}

	cell unmarked_block_size(Block *original)
	{
		Block *next_marked = next_marked_block_after(original);
		return ((char *)next_marked - (char *)original);
	}
};

}
