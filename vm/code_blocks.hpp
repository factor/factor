namespace factor
{

/* The compiled code heap is structured into blocks. */
struct code_block
{
	cell header;
	cell owner; /* tagged pointer to word, quotation or f */
	cell literals; /* tagged pointer to array or f */
	cell relocation; /* tagged pointer to byte-array or f */

	bool free_p() const
	{
		return header & 1 == 1;
	}

	code_block_type type() const
	{
		return (code_block_type)((header >> 1) & 0x3);
	}

	void set_type(code_block_type type)
	{
		header = ((header & ~0x7) | (type << 1));
	}

	bool pic_p() const
	{
		return type() == code_block_pic;
	}

	bool optimized_p() const
	{
		return type() == code_block_optimized;
	}

	cell size() const
	{
		return header & ~7;
	}

	void *xt() const
	{
		return (void *)(this + 1);
	}
};

}
