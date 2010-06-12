namespace factor
{

/* The compiled code heap is structured into blocks. */
struct code_block
{
	cell header;
	cell owner; /* tagged pointer to word, quotation or f */
	cell parameters; /* tagged pointer to array or f */
	cell relocation; /* tagged pointer to byte-array or f */

	bool free_p() const
	{
		return (header & 1) == 1;
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
		cell size = header & ~7;
#ifdef FACTOR_DEBUG
		assert(size > 0);
#endif
		return size;
	}

	template<typename Fixup> cell size(Fixup fixup) const
	{
		return size();
	}

	void *entry_point() const
	{
		return (void *)(this + 1);
	}

	/* GC info is stored at the end of the block */
	gc_info *block_gc_info() const
	{
		return (gc_info *)((u8 *)this + size() - sizeof(gc_info));
	}

	void flush_icache()
	{
		factor::flush_icache((cell)this,size());
	}

	template<typename Iterator> void each_instruction_operand(Iterator &iter)
	{
		if(to_boolean(relocation))
		{
			byte_array *rels = (byte_array *)UNTAG(relocation);

			cell index = 0;
			cell length = (rels->capacity >> TAG_BITS) / sizeof(relocation_entry);

			for(cell i = 0; i < length; i++)
			{
				relocation_entry rel = rels->data<relocation_entry>()[i];
				iter(instruction_operand(rel,this,index));
				index += rel.number_of_parameters();
			}
		}
	}
};

}
