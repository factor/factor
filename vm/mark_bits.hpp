namespace factor
{

const int block_granularity = 16;
const int forwarding_granularity = 64;

template<typename Block> struct mark_bits {
	cell size;
	cell start;
	cell bits_size;
	u64 *marked;
	cell *forwarding;

	void clear_mark_bits()
	{
		memset(marked,0,bits_size * sizeof(u64));
	}

	void clear_forwarding()
	{
		memset(forwarding,0,bits_size * sizeof(cell));
	}

	explicit mark_bits(cell size_, cell start_) :
		size(size_),
		start(start_),
		bits_size(size / block_granularity / forwarding_granularity),
		marked(new u64[bits_size]),
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
		return (((cell)address - start) / block_granularity);
	}

	Block *line_block(cell line)
	{
		return (Block *)(line * block_granularity + start);
	}

	std::pair<cell,cell> bitmap_deref(Block *address)
	{
		cell line_number = block_line(address);
		cell word_index = (line_number >> 6);
		cell word_shift = (line_number & 63);
		return std::make_pair(word_index,word_shift);
	}

	bool bitmap_elt(u64 *bits, Block *address)
	{
		std::pair<cell,cell> position = bitmap_deref(address);
		return (bits[position.first] & ((u64)1 << position.second)) != 0;
	}

	Block *next_block_after(Block *block)
	{
		return (Block *)((cell)block + block->size());
	}

	void set_bitmap_range(u64 *bits, Block *address)
	{
		std::pair<cell,cell> start = bitmap_deref(address);
		std::pair<cell,cell> end = bitmap_deref(next_block_after(address));

		u64 start_mask = ((u64)1 << start.second) - 1;
		u64 end_mask = ((u64)1 << end.second) - 1;

		if(start.first == end.first)
			bits[start.first] |= start_mask ^ end_mask;
		else
		{
#ifdef FACTOR_DEBUG
			assert(start.first < bits_size);
#endif
			bits[start.first] |= ~start_mask;

			for(cell index = start.first + 1; index < end.first; index++)
				bits[index] = (u64)-1;

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

	/* From http://chessprogramming.wikispaces.com/Population+Count */
	cell popcount(u64 x)
	{
		u64 k1 = 0x5555555555555555ll;
		u64 k2 = 0x3333333333333333ll;
		u64 k4 = 0x0f0f0f0f0f0f0f0fll;
		u64 kf = 0x0101010101010101ll;
		x =  x       - ((x >> 1)  & k1); // put count of each 2 bits into those 2 bits
		x = (x & k2) + ((x >> 2)  & k2); // put count of each 4 bits into those 4 bits
		x = (x       +  (x >> 4)) & k4 ; // put count of each 8 bits into those 8 bits
		x = (x * kf) >> 56; // returns 8 most significant bits of x + (x<<8) + (x<<16) + (x<<24) + ...

		return (cell)x;
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

	/* We have the popcount for every 64 entries; look up and compute the rest */
	Block *forward_block(Block *original)
	{
#ifdef FACTOR_DEBUG
		assert(marked_p(original));
#endif
		std::pair<cell,cell> position = bitmap_deref(original);

		cell approx_popcount = forwarding[position.first];
		u64 mask = ((u64)1 << position.second) - 1;

		cell new_line_number = approx_popcount + popcount(marked[position.first] & mask);
		Block *new_block = line_block(new_line_number);
#ifdef FACTOR_DEBUG
		assert(new_block <= original);
#endif
		return new_block;
	}

	cell rightmost_clear_bit(u64 x)
	{
		cell n = 0;
		while(x & 1)
		{
			n++;
			x >>= 1;
		}
		return n;
	}

	Block *next_unmarked_block_after(Block *original)
	{
		std::pair<cell,cell> position = bitmap_deref(original);
		cell bit_index = position.second;

		for(cell index = position.first; index < bits_size; index++)
		{
			u64 mask = ((s64)marked[index] >> bit_index);
			if(~mask)
			{
				/* Found an unmarked block on this page.
				Stop, it's hammer time */
				cell clear_bit = rightmost_clear_bit(mask);
				return line_block(index * 64 + bit_index + clear_bit);
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

	cell rightmost_set_bit(u64 x)
	{
		cell n = 0;
		while(!(x & 1))
		{
			n++;
			x >>= 1;
		}
		return n;
	}

	Block *next_marked_block_after(Block *original)
	{
		std::pair<cell,cell> position = bitmap_deref(original);
		cell bit_index = position.second;

		for(cell index = position.first; index < bits_size; index++)
		{
			u64 mask = (marked[index] >> bit_index);
			if(mask)
			{
				/* Found an marked block on this page.
				Stop, it's hammer time */
				cell set_bit = rightmost_set_bit(mask);
				return line_block(index * 64 + bit_index + set_bit);
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
